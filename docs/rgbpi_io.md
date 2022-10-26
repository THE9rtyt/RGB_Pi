# rgbpi commands

## HAL commands

### RGBPi.HAL.[command]\([Arguments])

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
|`fill_hue`|strip, hue_offset|fills a strip with the an hsv color of #[hue_offset]FFFF|
|-|-|-|
|`set_brightness`|strip, brightness|sets strip to brightness|
|-|-|-|
|`strip_off`|strip|sets the strip to full black|
|-|-|-|
|`render`|N/A|renders the current frame buffer|
|-|-|-|
|`hsv_to_rgb`|#HHSSVV|returns the given color back in #RRGGBB|
|-|-|-|

## Animation Servers

### start them with RGBPi.Animations.[Animation].startlink([Arguments])
### giving it strip 0/1 goto channel 0 or 1 and if you give it 2 it will run both strips
##### note: using option 2 for strip to run both assumes the strips are the same length.

|Command|Arguments|Description|
|-|-|-|
|`RainbowAddressable`|strip|runs the Addressable Rainbow server on set strip(s)|
|-|-|-|
|`RainbowSolid`|strip|runs the Solid Rainbow Server on set strip(s)|
|-|-|-|
|`Sparklez`|strip|runs the Sparklez Server on set strip(s)|
|-|-|-|
