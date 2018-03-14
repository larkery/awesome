local gears = require("gears")
local color = { }

function color.rgba_parse (str)
   local r,g,b,a = gears.color.parse_color(str)
   return {r=r,g=g,b=b,a=a or 1}
end

function color.rgba_format (rgba)
   if rgba.a == 1 then
      return string.format("#%02x%02x%02x",
                           rgba.r*255, rgba.g*255, rgba.b*255)
   else
      return string.format("#%02x%02x%02x%02x",
                           rgba.r*255, rgba.g*255, rgba.b*255,
                           rgba.a*255)
   end
end

function color.rgba_to_hsl (rgb)
   local r, g, b = rgb.r, rgb.g, rgb.b

   local max, min = math.max(r, g, b), math.min(r, g, b)
   local h, s, l

   l = (max + min) / 2

   if max == min then
      h, s = 0, 0 -- achromatic
   else
      local d = max - min

      if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
      if max == r then
         h = (g - b) / d
         if g < b then h = h + 6 end
      elseif max == g then h = (b - r) / d + 2
      elseif max == b then h = (r - g) / d + 4
      end
      h = h / 6
   end

   return {h = h, s = s, l = l, a = rgb.a or 1}
end

function color.hsl_to_rgba (hsl)
   local h, s, l = hsl.h, hsl.s, hsl.l
   local r, g, b

   if s == 0 then
      r, g, b = l, l, l -- achromatic
   else
      function hue2rgb(p, q, t)
         if t < 0   then t = t + 1 end
         if t > 1   then t = t - 1 end
         if t < 1/6 then return p + (q - p) * 6 * t end
         if t < 1/2 then return q end
         if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
         return p
      end

      local q
      if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
      local p = 2 * l - q

      r = hue2rgb(p, q, h + 1/3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - 1/3)
   end

   return {r = r, g = g, b = b, a = hsl.a or 1}
end

function color.lighten (rgb_string, amount)
   local rgb = color.rgba_parse(rgb_string)
   local hsl = color.rgba_to_hsl(rgb)

   hsl.l = math.max(0, math.min(1, hsl.l + amount))

   return color.rgba_format(color.hsl_to_rgba(hsl))
end

return color
