
-------------------------------------------------------------------------------

local trickplay_red = "960A04"

game={
		MAX_TIME = 5,
		WIN_COLOR = "55FF5533",
		LOSE_COLOR = trickplay_red.."99",
		WAITING_FOR_ANSWER_COLOR = "000000",
		ANSWERED_COLOR = trickplay_red.."99",
		BORDER_COLOR = "FFFFFF40",
	}


-------------------------------------------------------------------------------
-- Setup the UI

local NUMBER_FONT_SIZE = 120 * 1080/screen.h

math.randomseed(os.time())

-- Place blackboard behind content
screen:add(Image { src="assets/chalkboard-background.png", size={screen.w,screen.h}, z = -1 })

local ui ={}

ui.question_answer = Group { x = 2*screen.w/12, y = 2*screen.h/6 }
ui.bigger_number = Text{
                            font="Eraser,DejaVu Sans,Sans "..NUMBER_FONT_SIZE.."px" ,
                            text="" ,
                            wrap=true,
                            color="FFFFFFC0",
                            y = 0,
                            }
ui.littler_number = Text{
                            font="Eraser,DejaVu Sans,Sans "..NUMBER_FONT_SIZE.."px" ,
                            text="" ,
                            wrap=true,
                            color="FFFFFFC0",
                            y = screen.h/6,
                            }
ui.underline = Image {
							src = "assets/underline.png",
							x = -screen.w/12,
							y = 2*screen.h/6,
						}
ui.answer = Text{
						font="Eraser,DejaVu Sans,Sans "..NUMBER_FONT_SIZE.."px" ,
						text="" ,
						wrap=true,
						color="FFFFFFC0",
						y = 9*screen.h/24,
					}
ui.question_answer:add(ui.bigger_number)
ui.question_answer:add(ui.littler_number)
ui.question_answer:add(ui.underline)
ui.question_answer:add(ui.answer)
screen:add(ui.question_answer)

ui.instructions_label = Text{
							font = "Eraser,DejaVu Sans,Sans "..(NUMBER_FONT_SIZE*2/3).."px" ,
							text = "",
							wrap = true,
							color = "FFFFFFC0",
							x = screen.w/6,
							y = screen.h/3,
							width = screen.w*1/3,
					}
screen:add(ui.instructions_label)

ui.timer_group = Group { position = { screen.w*1/3, screen.h*9/16 } }
ui.bomb = Image {
					src = "assets/bomb.png",
					size = { 299*screen.w/2800, 471*screen.h/1575 },
				}
ui.timer_group:add(ui.bomb)
ui.timer = Text{
                            name="timer",
                            font="Eraser,DejaVu Sans,Sans "..(NUMBER_FONT_SIZE*4/5).."px",
                            single_line=true,
                            color="00FF00",
                            text=tostring(game.MAX_TIME),
				}
ui.timer.position = {	1/2*(ui.bomb.w - ui.timer.w),
						2/3*ui.bomb.h - 1/2*ui.timer.h
					}

ui.timer_group:add(ui.timer)
ui.soot = Image {
					src = "assets/soot.png",
					opacity = 0,
					z = 5,
				}
ui.soot:move_anchor_point(ui.timer_group.x + ui.bomb.w/2, ui.timer_group.y + ui.bomb.h/2)
ui.soot.x = ui.timer_group.x + ui.bomb.w/2
ui.soot.y = ui.timer_group.y + ui.bomb.h/2
ui.soot.scale = { 0.01, 0.01, 0, 0 }
screen:add(ui.soot)

screen:add(ui.timer_group)

ui.players_box_rect = Rectangle{
									border_color=game.BORDER_COLOR,
									border_width=1,
									color="00000010",
									size = { screen.w*7/16, screen.h/2 },
									position = { screen.w*1/2, screen.h*1/3 },
								}
ui.players_box = Group { position = ui.players_box_rect.position, size = ui.players_box_rect.size }
screen:add(ui.players_box_rect)
screen:add(ui.players_box)

screen:show_all()

-------------------------------------------------------------------------------
-- table to hold our player information - the keys are the actual controller
-- instances, the values are tables to hold whatever we want

players={}

function player_count()
    local result=0
    for k,v in pairs(players) do
        result=result+1
    end
    return result
end

