-- Some assets

local service

local service_logo
local highlight_scrim
local bar_highlight, blue_overlay
local bar_slice

local launcher_group = Group {}

local function load_assets()
    service_logo = Image { src = "assets/paytv_logos/"..service..".png" }
    service_logo.anchor_point = { service_logo.w/2, 0 }
    bar_highlight = Image { src = "assets/menubar/bar-highlight.png" }
    blue_overlay = Image { src = "assets/menubar/blue-overlay.png" }

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

    bar_slice = Canvas( 1, 45 )
    -- 1 pixel of #0E1924, gradient for 43 pixels from (75,75,75) to (0,0,0), then one pixel of #0E1924
    bar_slice:rectangle(-1,1, 3,43)
    bar_slice:set_source_color( "#0E1924" )
    bar_slice.line_width = 1
    bar_slice:stroke(true)

    bar_slice:set_source_linear_pattern(1,2, 1,42)
    bar_slice:add_source_pattern_color_stop( 0, "#4B4B4B" )
    bar_slice:add_source_pattern_color_stop( 1, "#000000" )
    bar_slice:fill()

    bar_slice = bar_slice:Image( { width = 1920, tile = { true, false } } )
end

local function show_launcher()
    launcher_group.opacity = 0

    screen:add(launcher_group)

    service_logo.position = { 1920*0.2, 100 }
    bar_slice.position = { 0, 925 }
    bar_highlight.position = { 100, 925-bar_highlight.h/2 }
    blue_overlay.position = { 100, 925 }

    launcher_group:add(highlight_scrim)
    launcher_group:add(service_logo)
    launcher_group:add(bar_slice)
    launcher_group:add(bar_highlight)
    launcher_group:add(blue_overlay)

    mediaplayer.on_loaded = function()
        mediaplayer:play()
        dolater(4000, launcher_group.animate, launcher_group, { duration = 750, opacity = 255 })
    end
    mediaplayer:load("glee.mp4")

end

function start_launcher(the_service)
    service = the_service
    load_assets()
    show_launcher()
end
