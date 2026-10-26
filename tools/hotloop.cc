/* hotloop dump.pipe <lo hex> <hi hex>: find the hottest loop of the code in [lo, hi)
 * in an r9999 ooo_core --pipelog dump, and a steady-state window in it.
 *
 * The loop is the most frequent backward jump between consecutive retired records
 * that both lie in [lo, hi) (from = the back-edge delay slot, to = the loop head).
 * The window starts at the loop-head record of the middle trip and spans two trips.
 * Prints one line: head tail trips start focus_len (start is 1-based, = gen_html -s).
 *
 * build: g++ -O2 -std=c++17 -I<r9999> hotloop.cc -lboost_serialization -o hotloop */
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <vector>
#include "pipeline_record.hh"

int main(int argc, char *argv[]) {
  if(argc != 4) {
    fprintf(stderr, "usage: hotloop dump.pipe lo hi\n");
    return 1;
  }
  uint64_t lo = strtoull(argv[2], nullptr, 16), hi = strtoull(argv[3], nullptr, 16);
  pipeline_reader r;
  r.read(argv[1]);
  std::vector<uint64_t> pcs;
  for(auto &rec : r.get_records()) {
    pcs.push_back(rec.pc & 0xffffffffUL);
  }
  auto in = [&](uint64_t pc) { return pc >= lo && pc < hi; };
  std::map<std::pair<uint64_t, uint64_t>, uint64_t> edges;
  for(size_t i = 0; i + 1 < pcs.size(); i++) {
    if(in(pcs[i]) && in(pcs[i + 1]) && pcs[i + 1] < pcs[i]) {
      edges[{pcs[i], pcs[i + 1]}]++;
    }
  }
  if(edges.empty()) {
    printf("none\n");
    return 0;
  }
  std::pair<uint64_t, uint64_t> best;
  uint64_t n = 0;
  for(auto &e : edges) {
    if(e.second > n) {
      n = e.second;
      best = e.first;
    }
  }
  /* record indices (0-based) of each loop-head record reached by the back edge */
  std::vector<size_t> heads;
  for(size_t i = 0; i + 1 < pcs.size(); i++) {
    if(pcs[i] == best.first && pcs[i + 1] == best.second) {
      heads.push_back(i + 1);
    }
  }
  size_t m = heads.size() / 2;
  size_t start = heads[m];
  size_t len = (m + 2 < heads.size()) ? heads[m + 2] - start : 64;
  printf("%lx %lx %zu %zu %zu\n", (unsigned long)best.second, (unsigned long)best.first,
         heads.size(), start + 1, len);
  return 0;
}
