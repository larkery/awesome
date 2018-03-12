local awful = require("awful")

local util = {}

function util.next_layout () awful.layout.inc(1) end
function util.prev_layout () awful.layout.inc(-1) end

function util.minimize (c)
   if c == client.focus then
      c.minimized = true
   else
      c.minimized = false
      client.focus = c
      c:raise()
   end
end

function util.focus_prev () awful.client.focus.byidx(-1) end
function util.focus_next () awful.client.focus.byidx(1) end
function util.swap_prev  () awful.client.swap.byidx(-1) end
function util.swap_next  () awful.client.swap.byidx(1) end

function util.spawn (cmd)
   return function () awful.spawn(cmd) end
end

function util.exec (cmd)
   return function () awful.spawn(cmd, false) end
end

function util.widen_master () awful.tag.incmwfact(0.05) end
function util.narrow_master () awful.tag.incmwfact(-0.05) end

function util.run () awful.screen.focused().prompt:run() end

function util.next_screen () awful.screen.focus_relative( 1) end
function util.shift_next_screen (c) c:move_to_screen() end

function util.max_toggle (c)
   c.maximized = not c.maximized
end

function util.full_toggle (c) c.fullscreen = not c.fullscreen end

function util.fewer_masters () awful.tag.incnmaster(-1, null, true) end
function util.more_masters () awful.tag.incnmaster(1, null, true) end
function util.fewer_cols () awful.tag.incncol(-1, null, true) end
function util.more_cols () awful.tag.incncol(1, null, true) end

function util.kill (c) c:kill() end

function util.brightness (delta)
   if delta > 0 then
      return util.exec("xbacklight -inc " .. delta)
   else
      return util.exec("xbacklight -dec " .. -delta)
   end
end

function util.volume (delta)
   if delta > 0 then
      return util.exec("pamixer -i " .. delta)
   else
      return util.exec("pamixer -d " .. -delta)
   end
end

util.mute = util.exec("pamixer -t")

return util
