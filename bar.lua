local awful = require("awful")
local wibox = require("wibox")
local taglist = require("taglist")
local gears = require("gears")
local util = require("util")

local bar = { }
local clock = wibox.widget.textclock()
local taglist_buttons = { }


local tasklist_buttons = gears.table.join(
   awful.button({}, 1, util.minimize)
)

local separator = wibox.widget.textbox()

separator:set_text(" ")

function bar:create(s, tags)
   local mywibox = awful.wibar({
         position = "bottom",
         screen = s
   })

   local taglist = taglist(
      tags, s, awful.widget.taglist.filter.all,
      taglist_buttons
   )

   local promptbox = awful.widget.prompt()
   s.prompt = promptbox

   local layoutbox = awful.widget.layoutbox(s)
   layoutbox:buttons(
      gears.table.join(
         awful.button({}, 1, util.next_layout),
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
           clock
         }
   })

   s.mywibox = mywibox
end

return bar
