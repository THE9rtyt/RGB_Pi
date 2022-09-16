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

void set_pixel(ws2811_channel_t *channels) {
  uint8_t strip;
  uint16_t pixel;
  ws2811_led_t color;
  char nl;
  if (scanf("%hhu %hu %x%c", &strip, &pixel, &color, &nl) != 4 || nl != '\n') {
    reply_error("Argument error");
    return;
  };
  
  debug("setting strip: %d pixel: %d color: 0x%08x", strip, pixel, color);

  channels[strip].leds[pixel] = color;
  reply_ok();
}

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

  ws2811_return_t ret;

  ws2811_t ledstring = {
      .freq = WS2811_TARGET_FREQ,
      .dmanum = atoi(argv[1]),
      .channel = {
          [0] = {
              .gpionum = atoi(argv[2]),
              .invert = 0,
              .count = atoi(argv[3]),
              .strip_type = WS2811_STRIP_RGB,
              .brightness = 255,
          },
          [1] = {
              .gpionum = atoi(argv[4]),
              .invert = 0,
              .count = atoi(argv[5]),
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

    if (!strcasecmp(buffer, "set_pixel")) {
      set_pixel(ledstring.channel);
    } else if (!strcasecmp(buffer, "render")) {
      ws2811_return_t result = ws2811_render(&ledstring);
      if (result != WS2811_SUCCESS)
        errx(EXIT_FAILURE, "ws2811_render failed: %d (%s)", result, ws2811_get_return_t_str(result));
      reply_ok();

    } else {
      reply_error("unknown command: %s", buffer);
    }
  }
}