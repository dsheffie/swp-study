#!/usr/bin/env python3
"""compare_runs.py A.log B.log: per-kernel cycles (CP0 Count around the timed loop)
and checksum agreement between two TSVC runs (e.g. MIPSpro SWP on vs off)."""
import math, re, sys
def load(f):
    d = {}
    for l in open(f):
        m = re.match(r'^(\S+)\s+n=\d+ iters=(\d+) count=(\d+) sum=\S+ \[(0x[0-9a-f]+)\]', l)
        if m:
            d[m.group(1)] = (int(m.group(2)), int(m.group(3)), m.group(4))
    return d
a, b = load(sys.argv[1]), load(sys.argv[2])
ks = [k for k in a if k in b]
mism = [k for k in ks if a[k][2] != b[k][2]]
print('kernels %d; checksum differs in %d: %s' % (len(ks), len(mism), ' '.join(mism)))
r = sorted((b[k][1] / a[k][1], k) for k in ks)
gm = math.exp(sum(math.log(x) for x, _ in r) / len(r))
print('geomean B/A cycles %.3f  (>1: A faster)   total A %d  B %d' % (gm, sum(a[k][1] for k in ks), sum(b[k][1] for k in ks)))
print('A wins most:', ', '.join('%s %.2fx' % (k, x) for x, k in r[::-1][:10]))
print('B wins most:', ', '.join('%s %.2fx' % (k, 1 / x) for x, k in r[:10]))
within = sum(1 for x, _ in r if abs(x - 1) < 0.03)
print('within 3%%: %d / %d' % (within, len(r)))
