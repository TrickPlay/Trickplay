local bubble_light_color = "#cae1ff"
local bubble_dark_color = "#243A56"


local function load_resources()
    local hidden_group = screen:find_child('hidden_assets')
    hidden_group:hide()
    local bground = Image { name = "background_img", src = "assets/horizon/top-bg.png" }
    local beam = Image { name = "beam_img", src = "assets/horizon/beam.png" }
    local horizon1 = Image { name = "horizon1_img", src = "assets/horizon/1.png" }
    local horizon2 = Image { name = "horizon2_img", src = "assets/horizon/2.png" }
    local horizon3 = Image { name = "horizon3_img", src = "assets/horizon/3.png" }
    local horizon4 = Image { name = "horizon4_img", src = "assets/horizon/4.png" }
    hidden_group:add(bground, beam, horizon1, horizon2, horizon3, horizon4)
end

local function make_light_bubble(size)
    local canvas = Canvas(size, size)

    canvas:set_source_radial_pattern( size/2, size/2, 0, size/2, size/2, size/2 )
    canvas:add_source_pattern_color_stop( 0.0, bubble_light_color.."A0" )
    canvas:add_source_pattern_color_stop( 0.8, bubble_light_color.."40" )
    canvas:add_source_pattern_color_stop( 1.0, bubble_light_color.."00" )

    canvas:rectangle( 0, 0, size, size )
    canvas:fill()

    local img = canvas:Image( { name = "light bubble", opacity = 128 } )
    img.anchor_point = { img.w/2, img.h/2 }
    return img
end

local function make_dark_bubble(size)
    local canvas = Canvas(size, size)

    canvas:set_source_radial_pattern( size/2, size/2, 0, size/2, size/2, size/2 )
    canvas:add_source_pattern_color_stop( 0.0, bubble_dark_color.."ff" )
    canvas:add_source_pattern_color_stop( 0.7, bubble_dark_color.."e0" )
    canvas:add_source_pattern_color_stop( 0.9, bubble_dark_color.."20" )
    canvas:add_source_pattern_color_stop( 1.0, bubble_dark_color.."00" )

    canvas:rectangle( 0, 0, size, size )
    canvas:fill()

    local img = canvas:Image( { name = "dark bubble", opacity = 128 } )
    img.anchor_point = { img.w/2, img.h/2 }
    return img
end

local function make_halo_bubble(size)
    local canvas = Canvas(size*2, size*2)

    canvas:set_source_radial_pattern( canvas.w/2, canvas.h/2, 0, canvas.w/2, canvas.h/2, canvas.w/2 )
    canvas:add_source_pattern_color_stop( 0.0, bubble_light_color.."00" )
    canvas:add_source_pattern_color_stop( 0.5, bubble_light_color.."20" )
    canvas:add_source_pattern_color_stop( 0.51, bubble_light_color.."80" )
    canvas:add_source_pattern_color_stop( 1.0, bubble_light_color.."00" )

    canvas:rectangle( 0, 0, size*3, size*3 )
    canvas:fill()

    local img = canvas:Image( { name = "halo bubble", opacity = 128 } )
    img.anchor_point = { img.w/2, img.h/2 }
    return img
end

local function make_bubble(backdrop_group)
    local bubble_type = math.random(1,3)
    local bubble_size = math.random(100, 200)
    local the_bubble = nil
    if(bubble_type == 1) then
        the_bubble = make_dark_bubble(bubble_size)
    elseif(bubble_type == 2) then
        the_bubble = make_light_bubble(bubble_size)
    else
        the_bubble = make_halo_bubble(bubble_size)
    end
    the_bubble.x = math.random(0,screen.w)
    the_bubble.y = math.random(screen.h/4, screen.h/2)
    backdrop_group:add(the_bubble)
    the_bubble:animate( {
                            duration = math.random(1000,3000),
                            y = -the_bubble.h,
                            mode = "EASE_IN_QUAD",
                            on_completed = function()
                                the_bubble:unparent()
                                make_bubble(backdrop_group)
                            end } )
end

