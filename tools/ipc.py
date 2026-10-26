#!/usr/bin/env python3
"""ipc.py <repo root>: per-kernel IPC with and without SWP.
Insns = interp_mips CP0 Count (+1 per insn); cycles = 2 * r9999 ooo_core Count (ticks every other cycle)."""
import re, math, sys
def load(f):
    d = {}
    for l in open(f):
        m = re.match(r'^(\S+)\s+n=\d+ iters=\d+ count=(\d+)', l)
        if m: d[m.group(1)] = int(m.group(2))
    return d
d = sys.argv[1]
rs, rn = load(d+'/results/rtl_swp.log'), load(d+'/results/rtl_noswp.log')
isw, inn = load(d+'/results/interp_swp.txt'), load(d+'/results/interp_noswp.txt')
rows = []
for k in rn:
    cs, cn = 2*rs[k], 2*rn[k]
    rows.append((k, inn[k], cn, inn[k]/cn, isw[k], cs, isw[k]/cs, cs/cn, isw[k]/inn[k]))
gm = lambda xs: math.exp(sum(map(math.log, xs))/len(xs))
print('geomean IPC noswp %.3f  swp %.3f   insn ratio swp/noswp %.3f   cycle ratio %.3f' % (
    gm([r[3] for r in rows]), gm([r[6] for r in rows]), gm([r[8] for r in rows]), gm([r[7] for r in rows])))
print('agg IPC noswp %.3f swp %.3f' % (sum(inn.values())/sum(2*v for v in rn.values()), sum(isw.values())/sum(2*v for v in rs.values())))
hdr = '%-7s %8s %8s %6s | %8s %8s %6s | %6s %6s' % ('kern','ins_n','cyc_n','ipc_n','ins_s','cyc_s','ipc_s','cyc s/n','ins s/n')
rows.sort(key=lambda r: -r[7])
print(hdr)
for r in rows: print('%-7s %8d %8d %6.3f | %8d %8d %6.3f | %6.2f %6.2f' % r)
# histogram
import collections
for name, idx in (('noswp', 3), ('swp', 6)):
    b = collections.Counter(min(int(r[idx]*10), 12) for r in rows)
    print(name, ' '.join('%.1f:%d' % (i/10, b[i]) for i in sorted(b)))
