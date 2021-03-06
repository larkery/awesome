local gears = require("gears")
local awful = require("awful")
local util = require("util")
local xtags = require("xtags")

local restore_float = require("savefloats")

local cyclefocus = require("cyclefocus")

cyclefocus.cycle_filters = {}

local M = "Mod4"
local C = "Control"
local A = "Mod1"
local S = "Shift"

local keys = { M = M, C = C , A = A}
local key = awful.key

function keys:define_global()
   local ks = gears.table.join(
      key({M, C}, "r", awesome.restart, {description = "restart awesome", group = "session"}),
      key({M},    "a", util.unminimize),
      key({M},    "q", util.power_menu),

      key({M},    "y", function() cyclefocus.cycle({show_clients=false, focus_clients=false, modifier="Super_L", cycle_filters = {cyclefocus.filters.same_screen, cyclefocus.filters.common_tag, function(c, source_c) return c.minimized end}, keys = {"y", "u"}}) end),

      key({M},    "i", function() cyclefocus.cycle({show_clients=false, focus_clients=false, modifier="Super_L", cycle_filters = {}, keys = {"i", "u"}}) end),

      key({M}, "h", util.narrow_master, {description = "narrow master", group = "layout"}),
      key({M}, "l", util.widen_master, {description = "widen master", group = "layout"}),
      key({M}, "x", util.run, {description = "prompt", group="spawn"}),
      key({M}, "e", util.spawn("emacsclient -c -n"), {description = "emacsclient", group="spawn"}),
      key({M}, "w", util.spawn("firefox"), {description = "firefox", group="spawn"}),

      key({M},   "n", util.focus_next, {description = "focus next", group = "window"}),
      key({M},   "p", util.focus_prev, {description = "focus prev", group = "window"}),
      key({M,S}, "n", util.swap_next, {description = "swap next", group = "window"}),
      key({M,S}, "p", util.swap_prev, {description = "swap prev", group = "window"}),
      key({M},   "o", util.next_screen, {description = "focus next", group = "screen"}),
      key({M,A}, "o", util.rotate_screens, {description = "rotate screens around", group="screen"}),
      key({M},   "space", util.next_layout, {description = "focus next", group = "screen"}),
      key({M,S}, "space", util.prev_layout, {description = "focus next", group = "screen"}),
      key({M},    ",", util.fewer_masters),
      key({M},    ".", util.more_masters),

      key({M, A},  ",", util.fewer_cols),
      key({M, A},  ".", util.more_cols),
      key({M, A},  "p", util.prev_tag),
      key({M, A},  "n", util.next_tag),

      key({M},     "u", util.go_urgent),

      key({M, A},  "k", function () awful.screen.focused().selected_tag:destroy() end),

      key({}, "XF86MonBrightnessDown", util.brightness(-10)),
      key({}, "XF86MonBrightnessUp", util.brightness(10)),
      key({}, "XF86Launch1", util.exec("touchpad")),
      key({}, "XF86AudioRaiseVolume", util.volume(10)),
      key({}, "XF86AudioLowerVolume", util.volume(-10)),
      key({}, "XF86AudioMute", util.mute),

      key({M}, "'", util.rename_tag),
      key({M}, "=", util.go_empty_tag),

      key({M, S}, "Return", util.spawn("urxvt"), {description = "terminal", group = "spawn"}),

      key({M, S}, "/", util.exec("notmuch new"))
   )

   for i = 1, 9 do
      local code = "#" .. (i+9)
      ks = gears.table.join(
         ks,
         key({M},    code, function () xtags.nth(i):greedy_view() end, {description = "view " .. i, group = "tags"}),
         key({M, S}, code, function () awful.client.movetotag(xtags.nth(i)) end, {description = "view " .. i, group = "tags"})
      )
   end

   return ks
end

function keys:define_client()
   return gears.table.join(
      key({M}, "k",     util.kill, {description = "close", group="client"}),
      key({M}, "t",
         function(c)
            local restored = restore_float(c)
            awful.client.floating.toggle(c)
            if not(restored) then
               local margin = 20
               local geom = c:geometry()
               geom.x = geom.x+margin
               geom.y = geom.y+margin
               geom.width = math.max(margin, geom.width - (2*margin))
               geom.height = math.max(geom.height - (2*margin), margin)
               c:geometry(geom)
            end
            c.ontop = c.floating
         end
         , {description = "toggle floating", group="client"}),
      key({M}, "z",     util.minimize, {description = "minimize", group="client"}),
      key({M,S}, "o", util.shift_next_screen, {description = "-> next screen", group = "window"}),

      key({M}, "c", function(c) c.transparent = not c.transparent end),

      key({M}, "f", util.full_toggle, {description = "fullscreen", group="window"}),
      key({M}, "m", util.max_toggle, {description = "maximize", group="window"}),

      key({M}, "Return", function(c) c:swap(awful.client.getmaster()) end, {description="swap master", group="client"})
   )
end

return keys
