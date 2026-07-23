# Fixes and Faster Workflows

This file records repository and tool problems that were actually encountered, what caused them, how they were fixed, and the shortest reliable method to use next time.

## 2026-07-18 — FIFO topic and Vivado starter project

### Requested outcome

The FIFO work needed two stages:

1. Make FIFO the second major VLSI topic and explain the implementation approach without initially providing a finished design.
2. Create a minimal Vivado project with clearly named files so coding could begin from an empty starter rather than from a completed FIFO solution.

### Final result

| Item | Final location or value |
|---|---|
| FIFO approach | `subjects/VLSI Design/FIFO/README.md` |
| Design starter | `subjects/VLSI Design/FIFO/src/fifo.v` |
| Testbench starter | `subjects/VLSI Design/FIFO/sim/fifo_tb.v` |
| Vivado project | `subjects/VLSI Design/FIFO/vivado/fifo_vivado/fifo_vivado.xpr` |
| Design top | `fifo` |
| Simulation top | `fifo_tb` |
| FPGA part | `xc7a35tcpg236-1` |
| Generated-file rules | `subjects/VLSI Design/FIFO/vivado/fifo_vivado/.gitignore` |

The two Verilog files contain only module shells and comments. No FIFO behavior, interface, test stimulus, synthesis, or simulation result was invented.

## What happened during the Vivado setup

### 1. The project was created successfully

Vivado 2024.1 was already open. A project named `fifo_vivado` was created directly from the Tcl Console rather than through the project wizard.

The project appeared at the correct location and used the default Artix-7 part `xc7a35tcpg236-1`.

### 2. Adding files initially failed at the space in `VLSI Design`

Vivado reported a path similar to this as missing:

```text
C:/Users/kapil/OneDrive/Desktop/RevisionSolved/subjects/VLSI
```

The real path was longer and contained `VLSI Design`. The failure occurred because `add_files` expects a Tcl list. Passing the path as an ordinary quoted or braced string did not give `add_files` a safe one-element file list; the path was split at its space.

### Correct fix

Construct a real one-element Tcl list for every file path:

```tcl
add_files -norecurse [list {C:/Users/kapil/OneDrive/Desktop/RevisionSolved/subjects/VLSI Design/FIFO/src/fifo.v}]
add_files -fileset sim_1 -norecurse [list {C:/Users/kapil/OneDrive/Desktop/RevisionSolved/subjects/VLSI Design/FIFO/sim/fifo_tb.v}]
```

After this change, Vivado showed:

- one Design Source;
- two Simulation Sources, because the simulation set contains both the design and its testbench;
- `fifo` as the design top;
- `fifo_tb` as the simulation top.

### 3. Comment-only Verilog files were attached but did not appear as useful hierarchy modules

The first versions of `fifo.v` and `fifo_tb.v` contained only comments. Vivado knew that the files were in the source sets, but there was no module for the Hierarchy view to display.

### Correct fix

Give each starter file the smallest legal module shell:

```verilog
module fifo ();
    // Start the FIFO design here.
endmodule
```

```verilog
module fifo_tb;
    // Add the FIFO instance and test stimulus here.
endmodule
```

This does not solve the FIFO. It only gives Vivado a named design unit that can be selected as the top and opened from the source tree.

### 4. `save_project` was not the correct Vivado Tcl command

Entering `save_project` produced an error asking for the `name` option used by `save_project_as`.

### Correct handling

- Normal changes to source sets and project properties are written into the active `.xpr` project.
- Use the GUI save action when only saving the current project state.
- Use `save_project_as` only when intentionally creating or renaming a project copy, with its required name and directory arguments.
- Do not add a bare `save_project` command to future setup scripts.

### 5. `open_file` was not a valid Tcl command in this Vivado session

The attempted command `open_file [get_files */fifo.v]` was rejected as an invalid command.

### Correct handling

Open the file through the Sources pane:

1. Select the **Hierarchy** tab.
2. Expand **Design Sources**.
3. Open `fifo (fifo.v)`.

After the module shell exists, the file is visible normally in this tree.

### 6. Vivado warned that the project path was long

Vivado displayed a non-fatal warning that the project path exceeded its preferred length. The project still opened and the source references were correct.

For this repository the warning is currently accepted. If a later synthesis, IP-generation, or implementation step fails because of path length, shorten only the generated project-directory names before changing the organized study-topic path.

### 7. Generated Vivado folders appeared beside the project

Vivado created cache and hardware-state folders automatically. These are reproducible tool outputs and should not crowd Git status.

A project-local `.gitignore` now excludes common generated directories and logs while preserving the important `.xpr`, design source, and testbench.

## Fastest reliable setup next time

Use this procedure for another topic named `<topic>`.

### Step 1 — create the source files first

Create these before creating the Vivado project:

```text
src/<topic>.v
sim/<topic>_tb.v
```

Give both files a legal module shell. Use `<topic>` as the design module and `<topic>_tb` as the testbench module.

### Step 2 — reuse the existing Vivado window

- If the required project already exists, open its `.xpr`; do not recreate it.
- If it does not exist, create it from the Vivado Tcl Console.
- Use forward slashes in Tcl paths.

### Step 3 — use Tcl variables and `[list ...]` for paths

The reliable pattern is:

```tcl
set project_dir {C:/absolute/path/to/vivado/<topic>_vivado}
set design_file {C:/absolute/path/to/src/<topic>.v}
set testbench_file {C:/absolute/path/to/sim/<topic>_tb.v}

create_project <topic>_vivado $project_dir -part xc7a35tcpg236-1 -force
set_property target_language Verilog [current_project]

add_files -norecurse [list $design_file]
add_files -fileset sim_1 -norecurse [list $testbench_file]

set_property top <topic> [get_filesets sources_1]
set_property top <topic>_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
```

The important part is `[list $design_file]` and `[list $testbench_file]`. Keep this even when a current path happens not to contain spaces; it makes the command safe when a future folder does.

Vivado may print an informational warning that `update_compile_order` is unnecessary in the GUI because it automatically updates after hierarchy changes. The commands are harmless, but they may be omitted when working interactively if the source tree has already refreshed.

### Step 4 — verify the project before coding

Check all of these:

- [ ] The `.xpr` exists.
- [ ] Design Sources contains `<topic>.v`.
- [ ] Simulation Sources contains both `<topic>.v` and `<topic>_tb.v`.
- [ ] The design top is `<topic>`.
- [ ] The simulation top is `<topic>_tb`.
- [ ] The target part is correct.
- [ ] The design file opens from the Hierarchy view.
- [ ] Generated cache/run/log directories are ignored by Git.

Only after these checks should actual RTL ports and behavior be added.

## FIFO project: where to start coding

1. Begin in `src/fifo.v` by deciding the synchronous FIFO interface: clock, reset, write request, read request, input data, output data, `full`, and `empty`.
2. Keep the module name `fifo`, because the project already uses it as the design top.
3. After the interface is stable, instantiate it inside `sim/fifo_tb.v`.
4. Keep the testbench module name `fifo_tb`, because the simulation fileset already uses it as the simulation top.
5. Do not begin with asynchronous FIFO logic. Finish and verify the single-clock FIFO first, following the FIFO README.

## Current verification boundary

The starter project and file references were verified. Synthesis and simulation were intentionally not run because the modules contain no FIFO logic yet. A later result must not be called correct merely because the project opens; correctness begins only after a self-checking testbench passes and the synthesis/timing reports are reviewed.
