local on_completed = nil

local unlock_group = Group {}
screen:add(unlock_group)

local background = Image { src = "assets/background/bg-1.jpg" }
unlock_group:add(background)

local logo = Image { src = 'assets/tp_logo.png', position = { -100, 100 }, scale = {2, 2}, opacity = 8 }
logo.z_rotation = { -30, logo.w/2, logo.h/2 }
unlock_group:add(logo)

local prompt = Text { color = "white", font = "FreeSans bold 64px", text = "Enter TrickPlay Code:" }
local prompt_shadow = Text { color = "black", font = prompt.font, text = prompt.text, opacity = 64 }
prompt.position = { 158, 300 }
prompt_shadow.position = { prompt.x+4, prompt.y+4 }
local prompt_scrim = Canvas ( prompt.w+64, prompt.h+36 )
prompt_scrim:round_rectangle( 0, 0, prompt.w+64, prompt.h+36, 40 )
prompt_scrim:set_source_color( "#ff101010" )
prompt_scrim:stroke(true)
prompt_scrim:set_source_color( "#ff101060" )
prompt_scrim:fill()
prompt_scrim = prompt_scrim:Image()
prompt_scrim.position = { prompt.x-32, prompt.y-18 }
unlock_group:add( prompt_shadow, prompt )

local done_button_style = {
    border = {
        width = 2,
        colors = {
            default    = {255,255,255,32},
            focus      = {255,255,255,255},
            activation = {47,100,166}
        }
    },
    text = {
        font = "FreeSans bold 60px",
        colors = {
            default    = {255,255,255,128},
            focus      = {255,255,255},
            activation = {47,100,166}
        }
    },
    fill_colors    = {
        default    = {255,255,255,16},
        focus      = {255,255,255,64},
        activation = {255,255,255,32}
    }
}

local done_button = Button {
                                x = 820,
                                y = 780,
                                w = 280,
                                h = 100,
                                style = done_button_style,
                                label = "Skip...",
                        }
done_button:move_anchor_point( 140, 50 )


local number_highlight = Canvas ( 144, 248)
number_highlight:round_rectangle( 0, 0, 144, 248, 40 )
number_highlight:set_source_color( "#ffffff60" )
number_highlight:fill()
number_highlight = number_highlight:Image( { y = 388 } )
unlock_group:add(number_highlight)

local number_holder = Canvas ( 144, 248 )
number_holder.line_width = 2
number_holder:round_rectangle( 0, 0, 144, 248, 40 )
number_holder:set_source_color( "#ffffff20" )
number_holder:stroke(true)
number_holder:set_source_linear_pattern( 72, 0, 72, 248 )
number_holder:add_source_pattern_color_stop( 0.0, "#ffffff10" )
number_holder:add_source_pattern_color_stop( 0.5, "#ffffff20" )
number_holder:add_source_pattern_color_stop( 1.0, "#ffffff40" )
number_holder:fill()
number_holder = number_holder:Image()
number_holder:hide()
unlock_group:add(number_holder)

local digit_x = { 158, 316, 474, 722, 880, 1038, 1292, 1450, 1608 }

local number_holders = {}
local number_holders_g = Group {}

local digits = {}
local digits_s = {}
for i=1,9 do
    digits[i] = Text { color = "white", font = "FreeSans bold 196px", wrap = true, alignment = "CENTER", w = 144, h = 248, y = 388, x = digit_x[i], text = "" }
    digits_s[i] = Text { color = "black", font = "FreeSans bold 196px", wrap = true, alignment = "CENTER", w = 144, h = 248, y = 388+3, x = digit_x[i]+3, text = "", opacity = 64 }
    number_holders[i] = Clone { source = number_holder, position = { digit_x[i], 388 } }
    digits[i]:move_anchor_point( 72, 124 )
    digits_s[i]:move_anchor_point( 72, 124 )
end


