local capi = { client = client, mouse = mouse, screen = screen, mousegrabber = mousegrabber }
local awful = require("awful")

local function mouse_resize_handler(c, _, _, _, orientation)
   orientation = orientation or "tile"
   awful.client.incwfact(0, c) -- needed to fix normalization at start

   local start = capi.mouse.coords()
   local x,y = start.x, start.y
   local wa = c.screen.workarea
   local idx = awful.client.idx(c)
   local c_above, c_below
   local idx_above, idx_below
   local wfact_above, wfact_below
   local jump_to = {x = x, y = y, blah = true}
   local move_mwfact = false

   do
      local g = c:geometry()

      local v_border = math.max(g.height / 3, 20)

      if idx.idx > 1 and y >= g.y and y <= g.y + v_border then
         -- we are near the top edge of the window
         c_above = awful.client.next(-1, c)
         c_below = c
         jump_to.y = g.y
         idx_above = idx.idx - 1
         idx_below = idx.idx
      elseif idx.idx < (idx.num) and x >= g.y + g.height - v_border then
         -- we are near the bottom edge of the window
         c_above = c
         c_below = awful.client.next(1, c)
         idx_above = idx.idx
         idx_below = idx.idx +1
         jump_to.y = g.y + g.height
      end

      local mw_split = wa.x + wa.width * c.screen.selected_tag.master_width_factor

      if math.abs(mw_split - x) > wa.width / 6 then
         move_mwfact = false
      else
         move_mwfact = true
         jump_to.x = mw_split
      end
   end

   if idx_above then
      local t = c.screen.selected_tag
      local data = t.windowfact or {}
      local colfact = data[idx.col] or {}
      wfact_above = colfact[idx_above] or 1
      wfact_below = colfact[idx_below] or 1
   end

   capi.mouse.coords(jump_to)

   capi.mousegrabber.run(
      function (_mouse)
         if not c.valid then return false end

         local pressed = false
         for _,v in ipairs(_mouse.buttons) do
            if v then
               pressed = true
               break
            end
         end

         if pressed then
            if move_mwfact then
               c.screen.selected_tag.master_width_factor =
                  math.min(math.max(
                              (_mouse.x - wa.x)/wa.width
                              , 0.01), 0.99)
            end

            if idx_above then
               local factor_delta = (_mouse.y - jump_to.y) / wa.height

               if factor_delta < 0 then
                  factor_delta = math.max(factor_delta, -(wfact_above - 0.05))
               else
                  factor_delta = math.min(factor_delta, wfact_below - 0.05)
               end

               local t = c.screen.selected_tag
               local data = t.windowfact or {}
               local colfact = data[idx.col] or {}
               colfact[idx_above] = wfact_above + factor_delta
               colfact[idx_below] = wfact_below - factor_delta
               awful.client.incwfact(0, c_above) -- just in case
               awful.client.incwfact(0, c_below)
            end
            return true
         else
            return false
         end
      end, "cross")
end

awful.layout.suit.tile.mouse_resize_handler = mouse_resize_handler

-- local old_coords = mouse.coords

-- mouse.coords = function(...)
--    if select(1, ...) and not(select(1, ...).blah) then
--       print("set mouse!!!")
--       print(debug.traceback())

--    end
--    return old_coords(...)
-- end
