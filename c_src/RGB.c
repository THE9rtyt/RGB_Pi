//I DON'T KNOW WHAT I'M DOING

#include <limits.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <err.h>
#include <stdio.h>
#include <unistd.h>

//un comment for debug messages
#define DEBUG

#include "rpi_ws281x/ws2811.h"
#include "port_interface.h"

/*
using blinkchain as a reference I have reversed engineered the I/O 
between C and Elixir :poggies:

args:
1 - dma channel
2 - strip 1 pin
3 - strip 1 length
4 - strip 2 pin
5 - strip 3 length
*/
int main(int argc, char *argv[]) {
  debug("starting main");
  debug("dma channel: %d", atoi(argv[1]));
  debug("strip1 pin: %d", strtol(argv[3], NULL, 10));
  debug("strip1 length: %d", atoi(argv[3]));
  debug("strip2 pin: %d", strtol(argv[5], NULL, 10));
  debug("strip2 length: %d", atoi(argv[5]));

  ws2811_return_t ret;

  ws2811_t ledstring = {
      .freq = WS2811_TARGET_FREQ,
      .dmanum = atoi(argv[1]),
      .channel = {
          [0] = {
              .gpionum = atoi(argv[2]),
              .invert = 0,
              .count = strtol(argv[3], NULL, 10),
              .strip_type = WS2811_STRIP_RGB,
              .brightness = 255,
          },
          [1] = {
              .gpionum = atoi(argv[4]),
              .invert = 0,
              .count = strtol(argv[5], NULL, 10),
              .strip_type = WS2811_STRIP_RGB,
              .brightness = 255,
          },
      },
  };

  if ((ret = ws2811_init(&ledstring)) != WS2811_SUCCESS) {
      reply_error("ws2811_init failed: %s\n", ws2811_get_return_t_str(ret));
      exit(ret);
  }

  char buffer[16];
  for (;;) {
    buffer[0] = '\0';
    if (scanf("%15s", buffer) == 0 || strlen(buffer) == 0) {
      if (feof(stdin)) {
        debug("EOF");
        ws2811_fini(&ledstring);
        exit(EXIT_SUCCESS);
      } else {
        ws2811_fini(&ledstring);
        errx(EXIT_FAILURE, "read error");
      }
    }

    if (!strcasecmp(buffer, "hello")) {
      reply_ok_payload("world");
    } else {
      reply_error("unknown command: %s", buffer);
    }

    // 15 FPS
    usleep(1000000 / 15);
  }
}