local function make_beams(backdrop_group,beam_src)
    local beams = {}
    for i=1,4 do
        beams[i] = Clone { name = "beam"..i, source = beam_src }
        beams[i].x = math.random((i-1)*screen.w/4, i*screen.w/4)
        beams[i].y = math.random(0, screen.h/3)
        beams[i].extra.opacity_offset = math.random()
        beams[i].opacity = math.abs(2 * beams[i].opacity_offset - 1) * 128 + 32
        backdrop_group:add(beams[i])
    end

    local t = Timeline {
                            duration = 10000,
                            loop = true,
                            on_new_frame = function ( tl, elapsed, progress )
                                for i=1,4 do
                                    local spot = math.abs(2 * ((progress + beams[i].opacity_offset) % 1) - 1)
                                    beams[i].opacity = 128 * spot + 32
                                end
                            end,
                        }
    t:start()
end

local function make_zoom_zoom(group)
    local INTERVAL = 108
    local canvas = Canvas ( INTERVAL, INTERVAL*2 )
    canvas.antialias = "SUBPIXEL"
    canvas:set_source_color( "ffffff80" )

    canvas:arc(36, 54, 9, 0, 360)
    canvas:fill()

    canvas:set_source_color("40408020")
    canvas:move_to(0,0)
    canvas:line_to(0,INTERVAL*2)
    canvas:line_to(INTERVAL, INTERVAL*2)
    canvas:line_to(INTERVAL,0)
    canvas:close_path()
    canvas:fill()

    local c_image = canvas:Image( { name = "fly_bground", tile = { true, true }, width = 5760, height = 2200, x_rotation = { 90, 971, -300 }, x = -1280 } )
    local fake_group = Group{ name = "fake", children = { c_image }, y = -50 }
    group:add(fake_group)
    fake_group:lower_to_bottom()
    c_image:lower_to_bottom()
    
    c_image:animate{
        duration = 300,
        loop = true,
        z = INTERVAL*2,
    }
    --[[
    local fly_anim = Timeline {
                                duration = 180,
                                loop = true,
                                on_new_frame = function( self, msecs, progress )
                                    c_image.z = progress*INTERVAL*2
                                end,
                            }
    fly_anim:start()
    --]]
    return function()
        fake_group:animate{
            mode = "EASE_IN_QUAD",
            duration = 250,
            x = fake_group.x - INTERVAL*2,
            on_completed = function() fake_group.x = fake_group.x + INTERVAL*2 end
        }
    end,  function()
        fake_group:animate{
            mode = "EASE_IN_QUAD",
            duration = 250,
            x = fake_group.x + INTERVAL*2,
            on_completed = function() fake_group.x = fake_group.x - INTERVAL*2 end
        }
    end
end

local function make_backdrop()
    load_resources()

    local backdrop_group = Group { name = "backdrop" }

    backdrop_group:add(Clone{ name = "background", source = screen:find_child("background_img")})
    --local bubbles_and_beams = Group { name = "bubbles_and_beams" }
    --bubbles_and_beams.clip = { 0, 0, screen:find_child("background_img").w, screen:find_child("background_img").h }

--    make_beams(bubbles_and_beams,screen:find_child("beam_img"))
--[[
    for i=1,6 do
        make_bubble(bubbles_and_beams)
    end
--]]
    --backdrop_group:add(bubbles_and_beams)

    local zoom_group = Group { name = "zoom field" }
    screen:add(zoom_group)

    backdrop_group.cycle_left, backdrop_group.cycle_right = 
        make_zoom_zoom(zoom_group)

    local horizon = Group { name = "horizon" }
    local h1 = Clone { name = "horizon1", source = screen:find_child("horizon1_img") }
    h1.anchor_point = { 0, h1.h/2 }
    local h2 = Clone { name = "horizon2", source = screen:find_child("horizon2_img") }
    h2.anchor_point = { 0, h2.h/2 }
    local h3 = Clone { name = "horizon3", source = screen:find_child("horizon3_img") }
    h3.anchor_point = { 0, h3.h/2 }
    local h4 = Clone { name = "horizon4", source = screen:find_child("horizon4_img") }
    h4.anchor_point = { 0, h4.h/2 }
    horizon:add(h1,h2,h3,h4)

    horizon.y = screen:find_child("background_img").h

    zoom_group:add(horizon)

    return backdrop_group
end

return {
            make_backdrop = make_backdrop,
        }
