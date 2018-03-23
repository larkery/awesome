local awful = require("awful")
local xtags = require("xtags")
local capi = {screen = screen}

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

local send = require("send")

function util.rename_tag ()
   local screen = awful.screen.focused()
   local tag = screen.selected_tag
   awful.prompt.run {
      prompt = "<b>Tag: </b>",
      textbox = screen.prompt.widget,
      hooks = {
         {{}, 'Return', function (t) tag.name = t end},
         {{"Mod4"}, 'Return', function (t) xtags.named(t):greedy_view() end},
         {{"Shift"}, 'Return',
            function (t)
               local tag = xtags.named(t)
               client.focus:move_to_tag(tag)
               send.target = tag
            end
         }
      }
   }
end

function util.shift_new_tag ()
   client.focus:move_to_tag(send.to())
end

function util.rotate_screens ()
   local n = capi.screen:count()
   for i=1,n-1 do
      xtags.swap_screens(capi.screen[i], capi.screen[i+1])
   end
end

function util.prev_tag ()
   local cur = awful.screen.focused().selected_tag.xtag_index
   cur = cur - 1
   if cur == 0 then
      cur = #xtags.all_tags
   end
   xtags.nth(cur):greedy_view()
end

function util.next_tag ()
   local cur = awful.screen.focused().selected_tag.xtag_index
   cur = cur + 1
   if cur > #xtags.all_tags then
      cur = 1
   end
   xtags.nth(cur):greedy_view()
end

function util.go_urgent ()
   awful.client.urgent.jumpto(true)
end

function util.go_empty_tag ()
   local screen = awful.screen.focused()
   awful.prompt.run {
      prompt = "<b>Go tag: </b>",
      textbox = screen.prompt.widget,
      hooks = {
         {{}, 'Return', function (t) xtags.named(t):greedy_view() end}
      }
   }
end

function util.client_menu()
   local m = awful.menu.clients(
      { theme = {width = 500, height = 24} },
      nil,
      function (c)
         return not(c:isvisible())
      end
   )
end

return util
