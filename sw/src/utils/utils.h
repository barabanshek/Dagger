/**
 * @file utils.h
 * @brief Just utils.
 * @author Nikita Lazarev
 */
#ifndef _UTILS_H_
#define _UTILS_H_

namespace dagger {
namespace utils {
  // Perf counter
  static uint64_t rdtsc() {
    unsigned int lo, hi;
    __asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
    return ((uint64_t)hi << 32) | lo;
  }

}  // namespace utils

}  // namespace dagger

#endif
