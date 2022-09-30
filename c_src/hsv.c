#include "hsv.h"

ws2811_led_t hsv_to_rgb(HSV hsv) {
  uint8_t hue = ((hsv >> 16) & 0xFF);
  uint8_t sat = ((hsv >> 8) & 0xFF);
  uint8_t val = ((hsv) & 0xFF);


  uint8_t invsat = 255 - sat;
  uint8_t brightness_floor = (val * invsat) / 255;

  uint8_t color_amplitude = val - brightness_floor;

  uint8_t section = hue / THIRD;//0..2

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