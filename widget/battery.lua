local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

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
   arc.start_angle = -math.pi/2

   local update = function (state)
      if #state > 0 then
         local val = tonumber(state[1].perc)
         if state[1].state == "Charging" then
            txt:set_markup("↑")
         else
            txt:set_markup("☇")
         end

         arc.values = {100 - tonumber(state[1].perc),
                       tonumber(state[1].perc)}

         if val < 15 then
            arc.colors = {"#000000", "#ff8c00"}
         elseif val < 60 then
            arc.colors = {"#000000", "#ffd700"}
         elseif val < 80 then
            arc.colors = {"#000000", "#7fff00"}
         else
            arc.colors = {"#000000", "#00fa9a"}
         end
      end
   end

   batwid.acpi(update)

   local timer = gears.timer {timeout = 10}

   timer:connect_signal("timeout", function () batwid.acpi(update) end)
   timer:start()

   return arc
end

return batwid
