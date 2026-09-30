"""Check published Markdown links, assets, navigation, and the single dictionary.

Run from any directory: python _internal/repository/tools/check_repository.py
Uses only Python's standard library. Remote links are not fetched.
"""
from collections import Counter
from pathlib import Path
from urllib.parse import unquote, urlsplit
import argparse
import html
import re
import subprocess
import sys


def mask_code(text, inline=False):
    """Keep offsets and line numbers while excluding fenced examples and code."""
    lines, fence = [], None
    for line in text.splitlines(keepends=True):
        match = re.match(r'^\s{0,3}(`{3,}|~{3,})', line)
        if fence:
            lines.append(re.sub(r'[^\n]', ' ', line))
            if match and match[1][0] == fence[0] and len(match[1]) >= len(fence):
                fence = None
        elif match:
            fence = match[1]
            lines.append(re.sub(r'[^\n]', ' ', line))
        else:
            lines.append(line)
    result = ''.join(lines)
    result = re.sub(r'<!--.*?-->', lambda m: re.sub(r'[^\n]', ' ', m[0]), result, flags=re.S)
    if inline:
        result = re.sub(r'(`+)(.+?)\1', lambda m: re.sub(r'[^\n]', ' ', m[0]), result)
    return result


def heading_slug(label):
    label = re.sub(r'!?\[([^\]]+)\]\([^)]*\)', r'\1', label)
    label = html.unescape(re.sub(r'<[^>]*>', '', label)).strip().lower()
    label = re.sub(r'[^\w\-\s]', '', label, flags=re.UNICODE)
    return re.sub(r'\s', '-', label)


def anchors(text):
    content = mask_code(text)
    explicit = re.findall(r'<a\s+(?:id|name)=["\']([^"\']+)["\']', content)
    result, counts = set(explicit), Counter()
    for match in re.finditer(r'^#{1,6}\s+(.+?)(?:\s+#+)?\s*$', content, re.M):
        slug = heading_slug(match[1])
        suffix = '' if counts[slug] == 0 else f'-{counts[slug]}'
        result.add(slug + suffix)
        counts[slug] += 1
    duplicates = [key for key, count in Counter(explicit).items() if count > 1]
    return result, duplicates


def destination(raw):
    raw = raw.strip()
    if raw.startswith('<'):
        return raw[1:raw.find('>')]
    # Unescaped whitespace starts an optional Markdown title.
    return re.split(r'(?<!\\)\s', raw, maxsplit=1)[0].replace('\\ ', ' ')


def links(text):
    """Read inline and reference links, including nested brackets/parentheses."""
    content = mask_code(text, inline=True)
    references = {m[1].strip().lower(): destination(m[2]) for m in
                  re.finditer(r'^\s{0,3}\[([^\]]+)\]:\s*(.+)$', content, re.M)}
    i = 0
    while i < len(content):
        if content[i] != '[' or (i and content[i-1] == '\\'):
            i += 1
            continue
        start, depth, j = i, 1, i+1
        while j < len(content) and depth:
            if content[j] == '\\':
                j += 2
                continue
            depth += (content[j] == '[') - (content[j] == ']')
            j += 1
        if depth:
            i += 1
            continue
        label, raw, end = content[start+1:j-1], None, j
        if j < len(content) and content[j] == '(':
            depth, end = 1, j+1
            quoted, angle = None, False
            while end < len(content) and depth:
                c = content[end]
                if c == '\\':
                    end += 2
                    continue
                if quoted:
                    if c == quoted:
                        quoted = None
                elif angle:
                    if c == '>': angle = False
                elif c in '\"\'' and end > j+1 and content[end-1].isspace():
                    quoted = c
                elif c == '<': angle = True
                else:
                    depth += (c == '(') - (c == ')')
                end += 1
            if not depth:
                raw = destination(content[j+1:end-1])
        elif j < len(content) and content[j] == '[':
            end = content.find(']', j+1)
            if end != -1:
                raw = references.get((content[j+1:end] or label).strip().lower())
                end += 1
            else:
                end = j
        elif j == len(content) or content[j] != ':':
            raw = references.get(label.strip().lower())
        if raw:
            yield start, raw, start > 0 and content[start-1] == '!'
        i = max(j, end)


