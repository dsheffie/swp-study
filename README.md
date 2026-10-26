# swp-study

MIPSpro 7.30 software pipelining (SWP) on the TSVC kernels, run on the
[r9999](https://github.com/dsheffie/r9999) out-of-order MIPS core.
Writeup and A/B pipetraces: https://dsheffie.github.io/swp-study/

- `harness/`: links the MIPSpro n32 R4000 objects (`obj/*.o`, built in IRIX 6.5 by
  `src/build_obj.sh`) bare-metal. `make` builds `tsvc_swp.elf` and `tsvc_noswp.elf`;
  `make one K=s241` builds a single-kernel pair for pipetraces. Needs `mips-linux-gnu-gcc-14`.
- `listings/`: MIPSpro `-S` output, SWP on and off (`#<swps>` = MIPSpro's schedule notes).
- `results/`: per-kernel Count from r9999 `ooo_core` (`rtl_*.log`, cycles/2) and from
  `interp_mips` (`interp_*.txt`, instructions), `ooo_core --branch` mispredict logs,
  `ipc_table.txt` (`tools/ipc.py .`) and `rank.txt` (`tools/rank.py .`).
- `pipetraces/`: r9999 `gen_html` pipetraces of s318, vas and s241 with SWP on and off.
- `tools/`: `findpc` and `dumprec` read `ooo_core --pipelog` dumps (build against r9999's
  `pipeline_record.hh`).

Sim runs: `ooo_core -f tsvc_swp.elf -m 37 --branch b.txt` (ROB 32, 512 KB L2, memory latency 37).
