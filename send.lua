local xtags = require("xtags")

local send = {
   target = nil
}

tag.connect_signal(
   "deleted",
   function (t)
      if t == send.target then
         send.target = nil
      end
   end
)

tag.connect_signal(
   "property::selected",
   function (t)
      if t == send.target then
         send.target = nil
      end
   end
)

function send.to ()
   if not send.target then
      send.target = xtags.new_tag()
   end
   return send.target
end

return target