function player_joined(controller)

    -- When a player joins, we have to add a box for him, so we have to figure
    -- out where to put it

    local group=ui.players_box
    local children=group.children
    local top=0

    for k,child in pairs(children) do
        local bottom=child.y+child.h
        if bottom > top then
            top = bottom
        end
    end

	player_ui = {}

	player_ui.flash_box = Rectangle{
										border_color = game.BORDER_COLOR,
										border_width = 1,
										color=game.ANSWERED_COLOR,
										size = { group.w, group.h/4 }
									}
	player_ui.label = Text{font="Eraser,DejaVu Sans,Sans "..(NUMBER_FONT_SIZE*2/5).."px",text=controller.name,color="FFFFFF"}
	player_ui.score = Text{font="Eraser,DejaVu Sans,Sans "..(NUMBER_FONT_SIZE*4/5).."px",text="0",color="FFFFFF"}
	player_ui.player_box = Group {
								position = {0, top},
								size = { group.w, group.h/4 },
								children = {
												player_ui.flash_box,
												player_ui.label,
												player_ui.score
											}
								}

	-- Center the elements in the container
	player_ui.label.x = (NUMBER_FONT_SIZE*2/5)/2
	player_ui.label.y = (player_ui.player_box.h - player_ui.label.h)/2
	player_ui.score.x = player_ui.player_box.w - player_ui.score.w - (NUMBER_FONT_SIZE*4/5)/2
	player_ui.score.y = (player_ui.player_box.h - player_ui.score.h)/2

    -- TODO: animate
	print("Adding stuff for player",controller.name)
    group:add(player_ui.player_box)

    players[controller]={box=player_ui.player_box,ui=player_ui,score=0,answer_time=-1}

    if player_count()>=1 then
    	ui.instructions_label.opacity = 0
	    ui.players_box_rect.opacity = 255
        game.ready_to_start()
    end
end

--------------------------------------------------------------------------------
-- When a player leaves, we remove his/her box

function player_left(controller)

    local player_table=players[controller]
    
    if player_table then
        
		if player_table.answer_time > 0 then
			game.num_answered = game.num_answered - 1
		end
        local box=player_table.box
        local group=ui.players_box
        local children=group.children
        local to_move={}
        
        -- Collect all the player boxes below the one that is leaving
        
        for k,child in pairs(children) do
            if child.y>box.y then
                to_move[child]=Interval(child.y,child.y-box.h)
            end
        end
        
        -- Now, move them all up and fade out this one
        
        local timeline=Timeline{duration=250}
        function timeline.on_new_frame(timeline,msecs,progress)
            for child,interval in pairs(to_move) do
                child.y=interval:get_value(progress)
            end
            box.opacity=255-(255*progress)
        end
        function timeline.on_completed(timeline)
            timeline.on_new_frame=nil
            timeline.on_completed=nil
            group:remove(box)
        end
        
        timeline:start()
        
        players[controller]=nil
        
        if player_count()==0 then
            game.no_players()
        end
    end    
end

-------------------------------------------------------------------------------

function player_answered(controller,answer)
    if answer==game.answer then
        players[controller].answer_time=game.time
    else
        players[controller].answer_time=-1
    end
    game.num_answered = game.num_answered+1
    players[controller].ui.flash_box.color=game.ANSWERED_COLOR;    
end

-------------------------------------------------------------------------------
-- Hook up the connect, disconnect and ui controller events and call
-- the functions above

function controllers.on_controller_connected(controllers,controller)

	controller:declare_resource("quiz","assets/quiz.png")
	controller:declare_resource("numbers","assets/numbers.png")
	controller:set_ui_background("quiz")

	controller.on_key_down = function ( controller, key )
		if key >= keys.KP_0 and key <= keys.KP_9 then
			player_answered(controller, key - keys.KP_0)
		elseif key >= keys["0"] and key <= keys["9"] then
			player_answered(controller, key - keys["0"])
		end
	end


    print("CONNECTED",controller.name)
    
    player_joined(controller)
    
    function controller.on_disconnected(controller)
        
        print("DISCONNECTED",controller.name)
        
        player_left(controller)
        
    end
end

-------------------------------------------------------------------------------
-- Get ready to play

function game.no_players()
	ui.question_answer.opacity = 0
	ui.instructions_label.opacity = 255
	ui.instructions_label.text = "Press ENTER, or join to play..."
    ui.players_box_rect.opacity = 0
    ui.timer.text=""
	ui.timer_group.opacity = 0
    for controller,player_state in pairs(players) do
        player_state.ui.flash_box.color=game.WAITING_FOR_ANSWER_COLOR
    end
    if game.timer then
        game.timer:stop()
        game.timer.on_timer=nil
        game.timer=nil
    end
    game.ready=false
