/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at https://curl.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 * SPDX-License-Identifier: curl
 *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <curl/curl.h>

#define END_OF_LIST 0xffffff

const static int options[] = {
  CURLU_DEFAULT_PORT,
  CURLU_NO_DEFAULT_PORT,
  CURLU_DEFAULT_SCHEME,
  CURLU_NON_SUPPORT_SCHEME,
  CURLU_ALLOW_SPACE,
  CURLU_GUESS_SCHEME,
  CURLU_PATH_AS_IS,
  CURLU_DISALLOW_USER,
  END_OF_LIST
};

#define BUFSIZE (4096*9)

/*
 * Read URLs one by one from stdin.
 * Parse them with all listed option combinations
 */
int main(int argc, char **argv)
{
  int l, o, u;
  size_t count = 0;
  size_t ecount = 0; /* errors */
  struct timeval start;
  struct timeval end;
  time_t diff;
  long us;
  FILE *f;
  char buffer[BUFSIZE];

  gettimeofday(&start, NULL);

  while(fgets(buffer, sizeof(buffer), stdin)) {
    char *nl = strchr(buffer, '\n');
    if(nl) {
      CURLUcode ucode;
      *nl = 0;
      for(o = 0; options[o] != END_OF_LIST; o++) {
        CURLU *p = curl_url();
        ucode = curl_url_set(p, CURLUPART_URL, buffer, options[o]);
        curl_url_cleanup(p);
        count++;
        if(ucode) {
#if 0
          fprintf(stderr, "Failed [%u]: %s\n", (int)ucode, buffer);
#endif
          ecount++;
        }
      }
    }
  }
  gettimeofday(&end, NULL);
  diff = end.tv_sec-start.tv_sec;
  us = diff * 1000000 + end.tv_usec-start.tv_usec;
  printf("%d parsed URLs in %.1f secs, %.1f ns/URL, %.0f URLs/sec\n",
         count,
         (double)us/1000000.0,
         (double)us*1000/count, count / (us/1000000.0),
         ecount);
  printf("Errors: %zu (%.2f%%)\n", ecount, (double)ecount*100/count);
  return 0;
}
