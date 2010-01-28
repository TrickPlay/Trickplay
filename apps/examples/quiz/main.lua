
-------------------------------------------------------------------------------

game={}

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
                            font="Enchanted,Graublau Web,DejaVu Sans,Sans 48px" ,
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
                                                font="Enchanted,Graublau Web,DejaVu Sans,Sans 36px",
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
                        padding={left=80},
                        content=Text{
                            name="timer",
                            font="Enchanted,Graublau Web,DejaVu Sans,Sans 96px",
                            single_line=true,
                            color="FFFFFF",
                            text="30"
                            }
                    }
                    ,
                    {
                        background=Rectangle{color="FF000033"},
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
                content=Rectangle{color="00000000",name="flash_box"},
                columns=
                {
                    {
                        size=2/3,
                        content=Text{font="Enchanted,Graublau Web,DejaVu Sans,Sans 24px",text=controller.name,color="FFFFFF"}
                    }
                    ,
                    {
                        padding={left=8},
                        content=Text{font="Enchanted,Graublau Web,DejaVu Sans,Sans 24px",text="0",color="FFFFFF",name="score"}
                    }
                }
            }
        )
        
    -- TODO: animate
    
    group:add(player_box)
    
    players[controller]={box=player_box,ui=player_ui,score=0,answer_time=-1}
    
    if player_count()==1 then
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
    players[controller].ui.flash_box.color="00CCCC"    
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
    ui.question.text="Waiting for players to join..."
    ui.answer1.text=""
    ui.answer2.text=""
    ui.answer3.text=""
    ui.answer4.text=""
    ui.timer.text=""
    for controller,player_state in pairs(players) do
        player_state.ui.flash_box.color="00000000"
    end
    if game.timer then
        game.timer:stop()
        game.timer.on_timer=nil
        game.timer=nil
    end
end

function game.ready_to_start()
    ui.question.text="Tap to start..."
    game.ready=true
end

function game.ask_next_question()
    
    game.ready=false
    
    -- pick a question
    local question=table.remove(game.questions,math.random(#game.questions))
    
    ui.question.text=question[1]
    
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
        answer_box.text=i..". "..scrambled_answers[i].text
        answer_box.extra.correct=scrambled_answers[i].id==1
    end
    
    ui.timer.text="30"

	game.num_answered = 0
    for controller,player_state in pairs(players) do
        player_state.answer_time=-1
        player_state.ui.flash_box.color="FF0000"
        controller:show_multiple_choice_ui(
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
        ui.timer.text=tostring(30-game.time)
        print("ANSWERED SO FAR: "..game.num_answered)
        if game.time==30 or game.num_answered >= player_count() then
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
            player_state.score=player_state.score+30-player_state.answer_time
            player_state.ui.score.text=tostring(player_state.score)
        end
    end
    
    local timeline=Timeline{duration=1000}
    function timeline.on_new_frame(timeline,msecs,progress)
        for i=1,4 do
            local a=ui["answer"..i]
            if not a.extra.correct then
                a.opacity=255-(255*progress)
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
