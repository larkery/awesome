local capi = {screen=screen}
local placement = require("awful.placement")

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

function placement.no_offscreen2(c, screen)
    --HACK necessary for composition to work. The API will be changed soon
    if type(screen) == "table" then
        screen = nil
    end

    c = c or capi.client.focus
    local geometry = area_common(c)
    screen = get_screen(screen or c.screen or a_screen.getbycoord(geometry.x, geometry.y))
    local screen_geometry = screen.workarea

    if geometry.width > screen_geometry.width then
       geometry.width = screen_geometry.width - 40
       geometry.x = screen_geometry.x + 20
    elseif geometry.x < screen_geometry.x then
       geometry.x = screen_geometry.x + 20
    elseif geometry.x > screen_geometry.x + screen_geometry.width then
       geometry.x = screen_geometry.x + screen_geometry.width - (geometry.width + 20)
    end

    if geometry.height > screen_geometry.height then
       geometry.height = screen_geometry.height - 40
       geometry.y = screen_geometry.y + 20
    elseif geometry.y < screen_geometry.y then
       geometry.y = screen_geometry.y + 20
    elseif geometry.y > screen_geometry.y + screen_geometry.height then
       geometry.y = screen_geometry.y + screen_geometry.height - (geometry.height + 20)
    end

    return c:geometry {
        x = geometry.x,
        y = geometry.y,
        width = geometry.width,
        height = geometry.height
    }
end