def check_dictionary(text):
    errors = []
    ids = re.findall(r'<a id="([^"]+)"', text)
    definitions = {x for x in ids if x.startswith('term-')}
    entries = {x.removeprefix('index-') for x in ids if x.startswith('index-term-')}
    if definitions != entries:
        errors.append('dictionary term index does not match definitions')
    total = re.search(r'All \*\*(\d+) entries\*\*', text)
    if not total or int(total[1]) != len(definitions):
        errors.append(f'dictionary total must be {len(definitions)}')
    subject_rows = list(re.finditer(r'<a id="index-subject-([^"]+)"></a>\[[^\]]+\]\(#([^\)]+)\) \| (\d+) \|', text))
    if not subject_rows:
        errors.append('dictionary subject index is missing')
    subject_counts = []
    for row in subject_rows:
        subject = row[2]
        match = re.search(r'<a id="'+re.escape(subject)+r'"></a>', text)
        if not match:
            errors.append(f'dictionary subject anchor missing: {subject}')
            continue
        subject_counts.append((match.start(), subject, int(row[3])))
        if f'](#index-subject-{row[1]})' not in text[match.start():]:
            errors.append(f'dictionary subject return missing: {subject}')
    subject_counts.sort()
    for i, (start, subject, expected) in enumerate(subject_counts):
        end = subject_counts[i+1][0] if i+1 < len(subject_counts) else len(text)
        actual = len(re.findall(r'<a id="term-[^"]+"', text[start:end]))
        if actual != expected:
            errors.append(f'dictionary subject {subject}: index says {expected}, found {actual}')
    for term in definitions:
        if not re.search(r'<a id="index-'+re.escape(term)+r'"></a>[^\n]*\]\(#'+re.escape(term)+r'\)', text):
            errors.append(f'dictionary index target incorrect: {term}')
        block = re.search(r'<a id="'+re.escape(term)+r'"></a>(.*?)(?=<a id="term-|\Z)', text, re.S)
        if block and f'](#index-{term}' not in block[1]:
            errors.append(f'dictionary term return missing: {term}')
    return errors


def check(root, files):
    """Check only the supplied published inventory, also rejecting untracked targets."""
    inventory = {Path(f).as_posix() for f in files}
    documents = {f: (root/f).read_text(encoding='utf-8') for f in sorted(inventory) if f.endswith('.md') and (root/f).is_file()}
    anchor_map, errors, link_count, image_count = {}, [], 0, 0
    for f, text in documents.items():
        found, duplicates = anchors(text)
        anchor_map[f] = found
        errors.extend(f'{f}: duplicate explicit anchor #{a}' for a in duplicates)
        # Navigation IDs are explicit; an ordinary heading called "Page 3"
        # must not accidentally become a required page-navigation contract.
        for anchor in set(re.findall(r'<a id="([^"]+)"', mask_code(text))):
            if re.fullmatch(r'(?:page|ipad-page|lesson|topic)-\d+', anchor):
                if 'index-'+anchor not in found:
                    errors.append(f'{f}: #{anchor} has no matching index entry')
                elif f'](#index-{anchor})' not in text:
                    errors.append(f'{f}: #{anchor} has no matching return link')
            if re.fullmatch(r'index-(?:page|ipad-page|lesson|topic)-\d+', anchor) and anchor.removeprefix('index-') not in found:
                errors.append(f'{f}: #{anchor} has no content anchor')
            elif re.fullmatch(r'index-(?:page|ipad-page|lesson|topic)-\d+', anchor):
                target = anchor.removeprefix('index-')
                if not re.search(r'<a id="'+re.escape(anchor)+r'"></a>\s*\[[^\]]+\]\(#'+re.escape(target)+r'\)', text):
                    errors.append(f'{f}: #{anchor} does not link to its matching content')
    for f, text in documents.items():
        for offset, href, is_image in links(text):
            if re.match(r'(?:[a-zA-Z][\w+.-]*:|//)', href):
                continue
            link_count += 1
            image_count += is_image
            url = urlsplit(html.unescape(href))
            target = ((root if url.path.startswith('/') else (root/f).parent) / unquote(url.path).lstrip('/')).resolve() if url.path else (root/f).resolve()
            line = text.count('\n', 0, offset) + 1
            prefix = f'{f}:{line}'
            try:
                relative = target.relative_to(root.resolve()).as_posix()
            except ValueError:
                errors.append(f'{prefix}: local target leaves repository: {href}')
                continue
            if not target.exists():
                errors.append(f'{prefix}: missing {"image" if is_image else "file"}: {href}')
            elif target.is_file() and relative not in inventory:
                errors.append(f'{prefix}: target is not tracked: {href}')
            elif target.is_dir() and not any(x.startswith(relative.rstrip('/')+'/') for x in inventory):
                errors.append(f'{prefix}: directory has no tracked files: {href}')
            elif url.fragment and relative in anchor_map and unquote(url.fragment) not in anchor_map[relative]:
                errors.append(f'{prefix}: missing anchor: {href}')
    if 'dictionary/README.md' in documents:
        errors.extend('dictionary/README.md: '+e for e in check_dictionary(documents['dictionary/README.md']))
        other_dictionary_files = [f for f in inventory if f.startswith('dictionary/') and f.endswith('.md') and f != 'dictionary/README.md']
        if other_dictionary_files:
            errors.append('dictionary must stay in one Markdown file: '+', '.join(other_dictionary_files))
    return errors, len(documents), link_count, image_count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[3])
    args = parser.parse_args()
    root = args.root.resolve()
    try:
        files = subprocess.check_output(['git', '-C', str(root), 'ls-files', '-z'], text=True).split('\0')
        errors, docs, local_links, images = check(root, filter(None, files))
    except (OSError, subprocess.CalledProcessError, UnicodeError) as exc:
        print(f'Cannot check repository: {exc}', file=sys.stderr)
        return 2
    for error in errors:
        print(error)
    print(f'{docs} Markdown files; {local_links} local links ({images} images); {len(errors)} errors')
    return bool(errors)


if __name__ == '__main__':
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main())
