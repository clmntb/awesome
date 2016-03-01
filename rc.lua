-- {{{ License
--
-- Awesome configuration, using awesome 3.5 on Arch GNU/Linux
--   * Inspired by Adrian C. <anrxc@sysphere.org>

-- Screenshot: http://sysphere.org/gallery/snapshots

-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- {{{ Libraries
awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")
-- User libraries
vicious = require("vicious")
vicious.contrib = require("vicious.contrib")
-- Theme handling library
beautiful = require("beautiful")
-- Wibox
wibox = require("wibox")
local cal = require("utils.cal")

local menubar = require("menubar")
-- }}}


-- {{{ Variable definitions
local altkey = "Mod1"
local modkey = "Mod4"

local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- Beautiful theme
beautiful.init(home .. "/.config/awesome/zenburn.lua")

-- This is used later as the default terminal and editor to run.
-- A.Tabou: Increase default font size for all terminals
-- terminal = "xterm -fg white -bg black -fn -*-fixed-medium-*-*-*-14-*
terminal = "xterm -fg black -bg white -sl 32000"
menubar.utils.terminal = terminal
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "/usr/local/share/applications", "~/.local/share/applications", "/opt" }

-- Window management layouts
layouts = {
  awful.layout.suit.fair,        -- 3
  awful.layout.suit.tile,        -- 1
  awful.layout.suit.tile.bottom, -- 2
  awful.layout.suit.max,         -- 4
  awful.layout.suit.magnifier,   -- 5
  awful.layout.suit.floating     -- 6
}
-- }}}


-- {{{ Tags
tags = {
  names  = { "term", "web", "irc", "vm", "explorer", "pentest", 7, "rss", "media" },
  layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],
             layouts[1], layouts[1], layouts[1], layouts[1]
}}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
    awful.tag.setproperty(tags[s][5], "mwfact", 0.13)
    -- awful.tag.setproperty(tags[s][6], "hide",   true)
    awful.tag.setproperty(tags[s][7], "hide",   true)
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)
-- }}}

-- {{{ Define gradient to be used
local colour1, colour2
colour1 = beautiful.fg_widget
colour2 = beautiful.fg_end_widget
gradient_colour = {type="linear", from={0, 0}, to={0, 10},
    stops={{1, colour1}, {0.5, beautiful.fg_center_widget}, {0, colour2}}}
--- }}}

-- {{{ CPU usage and temperature
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
tzswidget = wibox.widget.textbox()
-- Graph properties
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.bg_widget)
cpugraph:set_color(gradient_colour)
-- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, {"thermal_zone1", "sys"})
-- }}}

-- {{{ RAM usage
ramicon = wibox.widget.imagebox()
ramicon:set_image(beautiful.widget_mem)
ramgraph = wibox.widget.textbox()
vicious.register(ramgraph, vicious.widgets.mem, "$1%", 1)
--- }}}

-- {{{ Battery state
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
-- Initialize widget
batwidget = wibox.widget.textbox()
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "$2%", 61, "BAT0")
-- vicious.register(batwidget, vicious.contrib.batproc, "$1$2%", 61, "BAT0")
-- }}}

-- {{{ File system usage
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.widget_fs)
-- Initialize widgets
fs = {
  r = awful.widget.progressbar(), h = awful.widget.progressbar()
  --s = awful.widget.progressbar(), b = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(14):set_width(5):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_color(gradient_colour)
  --w.widget:buttons(awful.util.table.join(
  --  awful.button({ }, 1, function () exec("rox", false) end)
  --))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",            599)
vicious.register(fs.h, vicious.widgets.fs, "${/boot used_p}",        599)
--vicious.register(fs.s, vicious.widgets.fs, "${/var used_p}", 599)
--vicious.register(fs.b, vicious.widgets.fs, "${/tmp used_p}",  599)
-- }}}

