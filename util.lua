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

function util.widen_master () awful.tag.incmwfact(0.05) end
function util.narrow_master () awful.tag.incmwfact(-0.05) end

function util.run () awful.screen.focused().prompt:run() end

function util.next_screen () awful.screen.focus_relative( 1) end
function util.shift_next_screen (c) c:move_to_screen() end

return util
