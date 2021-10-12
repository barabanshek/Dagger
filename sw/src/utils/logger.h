#pragma once

/***************************************************************************
 *   Copyright (C) 2008 by H-Store Project                                 *
 *   Brown University                                                      *
 *   Massachusetts Institute of Technology                                 *
 *   Yale University                                                       *
 *                                                                         *
 *   This software may be modified and distributed under the terms         *
 *   of the MIT license.  See the LICENSE file for details.                *
 *                                                                         *
 ***************************************************************************/

/**
 * @file logger.h
 * @brief Logging macros that can be optimized out
 * @author Hideaki, modified by Anuj (eRPC project) and Nikita
 */

#include <ctime>
#include <string>

namespace dagger {

// Log levels: higher means more verbose
#define FRPC_LOG_LEVEL_OFF 0
#define FRPC_LOG_LEVEL_ERROR 1
#define FRPC_LOG_LEVEL_WARN 2
#define FRPC_LOG_LEVEL_INFO 3
#define FRPC_LOG_LEVEL_FLOW 4

#define FRPC_LOG_DEFAULT_STREAM stdout

// If FRPC_LOG_LEVEL is not defined, default to the highest level
#ifndef FRPC_LOG_LEVEL
#define FRPC_LOG_LEVEL FRPC_LOG_LEVEL_INFO
#endif

static void output_log_header(int level);

#if FRPC_LOG_LEVEL >= FRPC_LOG_LEVEL_ERROR
#define FRPC_ERROR(...)                                             \
  output_log_header(FRPC_LOG_DEFAULT_STREAM, FRPC_LOG_LEVEL_ERROR); \
  fprintf(FRPC_LOG_DEFAULT_STREAM, __VA_ARGS__);                    \
  fflush(FRPC_LOG_DEFAULT_STREAM)
#else
#define FRPC_ERROR(...) ((void)0)
#endif

#if FRPC_LOG_LEVEL >= FRPC_LOG_LEVEL_WARN
#define FRPC_WARN(...)                                             \
  output_log_header(FRPC_LOG_DEFAULT_STREAM, FRPC_LOG_LEVEL_WARN); \
  fprintf(FRPC_LOG_DEFAULT_STREAM, __VA_ARGS__);                   \
  fflush(FRPC_LOG_DEFAULT_STREAM)
#else
#define FRPC_WARN(...) ((void)0)
#endif

#if FRPC_LOG_LEVEL >= FRPC_LOG_LEVEL_INFO
#define FRPC_INFO(...)                                             \
  output_log_header(FRPC_LOG_DEFAULT_STREAM, FRPC_LOG_LEVEL_INFO); \
  fprintf(FRPC_LOG_DEFAULT_STREAM, __VA_ARGS__);                   \
  fflush(FRPC_LOG_DEFAULT_STREAM)
#else
#define FRPC_INFO(...) ((void)0)
#endif

#if FRPC_LOG_LEVEL >= FRPC_LOG_LEVEL_FLOW
#define FRPC_FLOW(...)                                             \
  output_log_header(FRPC_LOG_DEFAULT_STREAM, FRPC_LOG_LEVEL_FLOW); \
  fprintf(FRPC_LOG_DEFAULT_STREAM, __VA_ARGS__);                   \
  fflush(FRPC_LOG_DEFAULT_STREAM)
#else
#define FRPC_FLOW(...) ((void)0)
#endif

/// Return decent-precision time formatted as seconds:microseconds
static std::string get_formatted_time() {
  struct timespec t;
  clock_gettime(CLOCK_REALTIME, &t);
  char buf[20];
  uint32_t seconds = t.tv_sec % 100;  // Rollover every 100 seconds
  uint32_t usec = t.tv_nsec / 1000;

  sprintf(buf, "%u:%06u", seconds, usec);
  return std::string(buf);
}

// Output log message header
static void output_log_header(FILE *stream, int level) {
  std::string formatted_time = get_formatted_time();

  const char *type;
  switch (level) {
    case FRPC_LOG_LEVEL_ERROR: type = "ERROR"; break;
    case FRPC_LOG_LEVEL_WARN: type = "WARNG"; break;
    case FRPC_LOG_LEVEL_INFO: type = "INFOR"; break;
    default: type = "UNKWN";
  }

  fprintf(stream, "%s %s: ", formatted_time.c_str(), type);
}

}  // namespace dagger
