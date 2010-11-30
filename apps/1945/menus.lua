modal_title = "kroeger 06_65 140px"
modal_font  = "kroeger 06_65 70px"

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
    
    function menu:animate_in(highscore,index)
        if state.curr_level == 2 then
            local m = Clone{source=imgs.medal_1, x=screen_w/2-100,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        elseif  state.curr_level == 3 then
            local m = Clone{source=imgs.medal_1, x=screen_w/2-100,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
            local m = Clone{source=imgs.medal_2, x=screen_w/2-300,y=screen_h/2-250}
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
        
        
        local timer = Timer{interval=1000}
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
            assert(index_to_be>0 and index_to_be < 11)
            table.insert(
                state.high_scores,
                index_to_be,
                {
                    score = h_score_to_be,
                    initials=menu.initials[1].text..
                        menu.initials[2].text..
                        menu.initials[3].text,
                    medals=0
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
    function menu:animate_in(highscore)
        if state.curr_level == 2 then
        
            local m = Clone{source=imgs.medal_1, x=screen_w/2-100,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        elseif  state.curr_level == 3 then
            local m = Clone{source=imgs.medal_1, x=screen_w/2-100,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
            local m = Clone{source=imgs.medal_2, x=screen_w/2-300,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        end
        
        menu_index       = 1
        arrow.y = play_again.y+40
        h_score_val.text = string.format("%06d",highscore).." pts"
        
        local timer = Timer{interval=1000}
        
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
                os.exit()
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
    local highscores  = Text{text="",      font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2-350}
    menu.group:add(title,play_again,highscores,quit,arrow)
    
    layers.splash:add(menu.group)
    menu.group:hide()
    
    local menu_index = 1
    
    function menu:animate_in()
        
        highscores.text = ""
        for i = 1,8 do
        print(i)
            highscores.text = highscores.text.."#"..i..":  "..state.high_scores[i].initials.." "..state.high_scores[i].score.."\n"
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
                os.exit()
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
    local enter       = Text{text="Press Enter to begin next level",        font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2+300}
    enter.anchor_point = {enter.w/2,enter.h/2}
    menu.group:add(title,h_score_val,medal_name,enter)
    
    layers.splash:add(menu.group)
    menu.group:hide()
        local medals = {}

    function menu:animate_in(score)
        if state.curr_level == 1 then
            local m = Clone{source=imgs.medal_1, x=screen_w/2-100,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
            medal_name.text = "Wingman Medal"
        elseif  state.curr_level == 2 then
            local m = Clone{source=imgs.medal_1, x=screen_w/2-100,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
            local m = Clone{source=imgs.medal_2, x=screen_w/2-300,y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
            medal_name.text = "Pilot Medal"
        end
        state.in_lvl_complete = true
        state.menu = score
        h_score_val.text = score.." pts"
        mediaplayer:play_sound("audio/Air Combat Player Power Up.mp3")
        local timer = Timer{interval=1000}
        timer.on_timer = function()
            menu.group:show()
            menu.group.opacity=255
            state.curr_mode = "LEVEL_END"
            timer:stop()
            timer = nil
        end
        timer:start()
    end
    
    menu.keys = {
        [keys.Return] = function()
        state.in_lvl_complete = false
        print("ddddd")
            remove_from_render_list(lvlbg[state.curr_level])
            state.curr_level = state.curr_level + 1
            if lvlbg[state.curr_level] ~= nil then
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
        end,
    }
end)