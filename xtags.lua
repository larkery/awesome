local awful = require("awful")
local gears = require("gears")
local capi = { screen = screen }

local xtags = {
   all_tags = { }
}

local delete_tag = awful.tag.object.delete
local add_tag = awful.tag.add

awful.tag.object.delete = function (t)
   local index = t.xtag_index
   local result = delete_tag(t)
   if result then
      table.remove(xtags.all_tags, index)
      for i = index, #xtags.all_tags do
         local t = xtags.all_tags[i]
         if t.name == ("" .. t.xtag_index) then
            t.name = "" .. (i)
         end
         t.xtag_index = i
      end
   end
   return result
end

awful.tag.add = function(name, props)
   local result = add_tag(name, props)
   result.xtag_index = (#xtags.all_tags)+1
   xtags.all_tags[result.xtag_index] = result
   function result:move_to(screen)
      screen = screen or awful.screen.focused()
      if self.screen ~= screen then
         local old_sel = self.screen.selected_tag
         local old_screen = self.screen

         self.screen = screen

         if old_sel == self and not old_screen.selected_tag then
            local new_tag = awful.tag.find_fallback(old_screen)
            if new_tag then new_tag:view_only() end
         end
      end
   end
   function result:greedy_view(screen)
      screen = screen or awful.screen.focused()
      if self.selected and self.screen ~= screen then
         local swap = screen.selected_tag
         swap:move_to(self.screen)
         swap:view_only()
      end
      self:move_to(screen)
      self:view_only()
   end
   return result
end

function print_screen (s)
   print("screen: " .. s.index)
   for _,t in ipairs(s.tags) do
      print("  " .. t.name .. " " .. tostring(t.selected) .. " " .. tostring(t.xtag_index))
   end
end

function xtags.swap_screens(s1, s2)
   local s1_tags = s1.selected_tags
   local s2_tags = s2.selected_tags
   local prior_selection = {}

   for _,t in ipairs(s1_tags) do
      prior_selection[t.xtag_index] = true
      t.screen = s2
   end

   for _,t in ipairs(s2_tags) do
      prior_selection[t.xtag_index] = true
      t.screen = s1
   end

   -- I think by deselecting all the tags on one screen awesome
   -- auto-selects other tags that we don't want selected. So I
   -- restore the selection here. Hack hack hack.
   for _, t in ipairs(s1.tags) do
      t.selected = prior_selection[t.xtag_index] or false
   end
   for _, t in ipairs(s2.tags) do
      t.selected = prior_selection[t.xtag_index] or false
   end
end

function xtags.new_tag (name)
   return awful.tag.add(
      name or ("" .. (1 + #xtags.all_tags)),
      {layout = awful.layout.layouts[1]}
   )
end

function xtags.nth (n)
   local result = xtags.all_tags[n]
   if not result then
      return xtags.new_tag()
   else
      return result
   end
end

function xtags.named (n)
   for _, tag in ipairs(xtags.all_tags) do
      if tag.name == n then
         return tag
      end
   end
   return xtags.new_tag(n)
end

function set_tag_for_new_screen (s)
   if not s.selected_tag then
      local needs_tag = true
      for _, tag in ipairs(xtags.all_tags) do
         if not(tag.selected) then
            tag:greedy_view(s)
            needs_tag = false
            break
         end
      end
      if needs_tag then
         xtags.new_tag():greedy_view(s)
      end
   end
end

function reassign_orphaned_tags (s)
   return function ()
      local newscreen = capi.screen.primary
      local seltags = newscreen.selected_tags
      for _,tag in ipairs(s.tags) do
         tag:move_to(newscreen)
      end
      for i,tag in ipairs(seltags) do
         if i == 1 then
            tag:view_only()
         else
            awful.tag.viewtoggle(tag)
         end
      end
   end
end

awful.screen.connect_for_each_screen(function(s)
      set_tag_for_new_screen(s)
      s:connect_signal("removed", reassign_orphaned_tags(s))
end)

function order_screens ()
   local screen_order = {}

   for s in capi.screen do
      table.insert(screen_order,
                   { screen = s,
                     left = s.geometry.x,
                     top = s.geometry.y
                   }
      )
   end
   table.sort(screen_order,
              function (s1, s2)
                 return (s1.left < s2.left) or (s1.top < s2.top)
              end
   )
   for i, s in ipairs(screen_order) do
      s.screen.screen_order = i
   end

   return screen_order
end

function xtags.save_to (file)
   local f = io.open(file, "w")
   if f then
      order_screens()
      for _, t in ipairs(xtags.all_tags) do
         local windows = {}
         for _,c in ipairs(t:clients()) do
            table.insert(windows, c.window)
         end
         f:write(string.format("%s\t%s\t%d\t%s\t%s\n",
                               t.name,
                               awful.layout.getname(t.layout),
                               (t.screen and t.screen.screen_order) or 1,
                               t.selected,
                               table.concat(windows, ",")))
      end
      f:close()
   end
end

function xtags.load_from (file)
   local f = io.open(file, "r")
   if f then
      f:close()
      local n = 1
      local layouts = {}
      for _, l in ipairs(awful.layout.layouts) do
         layouts[awful.layout.getname(l)] = l
      end

      local clients_by_win = {}
      for _, c in ipairs(client.get()) do
         c:tags({})
         clients_by_win[window] = c
      end

      local screen_order = order_screens()

      for line in io.lines(file) do
         local cols = gears.string.split(line, "\t")
         local tag_n = xtags.nth(n)

         tag_n.name = cols[1]
         tag_n.layout = layouts[cols[2]] or awful.layout.layouts[1]
         tag_n.screen = screen_order[tonumber(cols[3])].screen or capi.screen[1]
         tag_n.selected = cols[4] == "true"

         for _, client in ipairs(gears.string.split(cols[5], ",")) do
            local c = clients_by_win[tonumber(client)]
            if c then
               c:toggle_tag(tag_n)
            end
         end

         n = n + 1
      end
   end
end

return xtags
