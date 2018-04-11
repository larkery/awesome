local awful = require("awful")
local gears = require("gears")

local window = nil
local timer = gears.timer{ timeout = 0.5 }

function set_focus (c)
   c = c or awful.mouse.client_under_pointer()
   if not c then return false end
   if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c)
      and c.focusable
   then
      client.focus = c
   end
   if (awful.layout.get(c.screen) == awful.layout.suit.floating) then
      window = c
      timer:again()
   else
      window = nil
      c:raise()
   end
   return false
end

timer:connect_signal("timeout",
                     function ()
                        if window and client.focus == window then
                           window:raise()
                        end
                        timer:stop()
                     end
)

client.connect_signal("mouse::enter", set_focus)
client.connect_signal("mouse::leave",
                      function (c)
                         if window == c then
                            window = nil
                         end
                      end
                      )

-- this doesn't work, need another timer so the window's actually gone
--client.connect_signal("unmanage", function (c) set_focus() end)
client.connect_signal(
   "unmanage",
   function(c)
      gears.timer.start_new(0.1, set_focus)
   end
)
