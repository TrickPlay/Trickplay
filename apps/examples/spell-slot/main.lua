
-------------------------------------------------------------------------------

local trickplay_red = "960A04"

game={
		MAX_TIME = 15,
		WIN_COLOR = "55FF5533",
		LOSE_COLOR = trickplay_red.."99",
		WAITING_FOR_ANSWER_COLOR = "000000",
		ANSWERED_COLOR = trickplay_red.."99",
	}


-------------------------------------------------------------------------------
-- Setup the UI

math.randomseed(os.time())

dofile("layout.lua")

ui={}

-- Place a semi-transparent curtain behind content
screen:add(Rectangle { size={screen.w,screen.h}, color="00000080" })


layout(
    screen,
    {
        padding=10,
        columns=
        {
            {
                --left column has the question at the top and spinning numbers at the bottom
                
                size=660,
                rows=
                {
                    {
	                	padding={top=20, left=20, right=20},
                        content=Text{
                            name="bigger_number",
                            font="Diavlo,DejaVu Sans,Sans 40px" ,
                            text="" ,
                            wrap=true,
                            color="FFFFFF",
                            }
                    }
                    ,
                    {
	                	padding={top=20, left=20, right=20},
                        content=Text{
                            name="littler_number",
                            font="Diavlo,DejaVu Sans,Sans 40px" ,
                            text="Waiting for players to join..." ,
                            wrap=true,
                            color="FFFFFF"
                            }
                    }
                    ,
                    {
	                	padding={top=20, left=20, right=20},
                        content=Text{
                            name="answer",
                            font="Diavlo,DejaVu Sans,Sans 40px" ,
                            text="" ,
                            wrap=true,
                            color="FFFFFF",
                            }
                    }
                    ,
                }
            }
            ,
            {
                -- right column has the countdown timer and a group for players
                
                rows=
                {
                    {
                        size=120,
                        padding=0,
						content=Group { name = "timer_group" }
                    }
                    ,
                    {
                        background=Rectangle{border_color=game.ANSWERED_COLOR, border_width=1, color="00000000", name = "players_box_rect", opacity=0 },
                        padding=10,
                        group=Group{name="players_box"}
                    }
                }
            
            }
        }
    }
    ,
    ui
):show_all()

ui.timer = Text{
                            name="timer",
                            font="Diavlo,DejaVu Sans,Sans 64px",
                            single_line=true,
                            color="00FF00",
                            text=tostring(game.MAX_TIME),
                            }
ui.timer.position = {	(ui.timer_group.size[1] - ui.timer.size[1]) / 2,
						(ui.timer_group.size[2] - ui.timer.size[2]) / 2
					}
ui.timer_label = Text{
							color="FFFFFF",
							font="Sans 24px",
							single_line=true,
							text="Countdown",
				}
ui.timer_label.position = { (ui.timer_group.size[1] - ui.timer_label.size[1]) / 2,
						0
					}
ui.timer_box = Canvas{
						size = { ui.timer_group.size[1], ui.timer_group.size[2] }
					}
ui.timer_box:begin_painting()
ui.timer_box:set_source_color("FFFFFF")
local timer_box_top = ui.timer_label.y + ui.timer_label.size[2]/2
local timer_box_inset = 0
local timer_box_bottom = ui.timer_group.size[2] - (timer_box_inset + 10)
local timer_box_ratio = 4/5
ui.timer_box:move_to(timer_box_ratio * ui.timer_label.x, timer_box_top)
ui.timer_box:line_to(timer_box_inset, timer_box_top)
ui.timer_box:line_to(timer_box_inset, timer_box_bottom)
ui.timer_box:line_to(ui.timer_group.size[1] - timer_box_inset, timer_box_bottom)
ui.timer_box:line_to(ui.timer_group.size[1] - timer_box_inset, timer_box_top)
ui.timer_box:line_to(ui.timer_group.size[1] - timer_box_ratio * ui.timer_label.x, timer_box_top)
ui.timer_box:stroke()
ui.timer_box:finish_painting()

ui.timer_group:add(ui.timer_box)
ui.timer_group:add(ui.timer_label)
ui.timer_group:add(ui.timer)

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
    
    local player_box , player_ui=
    
        layout(
            Group{position={0,top},size={group.w,group.h/8}},
            {
                padding_bottom=4,
                content=Rectangle{color=game.ANSWERED_COLOR,name="flash_box"},
                columns=
                {
                    {
                        size=5/6,
                        content=Text{font="Diavlo,DejaVu Sans,Sans 24px",text=controller.name,color="FFFFFF",name="label"}
                    }
                    ,
                    {
                        content=Text{font="Diavlo,DejaVu Sans,Sans 24px",text="0",color="FFFFFF",name="score"}
                    }
                }
            }
        )

	-- Vertically center the elements in the container
	player_ui.label.position = {player_ui.label.x + 8, player_ui.label.y + 10}
	player_ui.score.position = {player_ui.score.x, player_ui.score.y + 10}

    -- TODO: animate
    
    group:add(player_box)
    
    players[controller]={box=player_box,ui=player_ui,score=0,answer_time=-1}
    
    if player_count()>=1 then
    	ui.littler_number.text = ""
	    ui.littler_number.font = "Diavlo,DejaVu Sans,Sans 40px"
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

	controller:declare_resource("quiz","http://10.0.190.103/quiz.png")
	controller:declare_resource("numbers","http://10.0.190.103/numbers.png")
	controller:set_background("quiz")

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
    ui.littler_number.text="Waiting for players to join..."
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
    ui.littler_number.text="Tap for next problem..."
	ui.timer_group.opacity = 0
    game.ready=true
end

function game.ask_next_question()

    game.ready=false

    -- pick a question
    local littler_number = math.random(0,9)
    local bigger_number = math.random(littler_number,littler_number+9)
    game.answer = bigger_number - littler_number
    local question = bigger_number.." - "..littler_number.." = ___"

    ui.bigger_number.text=tostring(bigger_number)
	ui.littler_number.text = tostring(littler_number)
	ui.answer.text = "???"
    
    print("CORRECT ANSWER IS",game.answer)

    ui.timer.text=tostring(game.MAX_TIME)
	ui.timer.position = { (ui.timer_group.size[1] - ui.timer.size[1]) / 2,
							40
						}
    ui.timer.color = "00FF00"
    ui.timer_group.opacity = 255


	game.num_answered = 0
    for controller,player_state in pairs(players) do
        player_state.answer_time=-1
        player_state.ui.flash_box.color=game.WAITING_FOR_ANSWER_COLOR
		controller:set_background("numbers")

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
			controller:set_background("quiz")
		end
    end

    game.time=0
    game.timer=Timer(1)
    function game.timer.on_timer(timer)
        game.time=game.time+1
        ui.timer.text=tostring(game.MAX_TIME-game.time)
		ui.timer.position = { (ui.timer_group.size[1] - ui.timer.size[1]) / 2,
								40
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
            player_state.ui.flash_box.color = game.WIN_COLOR
        else
        	player_state.ui.flash_box.color = game.LOSE_COLOR
			controller:set_background("quiz")
        end
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
