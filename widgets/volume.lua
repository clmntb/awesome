local wibox = require("wibox")
local awful = require("awful")

-- {{{ Volume level
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
-- Initialize widgets
volwidget = wibox.widget.textbox()
volwidget:set_align("right")

channel = "Master"
pulse = " -D pulse "

function update_volume(widget,channel,pulse)
   local fd = io.popen("amixer "..pulse.." sget "..channel)
   local status = fd:read("*all")
   fd:close()

   local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
   status = string.match(status, "%[(o[^%]]*)%]")

   -- starting colour
   local sr, sg, sb = 0x3F, 0x3F, 0x3F
   -- ending colour
   local er, eg, eb = 0xDC, 0xDC, 0xCC

   local ir = math.floor(volume * (er - sr) + sr)
   local ig = math.floor(volume * (eg - sg) + sg)
   local ib = math.floor(volume * (eb - sb) + sb)
   interpol_colour = string.format("%.2x%.2x%.2x", ir, ig, ib)
   if string.find(status, "on", 1, true) then
       volume = " <span color='".. beautiful.fg_normal .."'>".. volume*100 .."% </span>"
   else
       volume = " <span color='red'>" .. volume*100 .. "M </span>"
   end
   widget:set_markup(volume)
end

update_volume(volwidget,channel,pulse)

mytimer = timer({ timeout = 0.2 })
mytimer:connect_signal("timeout", function () update_volume(volwidget,channel,pulse) end)
mytimer:start()
-- }}}
