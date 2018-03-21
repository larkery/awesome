local capi = {client = client, tag = tag}
local awful = require("awful")
local log = { on = false, last_tag = "" }

function log.note (t, v)
   if log.on then
      awful.spawn({"track", t, v}, false)
   end
end

local function log_tag (t)
   if t and t.selected and t.name and t.name ~= log.last_tag then
      log.last_tag = t.name
      log.note("tag", t.name)
   end
end

local function log_window_title (w)
   if capi.client.focus == w then
      log.note("window", (w.name or "") .. " " .. w.class)
      log_tag(w.first_tag)
   end
end

capi.client.connect_signal("property::name", log_window_title)
capi.client.connect_signal("focus", log_window_title)
capi.tag.connect_signal("property::selected", log_tag)
capi.tag.connect_signal("property::name", log_tag)

return log
