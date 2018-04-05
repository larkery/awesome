local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local color = require("color")

local batwid = {}

function batwid.acpi (cb)
   awful.spawn.easy_async(
      "acpi",
      function (stdout, stderr, er, ec)
         local out = {}
         for line in stdout:gmatch('[^\r\n]+') do
            local n, state, perc = string.match(
               line,
               "Battery (%d+): (%D+), (%d+)%%"
            )
            if n then
               table.insert(out, {n = n, state = state, perc = perc, time = time})
            end
         end
         cb(out)
      end
   )
end

function batwid.create ()
   local txt = wibox.widget { align='center',
                              valign = 'center',
                              widget = wibox.widget.textbox }
   local arc = wibox.container.arcchart(txt)
   arc.max_value = 100
   arc.thickness = 3
   arc.padding = 1
   arc.start_angle = -math.pi / 2

   local ctable = {}
   for val=0,100 do
      local crgb = {r = math.sqrt((100 - val) / 100),
                    g = math.sqrt(val / 100), b = 0,
                    a=1}
      local c = color.rgba_format(crgb)
      ctable[val] = c
   end

   local label_map = {}
   label_map["Charging"] = "C"
   label_map["Unknown"] = "C"
   label_map["Full"] = "•"
   label_map["Discharging"] = "D"

   local update = function (state)
      if #state > 0 then
         local val = tonumber(state[1].perc)
         local lbl = label_map[state[1].state] or "-"
         txt:set_markup("<b><span color=\"white\">" .. lbl .. "</span></b>")

         local values = {100 - val, val}
         local colors = {"#000000", ctable[math.floor(val)]}

         arc.values = values
         arc.colors = colors

      end
   end

   batwid.acpi(update)

   local timer = gears.timer {timeout = 10}

   timer:connect_signal("timeout", function () batwid.acpi(update) end)
   timer:start()

   return arc
end

return batwid