-- {{{ Network usage
dnicon = wibox.widget.imagebox()
upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
-- Initialize widget
netwidget = wibox.widget.textbox()
--wlan0netwidget = wibox.widget.textbox()
-- Register widget
--vicious.register(eth0netwidget, vicious.widgets.net, '<span color="'
--  .. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
--  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 3)
	
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



-- {{{ Volume level

volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = wibox.widget.textbox()
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(12):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_color(gradient_colour)
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
-- Register buttons
volbar:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("kmix") end),
   awful.button({ }, 4, function () exec("amixer -D pulse -q set Master 5%+", false) end),
   awful.button({ }, 5, function () exec("amixer -D pulse -q set Master 5%-", false) end)
)) -- Register assigned buttons
volwidget:buttons(volbar:buttons())
-- }}}

-- {{{ Date and time
dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_date)
-- Initialize widget
datewidget = wibox.widget.textbox()
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%b %d, %R", 60)
--vicious.register(datewidget, vicious.widgets.date, "%R ", 61)
-- Register buttons
datewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec("pylendar.py") end)
))

cal.register(datewidget)

-- }}}

-- {{{ Wibox initialisation
mywibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
    awful.button({ },        1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ },        4, awful.tag.viewnext),
    awful.button({ },        5, awful.tag.viewprev
))

for s = 1, screen.count() do
    -- Create a promptbox
    promptbox[s] = awful.widget.prompt()
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))

    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 20,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.bg_normal,
        border_width = 1
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(taglist[s])
    left_layout:add(separator)
    --left_layout:add(layoutbox[s])
    --left_layout:add(separator)
    left_layout:add(promptbox[s])

    -- Widgets that are aligned to the right
    local custom_widgets =
    { 
        separator, cpuicon, cpugraph, tzswidget, separator,
	ramicon, ramgraph, separator,
        baticon, batwidget, separator,
        memicon, membar, --separator,
        fsicon, fs.r, fs.h, separator, -- fs.s, fs.b, separator,
        dnicon, netwidget, upicon, separator,
        --dnicon, wlan0netwidget, upicon, separator,
        --volicon, volbar, volwidget, separator,
        dateicon, datewidget , separator, layoutbox[s]
    }

    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    for _, wdgt in pairs(custom_widgets) do
        right_layout:add(wdgt)
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Client bindings
clientbuttons = awful.util.table.join(
    awful.button({ },        1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,		  }, "p", function () menubar.show() end),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ altkey, "Control" }, "l", function () awful.util.spawn("dm-tool lock") end),

    awful.key({ modkey, "Shift" }, "o", 
	function (c) 
        	local currenttag = awful.tag.getidx()
        	local nextscreen = mouse.screen + 1
        	if mouse.screen == screen.count() then
            		nextscreen = mouse.screen - 1
        	end
        	awful.client.movetotag(tags[nextscreen][currenttag],c)
       	 	awful.tag.viewonly(tags[nextscreen][currenttag])
    	end),

    awful.key( -- restore minimized windows
        {modkey, "Shift"}, "n",
        function ()
            local allclients = client.get(mouse.screen)

            for _,c in ipairs(allclients) do
                if c.minimized and c:tags()[mouse.screen] ==
                    awful.tag.selected(mouse.screen) then
                    c.minimized = false
                    client.focus = c
                    c:raise()
                    return
                end
            end
        end
    ),

    -- Prompt
    awful.key({ modkey },            "r",     function () promptbox[mouse.screen]:run() end),

    awful.key({ }, "Print", function () awful.util.spawn_with_shell("sleep 0.5 && scrot '%Y-%m-%d_%H:%M:%S_capture.png' -e 'mv $f /home/cberland/Images/screenshots/'") end),
    awful.key({ "Control" }, "Print", function () awful.util.spawn_with_shell("sleep 0.5 && scrot -u '%Y-%m-%d_%H:%M:%S_capture.png' -e 'mv $f /home/cberland/Images/screenshots/'") end),
    awful.key({ "Shift" }, "Print", function () awful.util.spawn_with_shell("sleep 0.5 && scrot -s '%Y-%m-%d_%H:%M:%S_capture.png' -e 'mv $f /home/cberland/Images/screenshots/'") end),

    awful.key({ modkey }, "e", function () awful.util.spawn("nautilus") end),
    --awful.key({ modkey }, "t", function () awful.util.spawn("gedit") end),
    awful.key({ modkey }, "b", function () awful.util.spawn("chromium-browser") end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  promptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    -- awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

   -- Configure the hotkeys.
   awful.key({ }, "XF86AudioRaiseVolume",  function ()
       awful.util.spawn("amixer -D pulse set Master 5%+", false) end),
   awful.key({ }, "XF86AudioLowerVolume",  function ()
       awful.util.spawn("amixer -D pulse set Master 5%-", false) end),
   awful.key({ }, "XF86AudioMute", function ()
       awful.util.spawn("amixer -D pulse set Master 1+ toggle", false) end)

)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
    { rule = { }, properties = {
      focus = true,      size_hints_honor = false,
      keys = clientkeys, buttons = clientbuttons,
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal }
    },
    { rule = { class = "Firefox" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][6],c) end },
    { rule = { class = "Vim",    instance = "vim" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][1],c) end },
    { rule = { class = "chromium" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][2],c) end },
    { rule = { class = "Hexchat", instance = "hexchat" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][3],c) end },
    { rule = { class = "Pcmanfm" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][5],c) end },
    { rule = { class = "VirtualBox" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][4],c) end },
    { rule = { class = "Vim",    instance = "_Remember_" },
      properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { class = "Xmessage", instance = "xmessage" },
      properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { instance = "firefox-bin" },
      properties = { floating = true }, callback = awful.titlebar.add  },
    { rule = { name  = "Alpine" },      properties = { tag = tags[1][4]} },
    { rule = { class = "Gajim.py" },    properties = { tag = tags[1][5]} },
    { rule = { class = "Akregator" },   properties = { tag = tags[1][8]} },
    { rule = { class = "Ark" },         properties = { floating = true } },
    { rule = { class = "Geeqie" },      properties = { floating = true } },
    { rule = { class = "ROX-Filer" },   properties = { floating = true } },
    { rule = { class = "Pinentry.*" },  properties = { floating = true } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Manage signal handler
client.connect_signal("manage", function (c, startup)
    -- Add titlebar to floaters, but remove those from rule callback
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, {modkey = modkey}) end
    end

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function (c)
        if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Client placement
    if not startup then
        awful.client.setslave(c)

        if  not c.size_hints.program_position
        and not c.size_hints.user_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
-- }}}

