#!/bin/sh
# R4000 (mips3) objects for running on r9999: TSVC + LFK (Fortran, C), SWP on/off
cd /usr/tmp/swp
mkdir -p obj
for sw in swp noswp; do
  F="-n32 -mips3 -r4000 -O3"; [ $sw = noswp ] && F="$F -SWP:=OFF"
  echo "=== $sw loops.f"; f77 $F -c tsvc_f/loops.f > obj/tsvc_f_$sw.log 2>&1; echo "rc=$?"; mv loops.o obj/tsvc_f_r4000_$sw.o
  echo "=== $sw lfk.f";   f77 $F -c lfk.f          > obj/lfk_f_$sw.log 2>&1;  echo "rc=$?"; mv lfk.o obj/lfk_f_r4000_$sw.o
  echo "=== $sw kernel.c"; cc $F -c lfk_c/kernel.c > obj/lfk_c_$sw.log 2>&1;  echo "rc=$?"; mv kernel.o obj/lfk_c_r4000_$sw.o
done
ls -l obj
echo OBJ_DONE
