
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

dofile("layout.lua")

ui={}

layout(
    screen:set{size={960,540},color="000000"},
    {
        padding=10,
        columns=
        {
            {
                --left column has the question at the top and answers at the bottom
                
                size=660,
                rows=
                {
                    {
                        size=240,
                        content=Text{
                            name="question",
                            font="Diavlo,DejaVu Sans,Sans 40px" ,
                            text="Waiting for players to join..." ,
                            wrap=true,
                            color="FFFFFF"
                            }
                    }
                    ,
                    {
                        padding={left=40},
                        rows=
                            function()
                                local result={}
                                for i=1,4 do
                                    table.insert(result,
                                        {
                                            content=Text{
                                                name="answer"..i,
                                                font="Diavlo,DejaVu Sans,Sans 36px",
                                                wrap=true,
                                                color="FFFFFF",
                                                text="Answer "..i
                                                }
                                        })
                                end
                                return result
                            end
                    }
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
                        background=Rectangle{border_color=game.ANSWERED_COLOR, border_width=1, color="00000000"},
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
                            font="Diavlo,DejaVu Sans,Sans 68px",
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
local timer_box_inset = 10
local timer_box_bottom = ui.timer_group.size[2] - 5
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
    	ui.answer1.text = ""
	    ui.answer1.font="Diavlo,DejaVu Sans,Sans 40px"
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
    if tonumber(answer)==1 then
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

    print("CONNECTED",controller.name)
    
    player_joined(controller)
    
    function controller.on_disconnected(controller)
        
        print("DISCONNECTED",controller.name)
        
        player_left(controller)
        
    end
    
    function controller.on_ui_event(controller,event)
    
        print("ANSWERED",controller.name,event)
        
        player_answered(controller,event)
        
    end

end

-------------------------------------------------------------------------------
-- Get ready to play

game.questions=dofile("questions.lua")

function game.no_players()
    ui.question.text=""
    ui.answer1.text="Waiting for players to join..."
    ui.answer1.font="Diavlo,DejaVu Sans,Sans 40px"
    ui.answer1.color="FFFFFF"
    ui.answer1.opacity=255
    ui.answer2.text=""
    ui.answer3.text=""
    ui.answer4.text=""
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
    if ui.flying_answer then
        ui.flying_answer.parent:remove(ui.flying_answer)
        ui.flying_answer=nil
    end
end

function game.ready_to_start()
    ui.answer4:set{color="FFFFFF",opacity=255,text="Tap for next question..."}
    --ui.question.text="\nTap for next question..."
	ui.timer_group.opacity = 0
    game.ready=true
end

function game.ask_next_question()
    
    game.ready=false
    
    if ui.flying_answer then
        ui.flying_answer.parent:remove(ui.flying_answer)
        ui.flying_answer=nil
    end
    
    -- pick a question
    local question=table.remove(game.questions,math.random(#game.questions))
    
    ui.question.text=question[1]
    ui.question.font="Diavlo,DejaVu Sans,Sans 40px"
    
    print("CORRECT ANSWER IS",question[2])
    
    local answers={}
    
    for i=2,5 do
        table.insert(answers,{id=i-1,text=question[i]})
    end
    
    local scrambled_answers={}
    
    for i=1,4 do
        table.insert(scrambled_answers,table.remove(answers,math.random(#answers)))
    end
    
    for i=1,4 do
        local answer_box=ui["answer"..i]
        answer_box.opacity=255
        answer_box.color = "FFFFFF"
        answer_box.text=i..". "..scrambled_answers[i].text
        answer_box.extra.correct=scrambled_answers[i].id==1
    end
    
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
        controller:show_multiple_choice_ui(
        	"TP Quiz",
            scrambled_answers[1].id,
            scrambled_answers[1].text,
            scrambled_answers[2].id,
            scrambled_answers[2].text,
            scrambled_answers[3].id,
            scrambled_answers[3].text,
            scrambled_answers[4].id,
            scrambled_answers[4].text
            )
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

function game.times_up()
   
    -- score and gather flash boxes
   
    local player_boxes={}
   
    for controller,player_state in pairs(players) do
        
        if player_state.answer_time > -1 then
            player_state.score=player_state.score+game.MAX_TIME-player_state.answer_time
            player_state.ui.score.text=tostring(player_state.score)
            player_state.ui.flash_box.color = game.WIN_COLOR
        else
        	player_state.ui.flash_box.color = game.LOSE_COLOR
        	controller:clear_ui()
        end
    end
    
    -- Get the text box for the right answer, ignoring the first one
    
    local correct_answer_text=nil
    
    for i=2,4 do
        local a=ui["answer"..i]
        if a.extra.correct then
            correct_answer_text=a
        end
    end
    
    local flying_answer=nil
    local flying_answer_interval=nil
    
    if correct_answer_text then
        flying_answer=Text{
            font=correct_answer_text.font,
            text=correct_answer_text.text,
            position=correct_answer_text.position,
            size=correct_answer_text.position,
            color=correct_answer_text.color}
        correct_answer_text.parent:add(flying_answer)
        correct_answer_text.opacity=0
        flying_answer_interval=Interval(flying_answer.y,ui.answer1.y)
    end
    
    ui.flying_answer=flying_answer
    
    local timeline=Timeline{duration=1000}
    local progress = Alpha{ timeline = timeline, mode = "EASE_OUT_QUAD" }
    function timeline.on_new_frame(timeline,msecs)
        for i=1,4 do
            local a=ui["answer"..i]
            if not a.extra.correct then
                a.opacity=255-(255*progress.alpha)
                a.color = { 255, 255-(255*progress.alpha), 255-(255*progress.alpha) }
            elseif flying_answer then
                flying_answer.y=flying_answer_interval:get_value(progress.alpha)
                flying_answer.color = { 255-(255*progress.alpha), 255, 255-(255*progress.alpha) }
            else
                a.color = { 255-(255*progress.alpha), 255, 255-(255*progress.alpha) }
            end
        end
    end
    function timeline.on_completed(timeline)
        timeline.on_new_frame=nil
        timeline.on_completed=nil
        game.ready_to_start()
    end
    timeline:start()
end


function screen.on_key_down(screen,key)
    if key==keys.Return then
        if game.ready then
            game.ask_next_question()
        end
    end
end

game.no_players()

math.randomseed(os.time())
