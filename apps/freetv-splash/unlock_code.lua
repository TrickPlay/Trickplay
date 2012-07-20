local on_completed = nil

local unlock_group = Group {}
screen:add(unlock_group)

local prompt = Text { color = "white", font = "FreeSans bold 92px", text = "Please enter activation code" }
unlock_group:add( prompt )
local logo = Image { src = 'assets/tp_logo.png', position = { -100, 100 }, scale = {2, 2}, opacity = 8 }
logo.z_rotation = { -30, logo.w/2, logo.h/2 }
unlock_group:add(logo)


local skip_button = Button { x = 280, y = 850, label = "Skip" }
local done_button = Button { x = 1640-skip_button.w, y = 850, label = "Done" }

local number_highlight = Canvas ( 144, 248)
number_highlight:round_rectangle( 0, 0, 144, 248, 40 )
number_highlight:set_source_color( "#ffffff40" )
number_highlight:fill()
number_highlight = number_highlight:Image( { y = 388 } )
unlock_group:add(number_highlight)

local digit_x = { 158, 316, 474, 722, 880, 1038, 1292, 1450, 1608 }

local highlight_state = AnimationState {
                                            duration  = 150,
                                            mode = "EASE_IN_OUT_SINE",
                                            transitions = {
                                                {
                                                    source = "*",
                                                    target = "1",
                                                    keys = { { number_highlight, "x", digit_x[1] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "2",
                                                    keys = { { number_highlight, "x", digit_x[2] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "3",
                                                    keys = { { number_highlight, "x", digit_x[3] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "4",
                                                    keys = { { number_highlight, "x", digit_x[4] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "5",
                                                    keys = { { number_highlight, "x", digit_x[5] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "6",
                                                    keys = { { number_highlight, "x", digit_x[6] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "7",
                                                    keys = { { number_highlight, "x", digit_x[7] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "8",
                                                    keys = { { number_highlight, "x", digit_x[8] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "9",
                                                    keys = { { number_highlight, "x", digit_x[9] }, { number_highlight, "opacity", 255 } },
                                                },
                                                {
                                                    source = "*",
                                                    target = "10",
                                                    keys = { { number_highlight, "opacity", 0 } },
                                                }
                                            },
                                        }
local number_holder = Canvas ( 144, 248 )
number_holder.line_width = 2
number_holder:round_rectangle( 0, 0, 144, 248, 40 )
number_holder:set_source_color( "#ffffff10" )
number_holder:stroke(true)
number_holder:set_source_linear_pattern( 72, 0, 72, 248 )
number_holder:add_source_pattern_color_stop( 0.0, "#ffffff08" )
number_holder:add_source_pattern_color_stop( 0.5, "#ffffff10" )
number_holder:add_source_pattern_color_stop( 1.0, "#ffffff20" )
number_holder:fill()
number_holder = number_holder:Image()
number_holder:hide()
unlock_group:add(number_holder)

local digits = {}

function highlight_state:on_completed()
    for i=1,9 do
        if(digits[i].text == "") then
            skip_button:grab_key_focus()
            return
        end
    end
    done_button:grab_key_focus()
end


local function show_enter_code_screen()
    prompt.position = { (screen.w-prompt.w)/2, screen.h/10 }

    unlock_group:add( Clone { source = number_holder, position = { digit_x[1] , 388 } } )
    unlock_group:add( Clone { source = number_holder, position = { digit_x[2] , 388 } } )
    unlock_group:add( Clone { source = number_holder, position = { digit_x[3] , 388 } } )

    unlock_group:add( Clone { source = number_holder, position = { digit_x[4] , 388 } } )
    unlock_group:add( Clone { source = number_holder, position = { digit_x[5] , 388 } } )
    unlock_group:add( Clone { source = number_holder, position = { digit_x[6] , 388 } } )

    unlock_group:add( Clone { source = number_holder, position = { digit_x[7] , 388 } } )
    unlock_group:add( Clone { source = number_holder, position = { digit_x[8] , 388 } } )
    unlock_group:add( Clone { source = number_holder, position = { digit_x[9] , 388 } } )

    unlock_group:add(skip_button, done_button)

    dolater(skip_button.grab_key_focus, skip_button)

    for i=1,9 do
        digits[i] = Text { color = "white", font = "FreeSans bold 196px", wrap = true, alignment = "CENTER", w = 144, h = 248, y = 388, x = digit_x[i], text = "" }
    end
    unlock_group:add(unpack(digits))

    highlight_state:warp("1")
end

local function done_button_handler()
    local number = ""
    for i=1,9 do
        if(digits[i].text == "") then
            print("ENTER PRESSED BUT NUMBER NOT COMPLETE")
            return
        end
        number = number..digits[i].text
    end
    print("CODE NUMBER:",number)
    if(on_completed) then
        dolater(150, unlock_group.unparent, unlock_group)
        dolater(150,on_completed)
end

local function skip_button_handler()
    print("SKIP")
end

local function unlock_key_handler(screen, key)
    local current_state = highlight_state.state + 0

    if(key == keys.Right) then
        highlight_state.state = math.min(current_state+1,10)..""
    elseif(key == keys.Left) then
        highlight_state.state = math.max(current_state-1,1)..""

    elseif(key == keys.BACK) then
        for i=1,9 do
            digits[i].text = ""
        end
        highlight_state.state = "1"

    elseif(key >= keys["0"] and key <= keys["9"] and current_state >= 1 and current_state <= 9) then
        digits[current_state].text = (key - keys["0"])..""
        highlight_state.state = math.min(current_state+1,10)..""

    end
end

function do_unlock_code(callback)
    on_completed = callback
    show_enter_code_screen()

    screen.on_key_down = unlock_key_handler
    done_button:add_key_handler(keys.OK, done_button_handler)
    skip_button:add_key_handler(keys.OK, skip_button_handler)
end
