local gears = require("gears")
local awful = require("awful")
local util = require("util")

local M = "Mod4"
local C = "Control"
local A = "Mod1"
local S = "Shift"

local keys = { M = M, C = C , A = A}
local key = awful.key

function keys:define_global(tags)
   local ks = gears.table.join(
      key({M, C}, "r", awesome.restart, {description = "restart awesome", group = "session"}),

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
      key({M,S}, "o", util.next_screen, {description = "-> next screen", group = "window"}),

      key({M, S}, "Return", util.spawn("urxvt"), {description = "terminal", group = "spawn"})
   )

   for i = 1, 9 do
      local code = "#" .. (i+9)
      ks = gears.table.join(
         ks,
         key({M},    code, function () tags:view(i) end, {description = "view " .. i, group = "tags"}),
         key({M, S}, code, function () tags:shift_focused(i) end, {description = "view " .. i, group = "tags"})
      )
   end

   return ks
end

function keys:define_client()
   return gears.table.join(
      key({M}, "k",     function(c) c:kill() end, {description = "close", group="client"}),
      key({M}, "space", awful.client.floating.toggle, {description = "toggle floating", group="client"}),
      key({M}, "z",     util.minimize, {description = "minimize", group="client"}),
      key({M}, "Return", function(c) c:swap(awful.client.getmaster()) end, {description="swap master", group="client"})
   )
end

return keys



