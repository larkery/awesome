local gears = require("gears")
local awful = require("awful")
local tags_state_file = awful.util.getdir("cache") .. "/persist-tags"

require("better-resize")

-- goes mental after a little while, sadly
-- local dynamic = require("awful.layout.dynamic")

awful.layout.layouts = { awful.layout.suit.tile, awful.layout.suit.tile.bottom, awful.layout.suit.max, awful.layout.suit.floating, }

require("awful.autofocus")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local wibox = require("wibox")
local naughty = require("naughty")


require("handle_errors")

-- my things
local xtags = require("xtags")

xtags.load_from(tags_state_file)

local taglist = require("taglist")
local keys = require("keys")
local bar = require("bar")
require("savefloats")

local color = require("color")
local main_color = "#635d6c"

local function is_floating (c)
   return c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.useless_gap = 4
beautiful.border_focus = color.shift(main_color, 0, 0, 0.2)

beautiful.border_normal = "#555555"
beautiful.titlebar_bg_focus = main_color
beautiful.bg_visible = color.shift(main_color, 0, 0, -0.1)
beautiful.fg_visible = "#FFFFFF"
beautiful.bg_focus = beautiful.titlebar_bg_focus
beautiful.fg_focus = "#FFFFFF"

beautiful.notification_font = "Sans 12"

naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 5
naughty.config.padding = 100
naughty.config.spacing = 4
naughty.config.defaults.border_width = 2
naughty.config.defaults.opacity = 1
naughty.config.defaults.width = 200


beautiful.border_width = 2

terminal = "urxvt"
editor_cmd = os.getenv("VISUAL") or (terminal .. " -e " .. (os.getenv("EDITOR") or "nano"))
menubar.utils.terminal = terminal

local function set_wallpaper(s)
   gears.wallpaper.set {
      type = "linear",
      from = {s.geometry.x, s.geometry.y + s.geometry.height/2},
      to = {s.geometry.x + s.geometry.width, s.geometry.y},
      stops = {
         {0, color.shift(main_color,   0.1, 0, -0.01)},
         {0.4, color.shift(main_color, 0.1, 0, -0.05)},
         {1, color.shift(main_color,   0.1, 0, -0.15)}}
   }
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
      set_wallpaper(s)
      bar:create(s)
end)

local util = require("util")
root.buttons(gears.table.join(
                awful.button({}, 3, util.client_menu),
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))

root.keys(keys:define_global())

local clientkeys = keys:define_client()

local function resize_client(c)
   if is_floating(c) or not(c.screen.selected_tag.layout.mouse_resize_handler) then
      awful.mouse.client.resize(c, false, {include_sides = true})
      return true
   else
      return c.screen.selected_tag.layout.mouse_resize_handler(c)
   end
end

local function near_border(w, a, b)
   local w2 = (1 - (2 * w))
   return function (c, ...)
      local coords = mouse.coords()
      local geom = c:geometry()

      if coords.x < geom.x + (w * geom.width) or
         coords.x > geom.x + (geom.width * w2) or
         coords.y < geom.y + (w * geom.width) or
         coords.y > geom.y + (geom.height * w2)
      then
         local result = a(c, ...)
         if result then
            return result
         end
      end
      return b(c, ...)
   end
end

local function raise_client(c)
   if c.focusable and (not c.floating) or
      (not c == client.focus)
   then
      client.focus = c; c:raise()
   end
end

local clientbuttons = gears.table.join(
   awful.button({ }, 1, raise_client),
   awful.button({ keys.M }, 1, near_border(0.1,
                                           resize_client,
                                           awful.mouse.client.move)),
   awful.button({ keys.M }, 3, resize_client)
)

local function insert_above_focused (c)
   local cfocus = client.focus
   if not cfocus then return end
   if c.screen ~= cfocus.screen then
      return
   end
   local cls = client.get(c.screen)
   for _, v in pairs(cls) do
      if v == cfocus then
         break
      end
      c:swap(v)
   end
end

require("placement-extra")

local near_mouse = awful.placement.under_mouse + awful.placement.no_offscreen2

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = true,
         keys = clientkeys,
         buttons = clientbuttons,
         screen = awful.screen.preferred,
         placement = near_mouse,
         size_hints_honor = false,
         titlebars_enabled = true,
      },
      callback = insert_above_focused
    },

    {
       rule_any = {
          class = {
             "Yad",
             "wpa_gui",
             "Pinentry-gtk-2",
             "TelegramDesktop"
          }
       },
       properties = {
          floating = true,
          ontop = true,
          border_width = 0
       }
    },

    {
       rule_any = {
          class = {"password-input"}
       },
       properties = {
          sticky = true,
          focusable = false,
          floating = true,
          ontop = true
       }
    },

    -- Add titlebars to normal clients and dialogs
    {
       rule_any = {
          type = { "dialog" }
       },
       properties = {
          titlebars_enabled = true,
          border_width = 0,
          ontop = true
       }
    },

    {
       rule_any = {
          instance = {"xclock"}
       },
       properties = {
          border_width = 0,
          titlebars_enabled = false,
          titlebars_forbidden = true,
          floating = true,
          ontop = true,
          sticky = true,
          opacity = 0.7,
          buttons = awful.button({}, 1, awful.mouse.client.move),
          placement = awful.placement.no_offscreen2 + awful.placement.top_right
       }
    }
}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen2(c)
    end

    float_titlebar(c)
end)


function float_titlebar(c)
   if c then
      if not (c.maximized or c.fullscreen) and
         not c.titlebars_forbidden and
         is_floating(c)
      then
         if c.titlebar == nil then
            c:emit_signal("request::titlebars", "rules", {})
         end
         awful.titlebar.show(c)
         c.border_width = 1
         if client.focus == c then
            c.border_color = beautiful.titlebar_bg_focus
         end
      elseif c.maximized then
         awful.titlebar.hide(c)
         c.border_width = 0
      else
         awful.titlebar.hide(c)
         c.border_width = beautiful.border_width
      end
   end
end

client.connect_signal( "property::floating", float_titlebar )

tag.connect_signal( "property::layout",
                    function (t)
                       for _,c in ipairs(t:clients()) do
                          float_titlebar(c)
                       end
                    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
-- my autoraise
require("autoraise")

client.connect_signal("focus",
                      function(c)
                         if is_floating(c) then
                            c.border_color = beautiful.titlebar_bg_focus
                         else
                            c.border_color = beautiful.border_focus
                         end
                         c.opacity = 1
                      end
)
client.connect_signal("unfocus",
                      function(c)
                         c.border_color = beautiful.border_normal
                         if c.transparent and is_floating(c) then
                            c.opacity = 0.5
                         end
                      end
)

local function autorandr ()
   awful.spawn({"autorandr", "-c"}, false)
end

awesome.connect_signal(
   "screen::change",
   function (output, state)
      if state == "Connected" or state == "Disconnected" then
         autorandr()
      end
   end
)

tag.connect_signal(
   "property::layout",
   function (t)
      if t.layout == awful.layout.suit.max then
         t.gap = 0
      else
         t.gap = 4
      end
   end
)

local tracker = require("tracker")
tracker.note("awesome", "restart")

if awesome.hostname == "limiting-factor" then
   tracker.on = true
else
   tracker.on = false
end

os.remove(tags_state_file)

autorandr()

awesome.connect_signal(
   "exit",
   function (restart)
      xtags.save_to(tags_state_file)
   end
)
