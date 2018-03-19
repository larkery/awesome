local capi = {client = client, tag = tag}
local awful = require("awful")
local log = {}

function log.note (t)
   local cmd = {"track"}
   for k, v in pairs(t) do
      table.insert(cmd, k)
      table.insert(cmd, v)
   end
   awful.spawn(cmd, false)
end

local function log_window_title (w)
   if capi.client.focus == w then
      log.note {event = "window",
                title=w.name,
                class = w.class}
   end
end

local function log_tag (t)
   if t.selected then
      log.note {event = "tag", name = t.name}
   end
end

capi.client.connect_signal("property::name", log_window_title)
capi.client.connect_signal("focus", log_window_title)
capi.tag.connect_signal("property::selected", log_tag)
capi.tag.connect_signal("property::name", log_tag)

return log
