local gears = require("gears")
local awful = require("awful")
local tags_state_file = awful.util.getdir("cache") .. "/persist-tags"

awful.layout.layouts = { awful.layout.suit.tile, awful.layout.suit.tile.bottom, awful.layout.suit.max, awful.layout.suit.floating, }

require("awful.autofocus")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local wibox = require("wibox")
local naughty = require("naughty")

naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.opacity = 0.8

require("handle_errors")

-- my things
local xtags = require("xtags")

xtags.load_from(tags_state_file)

local taglist = require("taglist")
local keys = require("keys")
local bar = require("bar")
require("savefloats")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.useless_gap = 2

terminal = "urxvt"
editor_cmd = os.getenv("VISUAL") or (terminal .. " -e " .. (os.getenv("EDITOR") or "nano"))
menubar.utils.terminal = terminal


local function set_wallpaper(s)
   gears.wallpaper.set("#376")
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
      set_wallpaper(s)
      bar:create(s)
end)

root.buttons(gears.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

root.keys(keys:define_global())

local clientkeys = keys:define_client()

local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ keys.M }, 1, awful.mouse.client.move),
    awful.button({ keys.M }, 3, awful.mouse.client.resize))

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
         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
         size_hints_honor = false
     }
    },

    {
       rule_any = {
          class = {
             "wpa_gui",
             "Pinentry-gtk-2"
          }
       },
       properties = {
          floating = true,
          ontop = true
       }
    },

    -- Add titlebars to normal clients and dialogs
    {
       rule_any = {
          type = { "normal", "dialog" }
       },
       properties = { titlebars_enabled = true }
    },

    {
       rule_any = {
          instance = {"xclock"}
       },
       properties = {
          titlebars_enabled = false,
          floating = true,
          ontop = true,
          sticky = true,
          opacity = 0.7,
          buttons = awful.button({}, 1, awful.mouse.client.move)
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
        awful.placement.no_offscreen(c)
    end
end)

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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

awesome.connect_signal(
   "screen::change",
   function (output, state)
      if state == "Connected" or state == "Disconnected" then
         awful.spawn("autorandr -c", false)
      end
   end
)


awesome.connect_signal(
   "exit",
   function (restart)
      xtags.save_to(tags_state_file)
   end
)
