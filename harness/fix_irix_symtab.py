#!/usr/bin/env python3
"""fix_irix_symtab.py IN.o OUT.o

MIPSpro (IRIX) relocatable objects interleave LOCAL and GLOBAL symbols and leave
.symtab sh_info = 0.  The ELF spec (and GNU ld) require all locals first with
sh_info = index of the first non-local.  Reorder the symbol table (stable: locals
then globals), rewrite the symbol index in every REL/RELA entry that uses it, and
fix sh_info.  ELF32 big-endian only (n32).
"""
import struct
import sys

SHT_SYMTAB, SHT_RELA, SHT_REL = 2, 4, 9

data = bytearray(open(sys.argv[1], 'rb').read())
assert data[:4] == b'\x7fELF' and data[4] == 1 and data[5] == 2, 'ELF32 big-endian only'
e_shoff, = struct.unpack_from('>I', data, 0x20)
e_shentsize, e_shnum = struct.unpack_from('>HH', data, 0x2e)

def shdr(i):
    off = e_shoff + i * e_shentsize
    return off, list(struct.unpack_from('>10I', data, off))

secs = [shdr(i) for i in range(e_shnum)]
symidx = [i for i, (_, h) in enumerate(secs) if h[1] == SHT_SYMTAB]
assert len(symidx) == 1
st_off, st = secs[symidx[0]]
sym_base, sym_size, sym_ent = st[4], st[5], st[9]
nsym = sym_size // sym_ent
syms = [bytes(data[sym_base + k * sym_ent: sym_base + (k + 1) * sym_ent]) for k in range(nsym)]
local = [k for k in range(nsym) if (syms[k][12] >> 4) == 0]
nonlocal_ = [k for k in range(nsym) if (syms[k][12] >> 4) != 0]
order = local + nonlocal_
newidx = {old: new for new, old in enumerate(order)}
for new, old in enumerate(order):
    data[sym_base + new * sym_ent: sym_base + (new + 1) * sym_ent] = syms[old]
st[7] = len(local)                                  # sh_info = first non-local
struct.pack_into('>10I', data, st_off, *st)

nrel = 0
for off, h in secs:
    if h[1] not in (SHT_REL, SHT_RELA) or h[6] != symidx[0]:
        continue
    ent = h[9]
    for k in range(h[5] // ent):
        p = h[4] + k * ent + 4
        info, = struct.unpack_from('>I', data, p)
        struct.pack_into('>I', data, p, (newidx[info >> 8] << 8) | (info & 0xff))
        nrel += 1

open(sys.argv[2], 'wb').write(data)
print('%s: %d symbols (%d local), %d relocations remapped' % (sys.argv[2], nsym, len(local), nrel))
