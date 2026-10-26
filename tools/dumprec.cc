/* Reads r9999 ooo_core --pipelog dumps; build against r9999/pipeline_record.hh:
 *   g++ -O2 -std=c++17 -I<r9999> dumprec.cc -lboost_serialization -o dumprec */
/* dumprec dump.pipe start len: F/A/C/R cycles per record, relative to the first fetch */
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "pipeline_record.hh"
int main(int argc, char *argv[]) {
  pipeline_reader r;
  r.read(argv[1]);
  size_t start = atol(argv[2]), len = atol(argv[3]), cnt = 0;
  int64_t base = -1;
  for(auto &rec : r.get_records()) {
    ++cnt;
    if(cnt < start) {
      continue;
    }
    if(cnt >= start + len) {
      break;
    }
    if(base < 0) {
      base = rec.fetch_cycle;
    }
    printf("%8lx  %-28s F%4ld A%4ld C%4ld R%4ld", (unsigned long)(rec.pc & 0xffffffffUL), rec.disasm.c_str(),
           (long)(rec.fetch_cycle - base), (long)(rec.alloc_cycle - base),
           (long)(rec.complete_cycle - base), (long)(rec.retire_cycle - base));
    for(const auto &e : rec.events) {
      printf("  %c%ld", (char)e.second, (long)(e.first - base));
    }
    printf("\n");
  }
  return 0;
}