end

function game.ready_to_start()
	ui.question_answer.opacity=0
	ui.instructions_label.opacity = 255
    ui.instructions_label.text="ENTER or tap for next problem..."
	ui.timer_group.opacity = 0
    game.ready=true
end

function game.ask_next_question()

    game.ready=false

    -- pick a question
    game.answer = math.random(0,9)
    local littler_number = math.random(1,10)
    local bigger_number = littler_number + game.answer

    ui.bigger_number.text=tostring(bigger_number)
	ui.littler_number.text = tostring(littler_number).." -"
	ui.answer.text = "???"

	ui.instructions_label.opacity = 0
	ui.question_answer.opacity = 255

    print("CORRECT ANSWER IS",game.answer)

    ui.timer.text=tostring(game.MAX_TIME)
	ui.timer.position = { 1/2*(ui.bomb.w - ui.timer.w),
							2/3*ui.bomb.h - 1/2*ui.timer.h,
						}
    ui.timer.color = "00FF00"
    ui.timer_group.opacity = 255
    ui.timer_group.scale = { 1, 1 }
    ui.timer_group.z = 0
    ui.soot.opacity = 0
	ui.bomb.z_rotation = {
							45,
							1/2*(ui.bomb.w),
							2/3*(ui.bomb.h)
						}
--	ui.bomb:animate( { duration = 50, z_rotation = 40, loop = true } )

	game.num_answered = 0
    for controller,player_state in pairs(players) do
        player_state.answer_time=-1
        player_state.ui.flash_box.color=game.WAITING_FOR_ANSWER_COLOR
		controller:set_ui_background("numbers")

		function controller.on_click(controller, x, y)
			if not game.got_tap then
				game.got_tap = true
				return
			end
			local the_answer
	
			-- The boundaries of the numbers are all on the 100s, rows and columns both
			local row = math.floor(y/100)
			local column = math.ceil(x/100)
	
			-- 0 is in a special place
			if row == 3 and column == 2 then
				the_answer = 0
			else
				the_answer = row*3 + column
			end
	
			print("ANSWERED",controller.name,the_answer,x,y)
	
			player_answered(controller,the_answer)

			-- disable additional clicks
			controller.on_click = nil

			-- reset background picture
			controller:set_ui_background("quiz")
		end
    end

    game.time=0
    game.timer=Timer(1)
    function game.timer.on_timer(timer)
        game.time=game.time+1
        ui.timer.text=tostring(game.MAX_TIME-game.time)
		ui.timer.position = { 1/2*(ui.bomb.w - ui.timer.w),
								2/3*ui.bomb.h - 1/2*ui.timer.h,
							}
		if game.time<=game.MAX_TIME/3 then
			ui.timer.color = "00FF00"
		elseif game.time<=2*game.MAX_TIME/3 then
			ui.timer.color = "FFFF00"
		else
			ui.timer.color = "FF0000"
		end
        if game.time==game.MAX_TIME or game.num_answered >= player_count() then
            game.timer=nil
            game.times_up()
            return false
        end
    end
    game.timer:start()
end

function game.times_up(correct_answer)

    -- score and gather flash boxes

    local player_boxes={}

    for controller,player_state in pairs(players) do

        if player_state.answer_time > -1 then
            player_state.score=player_state.score+game.MAX_TIME-player_state.answer_time
            player_state.ui.score.text=tostring(player_state.score)
			player_state.ui.score.x = player_state.ui.player_box.w - player_state.ui.score.w - (NUMBER_FONT_SIZE*4/5)/2
            player_state.ui.flash_box.color = game.WIN_COLOR
        else
        	player_state.ui.flash_box.color = game.LOSE_COLOR
			controller:set_ui_background("quiz")
        end
    end

	if game.time==game.MAX_TIME then
		ui.bomb:complete_animation()
		ui.timer_group:animate({ duration = 500, z = 1000, opacity = 0, mode = "EASE_OUT_SINE" })
		ui.soot:animate({ duration = 250, scale = { 1, 1 }, opacity = 200, mode = "EASE_OUT_SINE" })
	end

	game.ready_to_start()
end

function screen.on_key_down(screen,key)
    if key==keys.Return then
        if game.ready then
       		game.got_tap = false
            game.ask_next_question()
        end
	end
end

game.no_players()

for _,controller in pairs(controllers.connected) do
    controllers:on_controller_connected(controller)
end
