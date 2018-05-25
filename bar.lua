local awful = require("awful")
local wibox = require("wibox")
local taglist = require("taglist")
local gears = require("gears")
local util = require("util")
local batt = require("widget/battery")
local beautiful = require("beautiful")

local bar = { }
local clock = wibox.widget.textclock()
local taglist_buttons = gears.table.join(
   awful.button({}, 1, function (t) t:greedy_view() end),
   awful.button({}, 2, function (t) t:destroy() end),
   awful.button({}, 3, function (t)
         t:move_to()
         awful.tag.viewtoggle(t)
   end)
)

local tasklist_buttons = gears.table.join(
   awful.button({}, 1, util.minimize),
   awful.button({}, 2, util.kill)
)

local separator = wibox.widget.textbox()

separator:set_text(" ")

local function menu (s)
   local items = {

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
         border_width = 1,
         border_color = "#333333",
         position = "bottom",
         screen = s
   })

   local taglist = taglist(
      s,
      awful.widget.taglist.filter.all,
      taglist_buttons,
      { show_index = true }
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

   local tray = wibox.widget.systray()

   local mintasklist = awful.widget.tasklist(
         s,
         awful.widget.tasklist.filter.minimizedcurrenttags,
         tasklist_buttons,
         {
             disable_task_name = true
         }
   )

   local tasklist = awful.widget.tasklist(
         s,
         function (c, s)
           return awful.widget.tasklist.filter.currenttags(c, s) and not c.minimized
         end,
         tasklist_buttons
   )

   local batt = batt.create()

   mywibox:setup({
         layout = wibox.layout.align.horizontal,
         { layout = wibox.layout.fixed.horizontal,
           layoutbox,
           separator,
           taglist,
           separator,
           promptbox,
           mintasklist
         },
         tasklist,
         { layout = wibox.layout.fixed.horizontal,
           separator,
           tray,
           separator,
           batt,
           separator,
           clock
         }
   })

   s.mywibox = mywibox
end

return bar
