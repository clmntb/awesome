-- {{{ License
-- Awesome configuration, using awesome 3.5 on Arch GNU/Linux
--   * Inspired by Adrian C. <anrxc@sysphere.org>
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

require('freedesktop.utils')
require("naughty")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
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
terminal = "xterm -fg black -bg white -sl 32000"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'gnome' 
require('freedesktop.menu')

menu_items = freedesktop.menu.new()
myawesomemenu = {
     { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
     { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
     { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
     { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
}

table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })

mymainmenu = awful.menu.new({ items = menu_items, width = 250 })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon ,
                                     menu = mymainmenu
                                   })

myshutdownmenu = awful.menu({ 
   { "shutdown", awful.util.getdir("config") .. "/scripts/shutdown.sh", freedesktop.utils.lookup_icon({ icon = 'gtk-quit'}) },
   { "reboot", awful.util.getdir("config") .. "/scripts/reboot.sh", freedesktop.utils.lookup_icon({ icon = 'gtk-refresh'}) },
   { "suspend", awful.util.getdir("config") .. "/scripts/suspend.sh", freedesktop.utils.lookup_icon({ icon = 'gtk-quit'}) },
   { "hibernate", awful.util.getdir("config") .. "/scripts/hibernate.sh", freedesktop.utils.lookup_icon({ icon = 'gtk-quit'}) }
})

myshutdownlauncher = awful.widget.launcher({ image = beautiful.shutdown_icon,
                                     menu = myshutdownmenu })

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
  names  = { "term", "web", "irc", "vm", "explorer", "pentest", 7, "other", "media" },
  layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],
             layouts[1], layouts[1], layouts[1], layouts[1]
}}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
    awful.tag.setproperty(tags[s][5], "mwfact", 0.13)
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

-- {{{ Widget imports 
require("widgets.system")
require("widgets.network")
require("widgets.volume")
require("widgets.date")

volwidget:buttons(awful.util.table.join(
        awful.button({ }, 1, function () exec("amixer "..pulse.." set "..channel.." 1+ toggle") end),
        awful.button({ }, 4, function () exec("amixer "..pulse.." -q set "..channel.." 5%+", false) end),
        awful.button({ }, 5, function () exec("amixer "..pulse.." -q set "..channel.." 5%-", false) end)
))

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
    left_layout:add(mylauncher)
    left_layout:add(separator)
    left_layout:add(taglist[s])
    left_layout:add(separator)
    left_layout:add(promptbox[s])

    -- Widgets that are aligned to the right
    local custom_widgets =
    { 
        separator, cpuicon, cpugraph, tzswidget, separator,
	ramicon, ramgraph, separator,
        baticon, batwidget, separator,
        memicon, membar, 
        fsicon, fs.r, fs.h, separator, 
        dnicon, netwidget, upicon, separator,
        volicon, volwidget, separator,
        dateicon, datewidget , separator, layoutbox[s], 
	separator, myshutdownlauncher
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
              end),

    awful.key({ }, "XF86AudioRaiseVolume",  function () exec("amixer -D pulse -q set Master 5%+") end),
    awful.key({ }, "XF86AudioLowerVolume",  function () exec("amixer -D pulse -q set Master 5%-") end),
    awful.key({ }, "XF86AudioMute", function () exec("amixer -D pulse -q set Master 1+ toggle") end)
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
        end)
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
    { rule = { class = "VirtualBox" },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][4],c) end },
    { rule = { class = "Vim",    instance = "_Remember_" },
      properties = { floating = true }, callback = awful.titlebar.add  }
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

autorun = true
autorunApps =
{
    "nitrogen --restore",
    "autocutsel -selection CLIPBOARD -fork",
    "autocutsel -selection PRIMARY -fork",
    "pgrep -u $USER -x .*xautolock.* > /dev/null || ~/.config/awesome/locker.sh",
--  "/usr/bin/VBoxClient-all",
    "pgrep -u $USER -x .*nm-applet.* > /dev/null || nm-applet"
}

if autorun then
        for _, app in pairs(autorunApps) do
                awful.util.spawn_with_shell(app)
        end
	
end

spawn_once("hexchat","Hexchat","irc")
