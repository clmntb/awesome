local wibox = require("wibox")
local awful = require("awful")

-- {{{ Network usage
dnicon = wibox.widget.imagebox()
upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
-- Initialize widget
netwidget = wibox.widget.textbox()
-- Register widget
vicious.register(netwidget, vicious.widgets.net,
        function (widget, args)
                if args["{eth0 carrier}"] == 1
                then
                        return '<span color="'.. beautiful.fg_netdn_widget .. '">' ..
                                args["{eth0 down_kb}"] ..
                        '</span> <span color="' .. beautiful.fg_netup_widget .. '">'..
                                args["{eth0 up_kb}"] ..
                        '</span>'
                elseif args["{wlan0 carrier}"] == 1
                then
                        return '<span color="'.. beautiful.fg_netdn_widget .. '">' ..
                                args["{wlan0 down_kb}"] ..
                        '</span> <span color="' .. beautiful.fg_netup_widget .. '">'..
                                args["{wlan0 up_kb}"] ..
                        '</span>'

                else
                        return  'Netwok Disabled '
                end
        end, 1)
-- }}}

