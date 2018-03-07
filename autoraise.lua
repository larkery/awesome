local gears = require("gears")

local window = nil
local timer = gears.timer{ timeout = 0.2 }
timer:connect_signal("timeout",
                     function ()
                        if window and client.focus == window then
                           window:raise()
                        end
                        timer:stop()
                     end
)

client.connect_signal("mouse::enter",
                      function (c)
                         window = c
                         timer:again()
                      end
)

client.connect_signal("mouse::leave",
                      function (c)
                         if window == c then
                            window = nil
                         end
                      end
                      )
