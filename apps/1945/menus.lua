modal_title = "kroeger 06_65 140px"
modal_font  = "kroeger 06_65 70px"

local max_level = 4

Menu_Game_Over_Save_Highscore = Class(function(menu, ...)
    
    menu.group = Group{}
    menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="GAME OVER",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local h_score_val = Text{text="000000",    font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-200}
    local h_score_txt = Text{text="HIGH SCORE!",font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-110}
    local init_here   = Text{text="Enter your initials:",font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2+200}
    local arrow_up    = Image{src="assets/splash/Arrow.png", x = screen_w/2-95, y = screen_h-200, z_rotation={-90,0,0}}
    local arrow_dn    = Image{src="assets/splash/Arrow.png", x = screen_w/2-55, y = screen_h-100, z_rotation={90,0,0}}

    init_here.anchor_point = {init_here.w/2,init_here.h/2}
    menu.initials = {
        Text{font = modal_font , text = "" , color = "FFFFFF",x=screen_w/2-100, y=screen_h-200},
        Text{font = modal_font , text = "" , color = "FFFFFF",x=screen_w/2,    y=screen_h-200},
        Text{font = modal_font , text = "" , color = "FFFFFF",x=screen_w/2+100, y=screen_h-200},
    }
    
    menu.group:add(title,h_score_val,h_score_txt,init_here,
        menu.initials[1],menu.initials[2],menu.initials[3], arrow_up, arrow_dn
    )
    
    layers.splash:add(menu.group)
    menu.group:hide()
    
    local initial_index = 1
    local index_to_be   = 0
    local h_score_to_be = 0
    local medals = {}
    
    function menu:animate_in(highscore,index,no_delay)
        
        local m
        local upper = state.curr_level-1
        if no_delay ~= nil then upper = state.curr_level end
        for i = 1, upper do
            m = Clone{source=imgs["medal_"..i], x=screen_w/2-100-200*(i-1),y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        end 
        
        menu.initials[1].text = "A"
        menu.initials[2].text = "A"
        menu.initials[3].text = "A"
        arrow_up.x = screen_w/2-95
        arrow_dn.x = screen_w/2-55
        initial_index    = 1
        index_to_be      = index
        h_score_to_be    = highscore
        h_score_val.text = string.format("%06d",highscore).." pts"
        
        
        local iii = 3000
        if no_delay then iii = 100 end
        local timer = Timer{interval=iii}
        timer.on_timer = function()
            remove_all_from_render_list()
            menu.group:show()
            menu.group.opacity=255
            state.curr_mode = "GAME_OVER_SAVE"
            timer:stop()
            timer = nil
        end
        timer:start()
    end
    
    function menu:animate_out()
        menu.group:hide()
    end
    
    menu.h_score_menu=nil
    function menu:set_ptr_to_h_scores(obj)
        menu.h_score_menu = obj
    end
    menu.keys = {
        [keys.Up]     = function()
            local byte = string.byte(menu.initials[initial_index].text)+1
            if byte > 95 then
                byte = 65
            end
            menu.initials[initial_index].text = string.char(byte)
        end,
        [keys.Down]   = function()
            local byte = string.byte(menu.initials[initial_index].text)-1
            if byte < 65 then
                byte = 95
            end
            menu.initials[initial_index].text = string.char(byte)
        end,
        [keys.Left]   = function()
            if initial_index - 1 >= 1 then
                initial_index = initial_index - 1
                arrow_up.x = arrow_up.x-100
                arrow_dn.x = arrow_dn.x-100
            end
        end,
        [keys.Right]  = function()
            if initial_index + 1 <= #menu.initials then
                initial_index = initial_index + 1
                arrow_up.x = arrow_up.x+100
                arrow_dn.x = arrow_dn.x+100
            end
        end,
        [keys.Return] = function()
            assert(index_to_be > 0 and index_to_be < 11)
            local m = state.curr_level-1
            if no_delay ~= nil then m = state.curr_level end
            table.insert(
                state.high_scores,
                index_to_be,
                {
                    score = h_score_to_be,
                    initials=
                        menu.initials[1].text..
                        menu.initials[2].text..
                        menu.initials[3].text,
                    medals=m
                }
            )
            state.high_scores[#state.high_scores] = nil
            menu.group:hide()
            menu.group.opacity=0
            menu.h_score_menu:animate_in()
            local upper = #medals
            for i = 1,upper do
                medals[i]:unparent()
                medals[i] = nil
            end
        end,
    }
end)

















Menu_Game_Over_No_Save = Class(function(menu, ...)
    
    menu.group = Group{}
    menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="GAME OVER",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local h_score_val = Text{text="000000",      font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-250}
    local play_again  = Text{text="Play Again",  font=modal_font,color="FFFFFF", x = screen_w/2-100, y = screen_h/2+100}
    local high_scores = Text{text="High Scores", font=modal_font,color="FFFFFF", x = screen_w/2-100, y = screen_h/2+180}
    local quit        = Text{text="Exit",        font=modal_font,color="FFFFFF", x = screen_w/2-100, y = screen_h/2+260}
    local arrow       = Image{src="assets/splash/Arrow.png", x = play_again.x-50, y = play_again.y+40}
    
    menu.group:add(title,h_score_val,play_again,high_scores,quit,arrow)
    
    layers.splash:add(menu.group)
    menu.group:hide()
    
    local menu_index = 1
    local medals = {}
    function menu:animate_in(highscore,no_delay)
        local m
        local upper = state.curr_level-1
        if no_delay ~= nil then upper = state.curr_level end
        for i = 1, upper do
            m = Clone{source=imgs["medal_"..i], x=screen_w/2-100-200*(i-1),y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        end   
        
        
        menu_index       = 1
        arrow.y = play_again.y+40
        h_score_val.text = string.format("%06d",highscore).." pts"
        
        local iii = 3000
        if no_delay then iii = 100 end
        local timer = Timer{interval=iii}
        
        timer.on_timer = function()
            remove_all_from_render_list()
            menu.group:show()
            menu.group.opacity=255
            state.curr_mode = "GAME_OVER"
            timer:stop()
            timer = nil
        end
        timer:start()
    end
    
    function menu:animate_out()
        menu.group:hide()
    end
    menu.h_score_menu=nil
    function menu:set_ptr_to_h_scores(obj)
        menu.h_score_menu = obj
    end
    menu.keys = {
        [keys.Up]     = function()
            if menu_index - 1 > 0 then
                menu_index = menu_index - 1
                arrow.y = screen_h/2+140+(menu_index-1)*80
            end
        end,
        [keys.Down]   = function()
            if menu_index + 1 < 4 then
                menu_index = menu_index + 1
                arrow.y = screen_h/2+140+(menu_index-1)*80
            end
        end,
        [keys.Return] = function()
            if menu_index == 1 then
                
                menu.group:hide()
                state.curr_mode  = "CAMPAIGN"
                state.curr_level = 1
                add_to_render_list(lvlbg[1])
                add_to_render_list(my_plane)
                add_to_render_list(levels[state.curr_level])
                state.hud.num_lives = 3
                for i = 1,#lives do
                    if i<= state.hud.num_lives then
                        lives[i].opacity=255
                    else
                        lives[i].opacity=0
                    end
                end
                state.hud.curr_score = 0
                redo_score_text()
            elseif menu_index == 2 then
                menu.group:hide()
                menu.h_score_menu:animate_in()
            else
                exit()
            end
            menu.group:hide()
            menu.group.opacity=0
            local upper = #medals
            for i = 1,upper do
                medals[i]:unparent()
                medals[i] = nil
            end
        end,
    }
end)















Menu_High_Scores = Class(function(menu, ...)
    
    menu.group = Group{}
    menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="HIGH SCORES",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local h_score_val = Text{text="000000",      font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2-350}
    local play_again  = Text{text="Play Again",  font=modal_font,color="FFFFFF", x = screen_w/2-750, y = screen_h/2}
    local quit        = Text{text="Exit",        font=modal_font,color="FFFFFF", x = screen_w/2-750, y = screen_h/2+80}
    local arrow       = Image{src="assets/splash/Arrow.png", x = play_again.x-50, y = play_again.y+20}
    local highscores_num  = Text{text="1:\n2:\n3:\n4:\n5:\n6:\n7:\n8:",      font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2-350}
    local highscores_sc  = Text{text="",      font=modal_font,color="FFFFFF", x = screen_w/2+400, y = screen_h/2-350}
    local highscores_ini  = Text{text="",      font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-350}
    local medals = Group{x = screen_w/2+600}
    menu.group:add(title,play_again,highscores_num,highscores_sc,highscores_ini,quit,arrow,medals)
    
    layers.splash:add(menu.group)
    menu.group:hide()
    
    local menu_index = 1
    
    function menu:animate_in()
        medals:clear()
        highscores_ini.text = ""
        highscores_sc.text = ""
        for i = 1,8 do
        print(i)
            highscores_ini.text = highscores_ini.text..state.high_scores[i].initials.."\n"
            highscores_sc.text  = highscores_sc.text..state.high_scores[i].score.."\n"
            for j = 1,state.high_scores[i].medals do
            print("gay")
                medals:add(Clone{source=imgs["medals_"..j.."_sm"], x = 40*j, y = 100*(i-1)})
            end
            
        end
        menu_index       = 1
        menu.group:show()
        menu.group.opacity=255
        state.curr_mode = "HIGH_SCORE"
    end
    

    
    menu.keys = {
        [keys.Up]     = function()
            if menu_index - 1 > 0 then
                menu_index = menu_index - 1
                arrow.y = screen_h/2-80+menu_index*100
            end
        end,
        [keys.Down]   = function()
            if menu_index + 1 < 3 then
                menu_index = menu_index + 1
                arrow.y = screen_h/2-80+menu_index*100
            end
        end,
        [keys.Return] = function()
            if menu_index == 1 then
                menu.group:hide()
                state.curr_mode  = "CAMPAIGN"
                state.curr_level = 1
                add_to_render_list(lvlbg[1])
                add_to_render_list(my_plane)
                add_to_render_list(levels[state.curr_level])
                state.hud.num_lives = 3
                for i = 1,#lives do
                    if i<= state.hud.num_lives then
                        lives[i].opacity=255
                    else
                        lives[i].opacity=0
                    end
                end
                state.hud.curr_score = 0
                redo_score_text()
            else
                exit()
            end
            menu.group:hide()
            menu.group.opacity=0
            
        end,
    }
end)











Menu_Level_Complete = Class(function(menu, ...)
    
    menu.group = Group{}
    menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="LEVEL COMPLETE",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local h_score_val = Text{text="000000",      font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-250}
    local medal_name = Text{text="",font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-140}
    local enter       = Text{text="Press Enter to Continue",        font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2+300}
    enter.anchor_point = {enter.w/2,enter.h/2}
    menu.group:add(title,h_score_val,medal_name,enter)
    
    layers.splash:add(menu.group)
    menu.group:hide()
    local medals = {}
    local g_over = nil
    function menu:animate_in(score)
        local m
        for i = 1, state.curr_level do
            m = Clone{source=imgs["medal_"..i], x=screen_w/2-100-200*(i-1),y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        end
        if      state.curr_level == 1 then   medal_name.text = "Wingman Medal"
        elseif  state.curr_level == 2 then   medal_name.text = "Pilot Medal"
        elseif  state.curr_level == 3 then   medal_name.text = "Ace Medal"
        elseif  state.curr_level == 4 then   medal_name.text = "Medal of Victory"
        end
        state.in_lvl_complete = true
        state.menu = score
        
        mediaplayer:play_sound("audio/level-complete.mp3")
        local timer = Timer{interval=3000}
        timer.on_timer = function()
            print(state.counters[state.curr_level].lvl_points)
            h_score_val.text = string.format("%06d",state.counters[state.curr_level].lvl_points).." pts"
            remove_all_from_render_list()
            menu.group:show()
            menu.group.opacity=255
            state.curr_mode = "LEVEL_END"
            timer:stop()
            timer = nil
        end
        timer:start()
    end
    menu.g_over_menu=nil
    function menu:set_ptr_to_g_over(obj)
        menu.g_over_menu = obj
    end

    menu.keys = {
        [keys.Return] = function()
        state.in_lvl_complete = false
        print("ddddd")
            if state.curr_level == max_level then
                menu.group:hide()
                local index = 0
                for i=1,8 do
                    if state.hud.curr_score > state.high_scores[i].score then
                        index = i
                        break
                    end
                end
                if index ~= 0 then
                    menu.g_over_menu:animate_in(state.hud.curr_score,index,true)
                else
                    menu.g_over_menu:animate_in(state.hud.curr_score,true)
                end
                local upper = #medals
                for i = 1,upper do
                    medals[i]:unparent()
                    medals[i] = nil
                end
            else
                remove_from_render_list(lvlbg[state.curr_level])
                state.curr_level = state.curr_level + 1
                if lvlbg[state.curr_level] ~= nil then
                    add_to_render_list(my_plane)
                    add_to_render_list(lvlbg[ state.curr_level])
                    add_to_render_list(levels[state.curr_level])
                    state.curr_mode = "CAMPAIGN"
                end
                menu.group:hide()
                menu.group.opacity=0
                local upper = #medals
                for i = 1,upper do
                    medals[i]:unparent()
                    medals[i] = nil
                end
            end
        end,
    }
end)