local highlight_state = AnimationState {
                                            duration  = 150,
                                            mode = "EASE_IN_OUT_SINE",
                                            transitions = {
                                                {
                                                    source = "*",
                                                    target = "1",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[1] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "2",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[2] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "3",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[3] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "4",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[4] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "5",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[5] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "6",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[6] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "7",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[7] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "8",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[8] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "9",
                                                    keys = {
                                                            { number_highlight, "x", digit_x[9] },
                                                            { number_highlight, "opacity", 255 },
                                                            { number_holders_g, "opacity", 255 },
                                                            { prompt, "opacity", 255 },
                                                            { prompt_shadow, "opacity", 255 },
                                                        },
                                                },
                                                {
                                                    source = "*",
                                                    target = "10",
                                                    keys = {
                                                            { number_highlight, "opacity", 0 },
                                                            { number_holders_g, "opacity", 0 },
                                                            { prompt, "opacity", 0 },
                                                            { prompt_shadow, "opacity", 0 },
                                                        },
                                                }
                                            },
                                        }

local function show_enter_code_screen()
    unlock_group:add(done_button)

    number_holders_g:add(unpack(number_holders))
    unlock_group:add( number_holders_g )
    unlock_group:add(unpack(digits_s))
    unlock_group:add(unpack(digits))

    highlight_state:warp("1")
end

done_button.on_released = function()
    local number = ""
    if(done_button.label == "Register") then
        for i=1,9 do
            if(digits[i].text == "") then
                print("ENTER PRESSED BUT NUMBER NOT COMPLETE")
                return
            end
            number = number..digits[i].text
        end
    end
    screen.on_key_down = nil
    dolater(150, on_completed, number )
end

local previous_position = 1
local function unlock_key_handler(screen, key)
    local current_state = highlight_state.state + 0

    if(key == keys.Right) then
        highlight_state.state = math.min(current_state+1,10)..""
    elseif(key == keys.Left) then
        highlight_state.state = math.max(current_state-1,1)..""

    elseif(key == keys.BACK) then
        for i=1,9 do
            digits[i].text = ""
            digits_s[i].text = ""
        end
        highlight_state.state = "1"

    elseif(key >= keys["0"] and key <= keys["9"] and current_state >= 1 and current_state <= 9) then
        digits[current_state].text = (key - keys["0"])..""
        digits_s[current_state].text = digits[current_state].text
        digits[current_state]:animate( { duration = 100, scale = { 1.1, 1.1 }, on_completed = function() digits[current_state]:animate( { duration = 150, scale = {1,1} } ) end } )
        digits_s[current_state]:animate( { duration = 100, scale = { 1.1, 1.1 }, on_completed = function() digits_s[current_state]:animate( { duration = 150, scale = {1,1} } ) end } )
        highlight_state.state = math.min(current_state+1,10)..""

    elseif(key == keys.Down and current_state >= 1 and current_state <= 9 ) then
        previous_position = current_state
        highlight_state.state = "10"

    elseif(key == keys.Up and current_state == 10) then
        highlight_state.state = previous_position..""

    end
end

function highlight_state:on_completed()
    if(highlight_state.state == "10") then
        done_button:grab_key_focus()
        done_button:animate( { duration = 100, scale = { 1.2, 1.2 }, on_completed = function() done_button:animate( { duration = 150, scale = {1,1} } ) end } )
    else
        screen:grab_key_focus()
    end

    for i=1,9 do
        if(digits[i].text == "") then
            done_button.label = "Skip..."
            return
        end
    end
    previous_position = 9
    done_button.label = "Register"
end


function start_unlock_code(callback)
    on_completed = function(code)
                        if callback then callback(code) end
                        background = nil
                        logo = nil
                        prompt = nil
                        prompt_shadow = nil
                        prompt_scrim = nil
                        done_button = nil
                        number_highlight = nil
                        highlight_state = nil
                        number_holder = nil
                        digit_x = nil
                        digits = nil
                        digits_s = nil
                        unlock_group:unparent()
                        unlock_group = nil
                        start_unlock_code = nil
                        collectgarbage()
                    end
    show_enter_code_screen()

    screen.on_key_down = unlock_key_handler
end
