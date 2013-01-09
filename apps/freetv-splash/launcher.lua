-- The launcher has a service logo and highlight scrim when it's visible, and then it has its menubar
-- The menubar is delegated

local service
local service_logo
local highlight_scrim
local date_time
local menubar

local launcher_group = Group {}

local function load_assets()
    service_logo = Image { src = "assets/paytv_logos/"..service..".png" }
    service_logo.anchor_point = { service_logo.w/2, service_logo.h/2 }

    highlight_scrim = Canvas( screen.w, 1 )
    highlight_scrim:rectangle( 0,0, screen.w,1 )
    highlight_scrim:set_source_linear_pattern( 0,0, screen.w,0 )
    highlight_scrim:add_source_pattern_color_stop( 0,    "#000000C0" )
    highlight_scrim:add_source_pattern_color_stop( 0.07, "#000000C0" )
    highlight_scrim:add_source_pattern_color_stop( 0.15, "#00000080" )
    highlight_scrim:add_source_pattern_color_stop( 0.19, "#00000040" )
    highlight_scrim:add_source_pattern_color_stop( 0.21, "#00000040" )
    highlight_scrim:add_source_pattern_color_stop( 0.25, "#00000080" )
    highlight_scrim:add_source_pattern_color_stop( 0.33, "#000000C0" )
    highlight_scrim:add_source_pattern_color_stop( 0,    "#000000C0" )
    highlight_scrim:fill()
    highlight_scrim = highlight_scrim:Image( { height = screen.h, tile = { false, true } } )

    date_time = Text { name = "date", color = "white", font = FONT_NAME.." 40px", text = os.date("%a %d %b\n%I:%M %p"), alignment = "CENTER" }
    date_time.anchor_point = { date_time.w, date_time.h/2 }
    date_time.extra.updater = Timer {
                                        interval = ( 60 - os.date("*t").sec ) * 1000,
                                        on_timer = function(t)
                                            date_time.text = os.date("%a %d %b\n%I:%M %p")
                                            t.interval = ( 60 - os.date("*t").sec ) * 1000
                                        end,
    }

    menubar = dofile("launcher/mainmenu.lua")
end

local launcher_hidden_key_handler

local function launcher_onscreen_key_handler(screen, key)
    if(keys.BACK == key) then
        launcher_group:animate({ duration = 500, opacity = 0 })
        highlight_scrim:animate({ duration = 500, opacity = 0 })
        menubar:goaway()
        screen.on_key_down = launcher_hidden_key_handler
    else
        -- Send all other keypresses to the menubar
        menubar:on_key_down(key)
    end
end

launcher_hidden_key_handler = function(screen, key)
    launcher_group:animate({ duration = 500, opacity = 255 })
    highlight_scrim:animate({ duration = 500, opacity = 255 })
    menubar:appear()
    screen.on_key_down = launcher_onscreen_key_handler
end

local function show_launcher(start_item)
    launcher_group.opacity = 0
    highlight_scrim.opacity = 0

    screen:add(launcher_group)

    service_logo.position = { screen.w * 1/5, screen.h * 1/10 }
    date_time.position = { screen.w * 19/20, screen.h * 1/10 }

    screen:add(highlight_scrim)
    launcher_group:add(service_logo)
    launcher_group:add(menubar)
    launcher_group:add(date_time)
    highlight_scrim:lower_to_bottom()

    mediaplayer.on_loaded = function()
        mediaplayer:play()
    end
    --mediaplayer:load("http://bkpc/Videos/Tonight%20Show%20With%20Jay%20Leno.mpg")
    mediaplayer:load('glee.mp4')

    screen:grab_key_focus()
    screen.on_key_down = launcher_hidden_key_handler
    menubar:start_item(start_item)
    settings.back_to_start = "Live TV"
end

function start_launcher(the_service, start_item)
    if( not start_item ) then start_item = "Live TV" end
    service = the_service
    load_assets()
    show_launcher(start_item)
end
