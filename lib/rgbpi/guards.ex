defmodule RGBPi.Guards do
  defguard is_strip(s) when 
    s in 0..1
  defguard is_rgb(r,g,b) when 
    r in 0..255 and g in 0..255 and b in 0..255
  defguard is_wrgb(w,r,g,b) when 
    w in 0..255 and r in 0..255 and g in 0..255 and b in 0..255 

end