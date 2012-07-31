-- The launcher has a service logo and highlight scrim when it's visible, and then it has its menubar
-- The menubar is delegated

local service
local service_logo
local highlight_scrim
local menubar

local launcher_group = Group {}

local function load_assets()
    service_logo = Image { src = "assets/paytv_logos/"..service..".png" }
    service_logo.anchor_point = { service_logo.w/2, 0 }

    highlight_scrim = Canvas( 1920, 1 )
    highlight_scrim:rectangle( 0,0, 1920,1 )
    highlight_scrim:set_source_linear_pattern( 0,0, 1920,0 )
    highlight_scrim:add_source_pattern_color_stop( 0,    "#000000C0" )
    highlight_scrim:add_source_pattern_color_stop( 0.07, "#000000C0" )
    highlight_scrim:add_source_pattern_color_stop( 0.15, "#00000080" )
    highlight_scrim:add_source_pattern_color_stop( 0.19, "#00000040" )
    highlight_scrim:add_source_pattern_color_stop( 0.21, "#00000040" )
    highlight_scrim:add_source_pattern_color_stop( 0.25, "#00000080" )
    highlight_scrim:add_source_pattern_color_stop( 0.33, "#000000C0" )
    highlight_scrim:add_source_pattern_color_stop( 0,    "#000000C0" )
    highlight_scrim:fill()
    highlight_scrim = highlight_scrim:Image( { height = 1080, tile = { false, true } } )

    menubar = dofile("launcher/mainmenu.lua")
end

local launcher_hidden_key_handler

local function launcher_onscreen_key_handler(screen, key)
    if(keys.BACK == key) then
        launcher_group:animate({ duration = 500, opacity = 0 })
        menubar:goaway()
        screen.on_key_down = launcher_hidden_key_handler
    else
        -- Send all other keypresses to the menubar
        menubar:on_key_down(key)
    end
end

launcher_hidden_key_handler = function(screen, key)
    launcher_group:animate({ duration = 500, opacity = 255 })
    menubar:appear()
    screen.on_key_down = launcher_onscreen_key_handler
end

local function show_launcher()
    launcher_group.opacity = 0

    screen:add(launcher_group)

    service_logo.position = { 1920*0.2, 100 }

    launcher_group:add(highlight_scrim)
    launcher_group:add(service_logo)
    launcher_group:add(menubar)

    mediaplayer.on_loaded = function()
        mediaplayer:play()
    end
    mediaplayer:load("glee.mp4")

    screen:grab_key_focus()
    screen.on_key_down = launcher_hidden_key_handler
end

function start_launcher(the_service)
    service = the_service
    load_assets()
    show_launcher()
end
