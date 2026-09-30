"""Regression fixtures for the repository checker; no third-party packages."""
from pathlib import Path
import tempfile
import unittest

from check_repository import anchors, check, check_dictionary, links


class RepositoryChecks(unittest.TestCase):
    def run_fixture(self, documents, inventory=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, text in documents.items():
                target = root/name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(text, encoding='utf-8')
            return check(root, inventory if inventory is not None else documents)[0]

    def test_encoded_path_title_and_nested_parentheses(self):
        self.assertEqual([], self.run_fixture({
            'README.md': '[Read](notes/My%20file%20(v2).md#details "Open (details)")',
            'notes/My file (v2).md': '# Details\n',
        }))

    def test_missing_image(self):
        errors = self.run_fixture({'README.md': '![source](images/missing.png)'})
        self.assertTrue(any('missing image' in e for e in errors))

    def test_missing_file(self):
        self.assertTrue(any('missing file' in e for e in self.run_fixture({'README.md': '[Notes](absent.md)'})))

    def test_missing_fragment(self):
        errors = self.run_fixture({'README.md': '[Go](notes.md#absent)', 'notes.md': '# Present'})
        self.assertTrue(any('missing anchor' in e for e in errors))

    def test_existing_untracked_target_is_not_publishable(self):
        errors = self.run_fixture({'README.md': '[Draft](draft.md)', 'draft.md': '# Draft'}, ['README.md'])
        self.assertTrue(any('not tracked' in e for e in errors))

    def test_fences_inline_code_comments_and_remote_urls_are_skipped(self):
        text = '```markdown\n[bad](missing.md)\n```\n`[bad](missing.md)`\n<!-- [bad](missing.md) -->\n[web](https://example.org/no-check)'
        self.assertEqual([], self.run_fixture({'README.md': text}))

    def test_reference_links(self):
        found = list(links('[first][note]\n[second][]\n\n[note]: notes.md#topic\n[second]: notes.md#topic'))
        self.assertEqual(['notes.md#topic', 'notes.md#topic'], [x[1] for x in found])

    def test_repeated_headings_have_github_suffixes(self):
        found, duplicates = anchors('# Repeat\n## Repeat\n## Repeat\n')
        self.assertEqual({'repeat', 'repeat-1', 'repeat-2'}, found)
        self.assertEqual([], duplicates)

    def test_duplicate_explicit_anchor(self):
        errors = self.run_fixture({'README.md': '<a id="same"></a>\n<a id="same"></a>'})
        self.assertTrue(any('duplicate explicit anchor' in e for e in errors))

    def test_matching_index_and_return(self):
        text = '<a id="index-page-03"></a>[3](#page-03)\n<a id="page-03"></a>\n## Page 3\n[Back](#index-page-03)'
        self.assertEqual([], self.run_fixture({'README.md': text}))

    def test_missing_return(self):
        text = '<a id="index-page-03"></a>[3](#page-03)\n<a id="page-03"></a>\n## Page 3'
        self.assertTrue(any('no matching return' in e for e in self.run_fixture({'README.md': text})))

    def test_index_entry_pointing_to_another_valid_page(self):
        text = '<a id="index-page-03"></a>[3](#page-04)\n<a id="page-03"></a>\n<a id="page-04"></a>\n[Back](#index-page-03)'
        self.assertTrue(any('does not link to its matching content' in e for e in self.run_fixture({'README.md': text})))


class DictionaryChecks(unittest.TestCase):
    def dictionary(self):
        return '''All **1 entries**
| <a id="index-subject-demo"></a>[Demo](#demo) | 1 |
| <a id="index-term-demo-a"></a>[A](#term-demo-a) | Demo |
<a id="demo"></a>
## Demo
[Back](#index-subject-demo)
| <a id="term-demo-a"></a>A | Meaning | [↑](#index-term-demo-a "Return") |
'''

    def test_correct_indexes_and_returns(self):
        self.assertEqual([], check_dictionary(self.dictionary()))

    def test_stale_total(self):
        self.assertTrue(any('total must be 1' in e for e in check_dictionary(self.dictionary().replace('**1 entries**', '**2 entries**'))))

    def test_stale_subject_count(self):
        self.assertTrue(any('index says 2, found 1' in e for e in check_dictionary(self.dictionary().replace('| 1 |', '| 2 |'))))

    def test_missing_alphabetical_entry(self):
        text = self.dictionary().replace('<a id="index-term-demo-a"></a>', '')
        self.assertTrue(any('index does not match definitions' in e for e in check_dictionary(text)))

    def test_missing_definition_return(self):
        text = self.dictionary().replace('[↑](#index-term-demo-a "Return")', '')
        self.assertTrue(any('term return missing' in e for e in check_dictionary(text)))

    def test_additional_dictionary_file(self):
        errors = RepositoryChecks().run_fixture({'dictionary/README.md': self.dictionary(), 'dictionary/extra.md': '# Extra'})
        self.assertTrue(any('one Markdown file' in e for e in errors))


if __name__ == '__main__':
    unittest.main()
