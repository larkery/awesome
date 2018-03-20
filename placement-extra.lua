local capi = {screen=screen}
local placement = require("awful.placement")
local gtable = require("gears.table")
-- Get the area covered by a drawin.
-- @param d The drawin
-- @tparam[opt=nil] table new_geo A new geometry
-- @tparam[opt=false] boolean ignore_border_width Ignore the border
-- @tparam table args the method arguments
-- @treturn The drawin's area.
local area_common = function(d, new_geo, ignore_border_width, args)
    -- The C side expect no arguments, nil isn't valid
    if new_geo and args.zap_border_width then
        d.border_width = 0
    end
    local geometry = new_geo and d:geometry(new_geo) or d:geometry()
    local border = ignore_border_width and 0 or d.border_width or 0

    -- When using the placement composition along with the "pretend"
    -- option, it is necessary to keep a "virtual" geometry.
    if args and args.override_geometry then
       geometry = gtable.clone(args.override_geometry)
    end

    geometry.width = geometry.width + 2 * border
    geometry.height = geometry.height + 2 * border
    return geometry
end

local function get_screen(s)
   return s and capi.screen[s]
end

local margin = 10

function placement.no_offscreen2(c, args)
    c = c or capi.client.focus
    local geometry = area_common(c, nil, false, args)

    local screen = c.screen
    local screen_geometry = screen.workarea

    if geometry.width > screen_geometry.width then
       geometry.width = screen_geometry.width - (2*margin)
       geometry.x = screen_geometry.x + margin
    elseif geometry.x < screen_geometry.x then
       geometry.x = screen_geometry.x + margin
    elseif geometry.x + geometry.width > screen_geometry.x + screen_geometry.width then
       geometry.x = screen_geometry.x + screen_geometry.width - (geometry.width + margin)
    end

    if geometry.height > screen_geometry.height then
       geometry.height = screen_geometry.height - (2*margin)
       geometry.y = screen_geometry.y + margin
    elseif geometry.y < screen_geometry.y then
       geometry.y = screen_geometry.y + margin
    elseif geometry.y + geometry.height > screen_geometry.y + screen_geometry.height then
       geometry.y = screen_geometry.y + screen_geometry.height - (geometry.height + margin)
    end

    return c:geometry {
        x = geometry.x,
        y = geometry.y,
        width = geometry.width,
        height = geometry.height
    }
end
