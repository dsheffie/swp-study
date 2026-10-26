#!/usr/bin/env python3
"""rank.py <repo root>: SWP losers and winners with branch-likely counts (static, from
the disassembly) and mispredicts (from the ooo_core --branch logs) per kernel.
Run tools/ipc.py first (writes nothing; rank.py reads results/ipc_table.txt) and
`make -C harness` (for the ELFs)."""
import bisect, collections, re, subprocess, sys
LIKELY = re.compile(r'(bc1tl|bc1fl|beql|bnel|blezl|bgtzl|bltzl|bgezl|beqzl|bnezl)$')
def funcs(elf):
    dis = subprocess.run(['mips64-linux-gnuabi64-objdump', '-d', elf], capture_output=True, text=True).stdout
    cur, lik, rng = None, collections.Counter(), {}
    for l in dis.splitlines():
        m = re.match(r'^([0-9a-f]+) <(\S+)>:', l)
        if m:
            cur = m.group(2)
            continue
        m = re.match(r'^\s*([0-9a-f]+):\s+[0-9a-f]{8}\s+(\S+)', l)
        if m and cur:
            pc = int(m.group(1), 16)
            rng.setdefault(cur, [pc, pc])[1] = pc
            if LIKELY.match(m.group(2)):
                lik[cur] += 1
    return lik, rng
def mispredicts(f, rng):
    iv = sorted((a, b, n) for n, (a, b) in rng.items())
    starts = [a for a, _, _ in iv]
    c = collections.Counter()
    for l in open(f):
        pc, _, n = l.strip().partition(',')
        pc = int(pc.split(':')[0], 16) & 0xffffffff
        i = bisect.bisect_right(starts, pc) - 1
        if i >= 0 and pc <= iv[i][1]:
            c[iv[i][2]] += int(n)
    return c
def counts(root):
    """per-function static branch-likely and dynamic mispredict counts, (swp, noswp)"""
    ls, rs = funcs(root + '/harness/tsvc_swp.elf')
    ln, rn = funcs(root + '/harness/tsvc_noswp.elf')
    ms = mispredicts(root + '/results/branch_mispredicts_swp.txt', rs)
    mn = mispredicts(root + '/results/branch_mispredicts_noswp.txt', rn)
    return ls, ln, ms, mn

def main(root):
    ls, ln, ms, mn = counts(root)
    rows = []
    for l in open(root + '/results/ipc_table.txt'):
        p = l.split()
        if len(p) == 11 and p[4] == '|' and p[0] != 'kern':
            rows.append(p)
    for title, keep in (('SWP slower (cycles s/n >= 1.04)', lambda r: float(r[9]) >= 1.04),
                        ('SWP faster (cycles s/n <= 0.92)', lambda r: float(r[9]) <= 0.92)):
        print('----', title)
        for p in filter(keep, rows):
            f = p[0] + '_'
            print('%-6s cyc s/n %s ins s/n %s ipc %s->%s  likely s/n %2d/%2d  mispred s/n %d/%d' %
                  (p[0], p[9], p[10], p[3], p[7], ls[f], ln[f], ms[f], mn[f]))

if __name__ == '__main__':
    main(sys.argv[1])
