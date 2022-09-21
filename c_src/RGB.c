//Main RGB program for RGBPi Hardware Abstraction Layer.
//does all of the communication and handling of the rpi_ws281x driver

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
#include "RGB_types.h"

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

void fill_strip(ws2811_channel_t *channels) {
  uint8_t strip;
  ws2811_led_t color;
  char nl;
  if (scanf("%hhu %x%c", &strip, &color, &nl) != 3 || nl != '\n') {
    reply_error("Argument error");
    return;
  };

  debug("filling strip: %d color: 0x%08x", strip, color);

  for (uint16_t pixel = 0; pixel < channels[strip].count; ++pixel) {
    channels[strip].leds[pixel] = color;
  };
  reply_ok();
}

#define THIRD 0x56

ws2811_led_t hsv_to_rgb(HSV hsv) {
  uint8_t hue = ((hsv >> 16) & 0xFF);
  uint8_t sat = ((hsv >> 8) & 0xFF);
  uint8_t val = ((hsv) & 0xFF);


  uint8_t invsat = 255 - sat;
  uint8_t brightness_floor = (val * invsat) / 255;

  uint8_t color_amplitude = val - brightness_floor;

  uint8_t section = hue / THIRD;

  uint8_t offset;
  //bug fix since I can't figure it out
  if (hue == 255) {
    offset = THIRD-1;
  } else {
    offset = hue % THIRD;
  }
  
  uint8_t rampup = offset;
  uint8_t rampdown = (THIRD - 1) - offset;

  // compute color-amplitude-scaled-down versions of rampup and rampdown
  uint8_t rampup_amp_adj   = (rampup   * color_amplitude) / (256 / 3);
  uint8_t rampdown_amp_adj = (rampdown * color_amplitude) / (256 / 3);

  // add brightness_floor offset to everything
  uint8_t rampup_adj_with_floor   = rampup_amp_adj   + brightness_floor;
  uint8_t rampdown_adj_with_floor = rampdown_amp_adj + brightness_floor;

  if( section ) {
    if( section == 1) {
      // section 1: 0x56..0xAA
      return((brightness_floor << 16) |
      (rampdown_adj_with_floor << 8) |
      (rampup_adj_with_floor))& 0xFFFFFFFF;
    } else {
      // section 2; 0xAB..0xFF
      return((rampup_adj_with_floor << 16) |
      (brightness_floor << 8) |
      (rampdown_adj_with_floor)) & 0xFFFFFFFF;
    }
  } else {
    // section 0: 0x00..0x55
    return((rampdown_adj_with_floor << 16) |
    (rampup_adj_with_floor << 8) |
    (brightness_floor)) & 0xFFFFFFFF;
  }
}

void hsvrgb() {
  ws2811_led_t color;
  char nl;
  if (scanf("%x%c", &color, &nl) != 2 || nl != '\n') {
    reply_error("Argument error");
    return;
  };

  reply_ok_payload("%x", hsv_to_rgb(color));
}

void fill_rainbow(ws2811_channel_t *channels) {
  uint8_t strip;
  uint8_t hue_offset;
  char nl;
  if (scanf("%hhu %hhu%c", &strip, &hue_offset, &nl) != 3 || nl != '\n') {
    reply_error("Argument error");
    return;
  };

  debug("filling rainbow strip: %d hue_offset: %d", strip, hue_offset);

  for (uint16_t pixel = 0; pixel < channels[strip].count; ++pixel) {
    channels[strip].leds[pixel] = hsv_to_rgb(hue_offset << 16 | 0xFFFF);
    ++hue_offset;
  };

  reply_ok();
}

void fill_hue(ws2811_channel_t *channels) {
  uint8_t strip;
  HSV hsvcolor;
  char nl;
  if (scanf("%hhu %x%c", &strip, &hsvcolor, &nl) != 3 || nl != '\n') {
    reply_error("Argument error");
    return;
  };

  debug("filling hue: %d hsvcolor: %x", strip, hsvcolor);

  ws2811_led_t color  = hsv_to_rgb(hsvcolor);

  for (uint16_t pixel = 0; pixel < channels[strip].count; ++pixel) {
    channels[strip].leds[pixel] = color;
  };

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

    if (!strcasecmp(buffer, "render")) {
      ws2811_return_t result = ws2811_render(&ledstring);
      if (result != WS2811_SUCCESS)
        errx(EXIT_FAILURE, "ws2811_render failed: %d (%s)", result, ws2811_get_return_t_str(result));
      reply_ok();
    } else if (!strcasecmp(buffer, "set_pixel")) {
      set_pixel(ledstring.channel);
    } else if (!strcasecmp(buffer, "fill_strip")) {
      fill_strip(ledstring.channel);
    } else if (!strcasecmp(buffer, "fill_rainbow")) {
      fill_rainbow(ledstring.channel);
    } else if (!strcasecmp(buffer, "fill_hue")) {
      fill_hue(ledstring.channel);
    } else if (!strcasecmp(buffer, "hsvrgb")) {
      hsvrgb();
    }else {
      reply_error("unknown command: %s", buffer);
    }
  }
}