local awful = require("awful")
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
   result.xtag_index = #xtags.all_tags+1
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

function make_tag (name)
   return awful.tag.add(
      name or ("" .. (1 + #xtags.all_tags)),
      {layout = awful.layout.layouts[1]}
   )

end

function xtags.nth (n)
   local result = xtags.all_tags[n]
   if not result then
      return make_tag()
   else
      return result
   end
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
         make_tag():greedy_view(s)
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


return xtags
