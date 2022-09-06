//I DON'T KNOW WHAT I'M DOING

#include <limits.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <err.h>
#include <stdio.h>

#include "rpi_ws281x/ws2811.h"
#include "port_interface.h"

//using blinkchain as a reference I have reversed engineered the I/O between C and Elixir :poggies:

int main() {
  char buffer[16];
  for (;;) {
  buffer[0] = '\0';
  if (scanf("%15s", buffer) == 0 || strlen(buffer) == 0) {
    if (feof(stdin)) {
      debug("EOF");
      exit(EXIT_SUCCESS);
    } else {
      errx(EXIT_FAILURE, "read error");
    }
  }

  if (strcasecmp(buffer, "hello") == 0) {
    reply_ok_payload("world");
  }
  }
}