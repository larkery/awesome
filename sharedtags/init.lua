--- Provides functionality to share tags across all screens in awesome WM.
-- @module sharedtags
-- @author Albert Diserholt
-- @copyright 2016 Albert Diserholt
-- @license MIT

-- Grab environment we need
local awful = require("awful")
local capi = {
    screen = screen
}

local sharedtags = {
    _VERSION = "sharedtags v1.0.0 for v4.0",
    _DESCRIPTION = "Share tags for awesome window manager v4.0",
    _URL = "https://github.com/Drauthius/awesome-sharedtags",
    _LICENSE = [[
        MIT LICENSE

        Copyright (c) 2017 Albert Diserholt

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the "Software"),
        to deal in the Software without restriction, including without limitation
        the rights to use, copy, modify, merge, publish, distribute, sublicense,
        and/or sell copies of the Software, and to permit persons to whom the
        Software is furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in
        all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
        FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
        IN THE SOFTWARE.
    ]]
}

-- Add a signal for each new screen, which just listens for the remove
-- event, and moves over all tags when it happens.
awful.screen.connect_for_each_screen(function(s)
    -- When the screen is removed, all tags need to be moved over to an existing
    -- screen. If they are not, accessing the tags will result in an error. It
    -- doesn't make sense to fix the error, since clients on the now-hidden tags
    -- will automatically be moved to a tag on a visible screen.
    s:connect_signal("removed",function()
        -- The screen to move the orphaned tags to.
        local newscreen = capi.screen.primary
        -- The currently selected tags on that screen.
        local seltags = newscreen.selected_tags

        -- Move over all tags to an existing screen.
        for _,tag in ipairs(s.tags) do
            sharedtags.movetag(tag, newscreen)
        end

        -- Restore the viewed tags on the new screen.
        for i,tag in ipairs(seltags) do
            if i == 1 then
                tag:view_only()
            else
                awful.tag.viewtoggle(tag)
            end
        end
    end)
end)

--- Create new tag objects.
-- The first tag defined for each screen will be automatically selected.
-- @tparam table def A list of tables with the optional keys `name`, `layout`
-- and `screen`. The `name` value is used to name the tag and defaults to the
-- list index. The `layout` value sets the starting layout for the tag and
-- defaults to the first layout. The `screen` value sets the starting screen
-- for the tag and defaults to the first screen. The tags will be sorted in this
-- order in the default taglist.
-- @treturn table A list of all created tags. Tags are assigned numeric values
-- corresponding to the input list, and all tags with non-numerical names are
-- also assigned to a key with the same name.
-- @usage local tags = sharedtags(
--   -- "main" is the first tag starting on screen 2 with the tile layout.
--   { name = "main", layout = awful.layout.suit.tile, screen = 2 },
--   -- "www" is the second tag on screen 1 with the floating layout.
--   { name = "www" },
--   -- Third tag is named "3" on screen 1 with the floating layout.
--   {})
-- -- tags[2] and tags["www"] both refer to the same tag.
function sharedtags.new(def)
   local tags = {}

   -- TODO sort out numbering and persistence

   function tags:add(t)
      local t = t or {}
      local i = 1+#tags
      local tg = awful.tag.add(
         t.name or i,
         {
            gap_single_client = false,
            screen = (t.screen and t.screen <= capi.screen.count())
               and t.screen or capi.screen.primary,
            layout = t.layout or awful.layout.layouts[1],
            sharedtagindex = i,
            selected = false
      })

      tags[i] = tg
      if not tags[i].screen.selected_tag then
         tags[i]:view_only()
      end
      return tg
   end
   for _,t in ipairs(def) do
      tags:add(t)
   end
   function tags:with(i, cb)
      local tag = tags[i]
      if not tag then
         awful.prompt.run(
            {
               prompt = "<b>Tag: </b>",
               text = ""..i
            },
            awful.screen.focused().prompt.widget,
            function (t)
               cb(tags:add({name = t}))
            end
         )
      else
         cb(tag)
      end
   end
   function tags:delete(tag)
      local ix = tag.sharedtagindex
      if tag and tag:delete() then
         if ix then
            table.remove(tags, ix)
         end
      end
   end
   function tags:view(i)
      tags:with(i,
                function (tag)
                   sharedtags.viewonly(tag, awful.screen.focused())
                end
      )
   end
   function tags:shift_focused(i)
      local f = client.focus
      if f then
         tags:with(
            i,
            function (tag)
               f:move_to_tag(tag)
            end
         )
      end
   end

   return tags
end

--- Move the specified tag to a new screen, if necessary.
-- @param tag The tag to move.
-- @tparam[opt=awful.screen.focused()] number screen The screen to move the tag to.
-- @treturn bool Whether the tag was moved.
function sharedtags.movetag(tag, screen)
    screen = screen or awful.screen.focused()
    local oldscreen = tag.screen

    -- If the specified tag is allocated to another screen, we need to move it.
    if oldscreen ~= screen then
        local oldsel = oldscreen.selected_tag
        tag.screen = screen

        if oldsel == tag then
            -- The tag has been moved away. In most cases the tag history
            -- function will find the best match, but if we really want we can
            -- try to find a fallback tag as well.
            if not oldscreen.selected_tag then
                local newtag = awful.tag.find_fallback(oldscreen)
                if newtag then
                    newtag:view_only()
                end
            end
        --else
            -- NOTE: A bug in awesome 4.0 is causing all tags to be deselected
            -- here. A shame, but I haven't found a nice way to work around it
            -- except by fixing the bug (history seems to be in a weird state).
        end

        -- Also sort the tag in the taglist, by reapplying the index. This is just a nicety.
        local unpack = unpack or table.unpack
        for _,s in ipairs({ screen, oldscreen }) do
            local tags = { unpack(s.tags) } -- Copy
            table.sort(tags, function(a, b) return a.sharedtagindex < b.sharedtagindex end)
            for i,t in ipairs(tags) do
                t.index = i
            end
        end

        return true
    end

    return false
end

--- View the specified tag on the specified screen.
-- @param tag The only tag to view.
-- @tparam[opt=awful.screen.focused()] number screen The screen to view the tag on.
function sharedtags.viewonly(tag, screen)
   -- if we are moving the tag from a different screen
   -- we should also move the current tag on this screen over there
   if tag.selected and tag.screen ~= screen then
      local swap = screen.selected_tag
      sharedtags.movetag(swap, tag.screen)
      swap:view_only()
   end
   sharedtags.movetag(tag, screen)
   tag:view_only()
end

--- Toggle the specified tag on the specified screen.
-- The tag will be selected if the screen changes, and toggled if it does not
-- change the screen.
-- @param tag The tag to toggle.
-- @tparam[opt=awful.screen.focused()] number screen The screen to toggle the tag on.
function sharedtags.viewtoggle(tag, screen)
    local oldscreen = tag.screen

    if sharedtags.movetag(tag, screen) then
        -- Always mark the tag selected if the screen changed. Just feels a lot
        -- more natural.
        tag.selected = true
        -- Update the history on the old and new screens.
        oldscreen:emit_signal("tag::history::update")
        tag.screen:emit_signal("tag::history::update")
    else
        -- Only toggle the tag unless the screen moved.
        awful.tag.viewtoggle(tag)
    end
end

return setmetatable(sharedtags, { __call = function(...) return sharedtags.new(select(2, ...)) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
