#!/bin/sh
# same matrix as build.sh with the software pipeliner off; waits for build.sh to finish first
cd /usr/tmp/swp
while ! grep -q BUILD_DONE build.out 2>/dev/null; do sleep 30; done
mkdir -p out
for t in r10000 r8000 r4000; do
  case $t in r4000) isa=-mips3;; *) isa=-mips4;; esac
  F="-n32 $isa -$t -O3 -SWP:=OFF"
  echo "=== $t lfk.f";    f77 $F -S lfk.f          > out/lfk_f_${t}_noswp.log 2>&1;  echo "rc=$?"; mv lfk.s out/lfk_f_${t}_noswp.s
  echo "=== $t loops.f";  f77 $F -S tsvc_f/loops.f > out/tsvc_f_${t}_noswp.log 2>&1; echo "rc=$?"; mv loops.s out/tsvc_f_${t}_noswp.s
  echo "=== $t kernel.c"; cc $F -S lfk_c/kernel.c  > out/lfk_c_${t}_noswp.log 2>&1;  echo "rc=$?"; mv kernel.s out/lfk_c_${t}_noswp.s
  echo "=== $t tsvc.c";   cc $F -S -Itsvc2/src tsvc2/src/tsvc.c > out/tsvc_c_${t}_noswp.log 2>&1; echo "rc=$?"; mv tsvc.s out/tsvc_c_${t}_noswp.s
done
ls -l out
echo NOSWP_DONE
