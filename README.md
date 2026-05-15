# Round-Robin Arbiter — Formal Verification

Formally verified 4-requester round-robin arbiter using SymbiYosys + Z3 SMT solver.

## Design
- N=4 parameterized priority-based arbiter
- Combinational grant logic + registered output
- Non-blocking assignment bug found and fixed via FV

## Properties Proved (k-induction, depth=20)
1. No grant asserted during reset
2. At most one grant at a time (one-hot)
3. Grant only when corresponding request was active ($past)
4. No grant when no requests pending

## Bug Found by FV
**Root cause:** Non-blocking assignment (`<=`) read inside `for` loop caused
all active requesters to be granted simultaneously — mutual exclusion violated.

**Fix:** Separated into combinational `always @(*)` + sequential `always @(posedge clk)`
blocks using blocking assignments for grant decision logic.

## Tools
- [SymbiYosys](https://github.com/YosysHQ/sby) — formal verification front-end
- Z3 — SMT solver backend
- OSS CAD Suite

## Run
```bash
sby -f arbiter.sby
```
Expected: `DONE (PASS, rc=0)` — successful proof by k-induction.