-- {{{ Focus signal handlers
client.connect_signal("focus", function(c)
                              c.border_color = beautiful.border_focus
                              c.opacity = 1
                           end)
client.connect_signal("unfocus", function(c)
                                c.border_color = beautiful.border_normal
                                c.opacity = 0.7
                             end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}
-- }}}

-- Autorun programs
autorun = true
autorunApps =
{
    "nitrogen --restore",
    "autocutsel -selection CLIPBOARD -fork",
    "autocutsel -selection PRIMARY -fork"
}

if autorun then
        for _, app in pairs(autorunApps) do
                awful.util.spawn(app)
        end
end

function spawn_once(command, class, tag) 
	-- create move callback
  	local callback 
  	callback = function(c) 
    		if c.class == class then 
      			awful.client.movetotag(tag, c) 
      			client.remove_signal("manage", callback) 
    		end 
  	end 
  	client.add_signal("manage", callback) 
  	-- now check if not already running!     
  	local findme = command
  	local firstspace = findme:find(" ")
  	if firstspace then
    		findme = findme:sub(0, firstspace-1)
	end
	-- finally run it
	awful.util.spawn_with_shell("pgrep -u $USER -x .*" .. findme .. ".* > /dev/null || (" .. command .. ")")
end

--spawn_once("chromium","Chromium","web")
spawn_once("hexchat","Hexchat","irc")
--spawn_once("pcmanfm","Pcmanfm","explorer")

awful.util.spawn_with_shell("nitrogen --restore")
awful.util.spawn_with_shell("pgrep -u $USER -x .*xautolock.* > /dev/null || ~/.config/awesome/locker.sh")
awful.util.spawn_with_shell("pgrep -u $USER -x .*nm-applet.* > /dev/null || nm-applet")
awful.util.spawn_with_shell("pgrep -u $USER -x .*kmix.* 2> /dev/null || kmix && qdbus org.kde.kmix /Mixers org.kde.KMix.MixSet.setCurrentMaster PulseAudio__Playback_Devices_1 alsa_output_pci_0000_00_1b_0_analog_stereo")
--awful.util.spawn_with_shell("/usr/bin/VBoxClient-all")