-- -- }}}
-- -- {{{ Key bindings

-- gears.table.join(
--     awful.key({ sup,           }, "f",
--         function (c)
--             c.fullscreen = not c.fullscreen
--             c:raise()
--         end,
--         {description = "toggle fullscreen", group = "client"}),
--     awful.key({ sup,    }, "k",      function (c) c:kill()                         end,
--               {description = "close", group = "client"}),
--     awful.key({ sup, "Control" }, "space",  awful.client.floating.toggle                     ,
--               {description = "toggle floating", group = "client"}),
--     awful.key({ sup, }, "Return", function (c) c:swap(awful.client.getmaster()) end,
--               {description = "move to master", group = "client"}),
--     awful.key({ sup,           }, "o",      function (c) c:move_to_screen()               end,
--               {description = "move to screen", group = "client"}),
--     awful.key({ sup,           }, "t",      function (c) c.ontop = not c.ontop            end,
--               {description = "toggle keep on top", group = "client"}),
--     awful.key({ sup,           }, "z",
--         function (c)
--             -- The client currently has the input focus, so it cannot be
--             -- minimized, since minimized clients can't have the focus.
--             c.minimized = true
--         end ,
--         {description = "minimize", group = "client"}),
--     awful.key({ sup,           }, "m",
--         function (c)
--             c.maximized = not c.maximized
--             c:raise()
--         end ,
--         {description = "(un)maximize", group = "client"}),
--     awful.key({ sup, "Control" }, "m",
--         function (c)
--             c.maximized_vertical = not c.maximized_vertical
--             c:raise()
--         end ,
--         {description = "(un)maximize vertically", group = "client"}),
--     awful.key({ sup, "Shift"   }, "m",
--         function (c)
--             c.maximized_horizontal = not c.maximized_horizontal
--             c:raise()
--         end ,
--         {description = "(un)maximize horizontally", group = "client"})
-- )
-- globalkeys = gears.table.join(
--     awful.key({ sup, shift     }, "/",      hotkeys_popup.show_help,
--               {description="show help", group="awesome"}),
--     awful.key({ sup,           }, "Left",   awful.tag.viewprev,
--               {description = "view previous", group = "tag"}),
--     awful.key({ sup,           }, "Right",  awful.tag.viewnext,
--               {description = "view next", group = "tag"}),
--     awful.key({ sup,           }, "Escape", awful.tag.history.restore,
--               {description = "go back", group = "tag"}),

--     awful.key({ sup,           }, "n",
--         function ()
--             awful.client.focus.byidx( 1)
--         end,
--         {description = "focus next by index", group = "client"}
--     ),
--     awful.key({ sup,           }, "p",
--         function ()
--             awful.client.focus.byidx(-1)
--         end,
--         {description = "focus previous by index", group = "client"}
--     ),
--     awful.key({ sup,           }, "w", function () awful.spawn("firefox") end,
--               {description = "run firefox", group = "awesome"}),
--     awful.key({ sup,           }, "e", function () awful.spawn("emacsclient -c -n") end,
--        {description = "run firefox", group = "awesome"}),

--     awful.key({ sup }, "j",
--        function ()
--           awful.prompt.run {
--              prompt = "<b>Tag: </b>",
--              textbox = mouse.screen.prompt.widget,
--              hooks = {
--                 {{}, 'Return',
--                    function (t)
--                       tags:add({name = t, screen = mouse.screen.index}):view_only()
--                    end
--                 },
--              }
--           }
--        end
--     ),

--     -- Layout manipulation
--     awful.key({ sup, "Shift"   }, "n", function () awful.client.swap.byidx(  1)    end,
--               {description = "swap with next client by index", group = "client"}),
--     awful.key({ sup, "Shift"   }, "p", function () awful.client.swap.byidx( -1)    end,
--               {description = "swap with previous client by index", group = "client"}),
--     awful.key({ sup, "Control" }, "n", function () awful.screen.focus_relative( 1) end,
--               {description = "focus the next screen", group = "screen"}),
--     awful.key({ sup, "Control" }, "p", function () awful.screen.focus_relative(-1) end,
--               {description = "focus the previous screen", group = "screen"}),
--     awful.key({ sup,           }, "u", awful.client.urgent.jumpto,
--               {description = "jump to urgent client", group = "client"}),
--     awful.key({ sup,           }, "Tab",
--         function ()
--             awful.client.focus.history.previous()
--             if client.focus then
--                 client.focus:raise()
--             end
--         end,
--         {description = "go back", group = "client"}),

--     -- Standard program
--     awful.key({ sup, "Shift"   }, "Return", function () awful.spawn(terminal) end,
--               {description = "open a terminal", group = "launcher"}),
--     awful.key({ sup, "Control" }, "r", awesome.restart,
--               {description = "reload awesome", group = "awesome"}),
--     awful.key({ sup, "Shift"   }, "q", awesome.quit,
--               {description = "quit awesome", group = "awesome"}),

--     awful.key({ sup,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
--               {description = "increase master width factor", group = "layout"}),
--     awful.key({ sup,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
--               {description = "decrease master width factor", group = "layout"}),
--     awful.key({ sup, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
--               {description = "increase the number of master clients", group = "layout"}),
--     awful.key({ sup, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
--               {description = "decrease the number of master clients", group = "layout"}),
--     awful.key({ sup, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
--               {description = "increase the number of columns", group = "layout"}),
--     awful.key({ sup, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
--               {description = "decrease the number of columns", group = "layout"}),
--     awful.key({ sup,           }, "space", function () awful.layout.inc( 1)                end,
--               {description = "select next", group = "layout"}),
--     awful.key({ sup, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
--               {description = "select previous", group = "layout"}),

--     awful.key({ sup, "Control" }, "z",
--               function ()
--                   local c = awful.client.restore()
--                   -- Focus restored client
--                   if c then
--                       client.focus = c
--                       c:raise()
--                   end
--               end,
--               {description = "restore minimized", group = "client"}),

--     -- Prompt
--     awful.key({ sup },            "r",     function () awful.screen.focused().prompt:run() end,
--               {description = "run prompt", group = "launcher"}),

--     awful.key({ sup , "Shift" }, "x",
--               function ()
--                   awful.prompt.run {
--                     prompt       = "Run Lua code: ",
--                     textbox      = awful.screen.focused().prompt.widget,
--                     exe_callback = awful.util.eval,
--                     history_path = awful.util.get_cache_dir() .. "/history_eval"
--                   }
--               end,
--               {description = "lua execute prompt", group = "awesome"}),
--     -- Menubar
--     awful.key({ sup }, "x", function() menubar.show() end,
--               {description = "show the menubar", group = "launcher"})
-- )



-- -- Bind all key numbers to tags.
-- -- Be careful: we use keycodes to make it work on any keyboard layout.
-- -- This should map on the top row of your keyboard, usually 1 to 9.
-- for i = 1, 9 do
--     globalkeys = gears.table.join(globalkeys,
--         -- View tag only.
--         awful.key({ sup }, "#" .. i + 9,
--                   function ()
--                         local screen = awful.screen.focused()
--                         local tag = tags[i]
--                         if tag then
--                            sharedtags.viewonly(tag, screen)
--                         end
--                   end,
--                   {description = "view tag #"..i, group = "tag"}),
--         -- Toggle tag display.
--         awful.key({ sup, "Control" }, "#" .. i + 9,
--                   function ()
--                       local screen = awful.screen.focused()
--                       local tag = tags[i]
--                       if tag then
--                          sharedtags.viewtoggle(tag)
--                       end
--                   end,
--                   {description = "toggle tag #" .. i, group = "tag"}),
--         -- Move client to tag.
--         awful.key({ sup, "Shift" }, "#" .. i + 9,
--                   function ()
--                       if client.focus then
--                           local tag = tags[i]
--                           if tag then
--                               client.focus:move_to_tag(tag)
--                           end
--                      end
--                   end,
--                   {description = "move focused client to tag #"..i, group = "tag"}),
--         -- Toggle tag on focused client.
--         awful.key({ sup, "Control", "Shift" }, "#" .. i + 9,
--                   function ()
--                       if client.focus then
--                           local tag = tags[i]
--                           if tag then
--                               client.focus:toggle_tag(tag)
--                           end
--                       end
--                   end,
--                   {description = "toggle focused client on tag #" .. i, group = "tag"})
--     )
-- end
