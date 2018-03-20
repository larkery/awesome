local capi = {client = client, tag = tag}
local awful = require("awful")
local log = { on = true }

function log.note (t, v)
   if log.on then
      awful.spawn({"track", t, v}, false)
   end
end

local function log_window_title (w)
   if capi.client.focus == w then
      log.note("window", w.name .. " " .. w.class)
   end
end

local function log_tag (t)
   if t.selected and t.name then
      log.note("tag", t.name)
   end
end

capi.client.connect_signal("property::name", log_window_title)
capi.client.connect_signal("focus", log_window_title)
capi.tag.connect_signal("property::selected", log_tag)
capi.tag.connect_signal("property::name", log_tag)

return log
