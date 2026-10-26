#!/bin/bash
# trace_kernel.sh <kernel> <swp|noswp>: simulate one kernel on r9999 ooo_core with a pipelog,
# find its hot loop (tools/hotloop), write pipetraces/<k>_<v>{,_focus}.html and print a
# metadata row: kernel variant head tail trips start focus_len count.  The pipelog is deleted.
# Needs: R9999 (default ~/code/r9999) with ooo_core + gen_html built; `make one K=<k>` done.
set -e
k=$1; v=$2
ROOT=$(cd "$(dirname "$0")/.." && pwd)
R9999=${R9999:-$HOME/code/r9999}
W=${WORK:-/tmp/swp_trace}
mkdir -p "$W"
elf=$ROOT/harness/one_${k}_$v.elf
pipe=$W/${k}_$v.pipe
# ooo_core drops side logs (branch_info.txt, log.txt, ...) in its cwd: give each run its own
mkdir -p "$W/${k}_$v.d"
(cd "$W/${k}_$v.d" && "$R9999/ooo_core" -f "$elf" -m 37 -p "$pipe" > "$W/${k}_$v.log" 2>&1)
count=$(grep -oE "^$k +n=[0-9]+ iters=[0-9]+ count=[0-9]+" "$W/${k}_$v.log" | sed 's/.*count=//')
range=$(mips64-linux-gnuabi64-nm -n "$elf" | grep -A1 " ${k}_$" | awk '{print $1}' | tr '\n' ' ')
read head tail trips start len <<< "$("$ROOT/tools/hotloop" "$pipe" $range | tail -1)"
if [ "$head" != none ]; then
  "$R9999/gen_html" -i "$pipe" -o "$ROOT/pipetraces/${k}_${v}_focus.html" -s "$start" -l "$len" > /dev/null
  "$R9999/gen_html" -i "$pipe" -o "$ROOT/pipetraces/${k}_${v}.html" -s "$start" -l 420 > /dev/null
fi
rm -rf "$pipe" "$W/${k}_$v.d"
echo "$k $v $head $tail $trips $start $len $count"
