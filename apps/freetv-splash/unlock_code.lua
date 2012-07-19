local prompt = Text { color = "white", font = "FreeSans bold 92px", text = "Please enter activation code" }
screen:add( prompt )

local number_highlight = Canvas ( 144, 248)
number_highlight:round_rectangle( 0, 0, 144, 248, 40 )
number_highlight:set_source_color( "#ffffff40" )
number_highlight:fill()
number_highlight = number_highlight:Image()
screen:add(number_highlight)

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
screen:add(number_holder)

local function show_enter_code_screen()
    prompt.position = { (screen.w-prompt.w)/2, screen.h/10 }

    screen:add( Clone { source = number_holder, position = { 158 , 388 } } )
    screen:add( Clone { source = number_holder, position = { 316 , 388 } } )
    screen:add( Clone { source = number_holder, position = { 474 , 388 } } )

    screen:add( Clone { source = number_holder, position = { 722 , 388 } } )
    screen:add( Clone { source = number_holder, position = { 880 , 388 } } )
    screen:add( Clone { source = number_holder, position = { 1038 , 388 } } )

    screen:add( Clone { source = number_holder, position = { 1292 , 388 } } )
    screen:add( Clone { source = number_holder, position = { 1450 , 388 } } )
    screen:add( Clone { source = number_holder, position = { 1608 , 388 } } )

    local skip_button = Button { x = 280, y = 850, label = "Skip", focused = true, selected = true }
    local done_button = Button { x = 1640-skip_button.w, y = 850, label = "Done" }

    screen:add(skip_button, done_button)

    number_highlight.position = { 158, 388 }
end

function do_unlock_code()
    show_enter_code_screen()
end
