# Coverage and Review Queue

[Subjects](../../../README.md) | [Dictionary](../../../dictionary/README.md) | [Revision method](../guides/REVISION_METHOD.md)

Notes are complete only within the stated source boundary. RTL status reports
the documented verification boundary; it does not imply a new simulation run
or timing signoff. Review dates record actual study sessions. None have been
recorded in this dashboard yet.

## Coverage dashboard

| Subject | Notes complete within scope | RTL verification | Last revised | Next review | Next action |
|---|---|---|---|---|---|
| [MOSFET and CMOS](../../../MOSFET%20and%20CMOS/README.md#quick-revision) | 110 pages, five notebooks; five module revision sections | Not applicable | Not recorded | Unscheduled | Derive threshold, delay, and noise margins closed-book |
| [STA](../../../Static%20Timing%20Analysis/README.md#quick-revision) | 25 pages; setup/hold reference and sign checks | Not applicable | Not recorded | Unscheduled | Solve one maximum-delay and one minimum-delay path |
| [I2C](../../../Protocols/01%20I2C/README.md#quick-revision) | Notebook pages 1–5 | No RTL implementation in this chapter | Not recorded | Unscheduled | Trace read ownership and the final NACK |
| [SPI](../../../Protocols/02%20SPI/README.md#quick-revision) | Notebook pages 6–8 | No RTL implementation in this chapter | Not recorded | Unscheduled | Draw all four CPOL/CPHA modes |
| [UART](../../../Protocols/03%20UART/README.md#quick-revision) | Notebook pages 9–16; TX/RX architecture | Design discussion; no verified UART core here | Not recorded | Unscheduled | Calculate tick error and trace receiver sampling |
| [AHB](../../../Protocols/04%20AMBA/01%20AHB/README.md#quick-revision) | 18 notebook pages plus ten iPad pages and lecture frames | [Documented AHB-Lite manager testbench](../../../Protocols/04%20AMBA/01%20AHB/code/README.md#run-it); no new RTL run in this update | Not recorded | Unscheduled | Trace address/data overlap through a waited WRAP4 burst |
| [APB](../../../Protocols/04%20AMBA/02%20APB/README.md#quick-revision) | Notebook pages 19–24 plus iPad and lecture captures | No RTL implementation in this chapter | Not recorded | Unscheduled | Draw SETUP, waited ACCESS, and completion/error |
| [AXI](../../../Protocols/04%20AMBA/03%20AXI/README.md#quick-revision) | All nine sections, lesson IDs 1–128, including code resources | [Compile baseline](../../../Protocols/04%20AMBA/03%20AXI/Code/README.md#compile-check): 11/15 full builds; four documented blockers; functional verification remains separate | Not recorded | Unscheduled | Trace independent channels and review the known code limitations |
| [Frequency Dividers](../../../Frequency%20Dividers/README.md#quick-revision) | All 13 notebook pages | See separate RTL practice | Not recorded | Unscheduled | Trace one odd-duty and one fractional-divider period |
| [Divider RTL practice](../../../Programmable%20Frequency%20Divider/README.md#quick-revision) | Implemented `/2`–`/5` and documented extra cases | [Self-checking simulation results documented](../../../Programmable%20Frequency%20Divider/README.md#progress); synthesis and timing review pending | Not recorded | Unscheduled | Run synthesis and inspect inferred clocks and timing |
| [FIFO](../../../FIFO/README.md#quick-revision) | Architecture, contract, verification, and CDC guide | Starter modules; FIFO behavior is not implemented or verified | Not recorded | Unscheduled | Implement the synchronous contract and boundary tests |

## Review queue

Add a row after a closed-book attempt. Use a specific term, page, derivation,
waveform, or invariant and link it to the source explanation. Leave dates
unrecorded until the session happens; repository edits are not study reviews.

| Item / source | Mark | Last revised | Next review | Repair action |
|---|---|---|---|---|
| No review attempts recorded yet | — | Not recorded | Unscheduled | Choose a question from a subject’s quick revision section |

- `M` (missed): review tomorrow; repair the prerequisite and solve another example.
- `H` (hesitant): review in three days; answer a contrast or “why” question.
- `R` (recalled): review in seven days, then after 14 and 30 days.

After each attempt, update its queue row and the corresponding dashboard dates.
Keep notes coverage and RTL results separate from recall performance.
