/* Reads r9999 ooo_core --pipelog dumps; build against r9999/pipeline_record.hh:
 *   g++ -O2 -std=c++17 -I<r9999> dumprec.cc -lboost_serialization -o dumprec */
/* findpc -i dump.pipe -p <hex pc> -n <occurrence>: record index (1-based, gen_html --start)
 * of the n-th retired record at pc. */
#include <iostream>
#include <cstdlib>
#include "pipeline_record.hh"
int main(int argc, char *argv[]) {
  pipeline_reader r;
  r.read(argv[1]);
  uint64_t pc = strtoull(argv[2], nullptr, 16);
  int n = atoi(argv[3]), seen = 0;
  size_t cnt = 0;
  for(auto &rec : r.get_records()) {
    ++cnt;
    if((rec.pc & 0xffffffffUL) == pc) {
      if(++seen == n) {
        std::cout << cnt << " fetch " << rec.fetch_cycle << " retire " << rec.retire_cycle << "\n";
        return 0;
      }
    }
  }
  std::cout << "seen " << seen << "\n";
  return 1;
}
