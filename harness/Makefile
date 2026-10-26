# tests/swp -- run MIPSpro-compiled (n32, R4000, SWP on/off) TSVC kernels bare-metal on r9999.
# obj/*.o come from MIPSpro 7.30 in the IRIX dev image (src/build_obj.sh); this Makefile
# only links them with the n32 shim.  KERNELS="s111 vpvtv" limits the driver (pipetrace).
CC      = mips-linux-gnu-gcc-14
CFLAGS  = -mabi=n32 -march=mips3 -EB -O2 -std=gnu17 -ffreestanding -fno-builtin -I. -I.
LDFLAGS = -mabi=n32 -EB -nostdlib -static -T link_n32.ld -Wl,--no-warn-mismatch
KERNELS ?=

all: tsvc_swp.elf tsvc_noswp.elf

tsvc_driver.c: gen_tsvc_driver.py src/mains.f
	python3 gen_tsvc_driver.py src/mains.f $(KERNELS) > $@

%.o: %.c swp_rt.h sim.h
	$(CC) $(CFLAGS) -c $< -o $@

crt0_n32.o: crt0_n32.S sim.h
	$(CC) $(CFLAGS) -c $< -o $@

# MIPSpro objects interleave local/global symbols (sh_info=0); GNU ld needs locals first
obj/%.fix.o: obj/%.o fix_irix_symtab.py
	python3 fix_irix_symtab.py $< $@

tsvc_%.elf: crt0_n32.o swp_rt.o tsvc_driver.o obj/tsvc_f_r4000_%.fix.o obj/tsvc_helpers_r4000.fix.o link_n32.ld
	$(CC) $(LDFLAGS) crt0_n32.o swp_rt.o tsvc_driver.o obj/tsvc_f_r4000_$*.fix.o obj/tsvc_helpers_r4000.fix.o -o $@

clean:
	rm -f *.o obj/*.fix.o tsvc_driver.c one_*_driver.c *.elf

.PHONY: all clean one
.PRECIOUS: tsvc_driver.c obj/%.fix.o

# make one K=s111 -> one_s111_swp.elf + one_s111_noswp.elf (a single kernel, for pipetraces)
one: crt0_n32.o swp_rt.o obj/tsvc_f_r4000_swp.fix.o obj/tsvc_f_r4000_noswp.fix.o obj/tsvc_helpers_r4000.fix.o
	python3 gen_tsvc_driver.py src/mains.f $(K) > one_$(K)_driver.c
	$(CC) $(CFLAGS) -c one_$(K)_driver.c -o one_$(K)_driver.o
	for v in swp noswp; do $(CC) $(LDFLAGS) crt0_n32.o swp_rt.o one_$(K)_driver.o obj/tsvc_f_r4000_$$v.fix.o obj/tsvc_helpers_r4000.fix.o -o one_$(K)_$$v.elf; done
