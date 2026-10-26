#!/bin/sh
# compile-only: MIPSpro -S for each kernel source x target (-S ignores -o: rename the .s)
cd /usr/tmp/swp
mkdir -p out
for t in r10000 r8000 r4000; do
  case $t in r4000) isa=-mips3;; *) isa=-mips4;; esac
  F="-n32 $isa -$t -O3"
  echo "=== $t lfk.f";    f77 $F -S lfk.f          > out/lfk_f_$t.log 2>&1;  echo "rc=$?"; mv lfk.s out/lfk_f_$t.s
  echo "=== $t loops.f";  f77 $F -S tsvc_f/loops.f > out/tsvc_f_$t.log 2>&1; echo "rc=$?"; mv loops.s out/tsvc_f_$t.s
  echo "=== $t kernel.c"; cc $F -S lfk_c/kernel.c  > out/lfk_c_$t.log 2>&1;  echo "rc=$?"; mv kernel.s out/lfk_c_$t.s
  echo "=== $t tsvc.c";   cc $F -S -Itsvc2/src tsvc2/src/tsvc.c > out/tsvc_c_$t.log 2>&1; echo "rc=$?"; mv tsvc.s out/tsvc_c_$t.s
done
ls -l out
echo BUILD_DONE
