# rgbpi commands

## HAL commands

#### HAL.[command]

|Command|Arguments|Description|
|-|-|-|
|`set_pixel`|strip, pixel, #WWRRGGBB or #RRGGBB|sets a specific pixel on strip to specified color|
|`set_pixel`|strip, pixel, W, R, G, B|sets a specific pixel on strip to specified color|
|`set_pixel`|strip, pixel, R, G, B|sets a specific pixel on strip to specified color|
|-|-|-|
|`fill_strip`|strip, #WWRRGGBB or #RRGGBB|sets the strip to specified color|
|`fill_strip`|strip, W, R, G, B|sets the strip to specified color|
|`fill_strip`|strip, R, G, B|sets the strip to specified color|
|-|-|-|
|`fill_rainbow`|strip, hue_offset|fills a strip with a rainbow starting with the given hue_offset|
|-|-|-|
|`fill_hue`|strip, #HHSSVV|fills a strip with the specified hsv color|
|-|-|-|
|`fill_hue`|strip, hue_offset|fills a strip with the hue where hue put in #HHFFFF|
|-|-|-|
|`strip_off`|strip|sets the strip to full black|
|-|-|-|
|`render`|N/A|renders the current frame buffer|
|-|-|-|
|`hsv_to_rgb`|#HHSSVV|returns the given color back in #RRGGBB|
|-|-|-|

## RGB commands

#### RGB.[command]

|Command|Arguments|Description|
|-|-|-|
|`rainbow`|N/A|turns the addressable rainbow mode on|
|-|-|-|
|`rainbow_colid`|N/A|turns the solid rainbow mode on|
|-|-|-|
|`off`|N/A|turns any animations off|
|-|-|-|
