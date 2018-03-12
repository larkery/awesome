local awful = require("awful")
local wibox = require("wibox")
local taglist = require("taglist")
local gears = require("gears")
local util = require("util")
local batt = require("batteryarc")
local beautiful = require("beautiful")

local bar = { }
local clock = wibox.widget.textclock()
local taglist_buttons = { }

local tasklist_buttons = gears.table.join(
   awful.button({}, 1, util.minimize),
   awful.button({}, 2, util.kill)
)

local separator = wibox.widget.textbox()

separator:set_text(" ")

local function menu (s)
   local items = {
      {"hibernate", util.exec("systemctl hibernate")},
   }

   for _, l in ipairs(awful.layout.layouts) do
      table.insert(items,
                   {l.name,
                    function () s.selected_tag.layout = l end,
                    beautiful["layout_" .. l.name]
                    }
      )
   end

   local boxmenu = awful.menu.new({
         items = items
   })

   return boxmenu
end

function bar:create(s)
   local boxmenu = menu(s)

   local mywibox = awful.wibar({
         position = "bottom",
         screen = s
   })

   local taglist = taglist(
      s,
      awful.widget.taglist.filter.all,
      taglist_buttons,
      { bg_vis = beautiful.bg_focus, fg_vis=beautiful.fg_focus,
        bg_focus = "#53868b"

      }
   )

   local promptbox = awful.widget.prompt()
   s.prompt = promptbox

   local layoutbox = awful.widget.layoutbox(s)
   layoutbox:buttons(
      gears.table.join(
         awful.button({}, 1, function () boxmenu:toggle() end),
         awful.button({}, 3, util.prev_layout)
      )
   )

   local tasklist = awful.widget.tasklist(
      s,
      awful.widget.tasklist.filter.currenttags,
      tasklist_buttons
   )

   mywibox:setup({
         layout = wibox.layout.align.horizontal,
         { layout = wibox.layout.fixed.horizontal,
           layoutbox,
           separator,
           taglist,
           separator,
           promptbox
         },
         tasklist,
         { layout = wibox.layout.fixed.horizontal,
           separator,
           wibox.widget.systray(),
           separator,
           batt,
           separator,
           clock
         }
   })

   s.mywibox = mywibox
end

return bar
