#ifndef HSV_H
#define HSV_H


#include <stdint.h>

#include "rpi_ws281x/ws2811.h"
#include "RGB_types.h"

#define THIRD 0x56

ws2811_led_t hsv_to_rgb(HSV hsv);

#endif
