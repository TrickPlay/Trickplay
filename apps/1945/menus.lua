modal_title = "Arcade Normal, 70px"
modal_font  = "Arcade Normal, 35px"

local max_level = 4

Menu_Game_Over_Save_Highscore = Class(function(menu, ...)
    
    menu.group = Group{}
    --menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="GAME OVER",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local h_score_val = Text{text="000000",    font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-200}
    local h_score_txt = Text{text="HIGH SCORE!",font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-110}
    local init_here   = Text{text="Enter your initials:",font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2+200}
    local arrow_up    = Clone{source=base_imgs.arrow, x = screen_w/2-95, y = screen_h-200, z_rotation={-90,0,0}}
    local arrow_dn    = Clone{source=base_imgs.arrow, x = screen_w/2-55, y = screen_h-100, z_rotation={ 90,0,0}}
    local ok          = button{
	size          = "large",
	x             = screen_w/2+220,
	y             = screen_h  -260,
	text          = "Submit",
    }
        
    init_here.anchor_point = {init_here.w/2,init_here.h/2}
    menu.initials = {
        Text{font = modal_font , text = "" , color = "FFFFFF",x=screen_w/2-100, y=screen_h-200},
        Text{font = modal_font , text = "" , color = "FFFFFF",x=screen_w/2,    y=screen_h-200},
        Text{font = modal_font , text = "" , color = "FFFFFF",x=screen_w/2+100, y=screen_h-200},
    }
    
    menu.group:add(title,h_score_val,h_score_txt,init_here,
        menu.initials[1],menu.initials[2],menu.initials[3],ok
    )
    
    local initial_index = 1
    
    for i,initial in pairs(menu.initials) do
	
	initial.on_text_change = function()
	    --print(initial)
	    initial.anchor_point = {initial.w/2,initial.h/2}
	end
	
	initial.up = Clone{source=base_imgs.arrow, x = initial.x, y = initial.y-initial.h/2-5, z_rotation={-90,0,0}}
	initial.dn = Clone{source=base_imgs.arrow, x = initial.x, y = initial.y+initial.h/2+5, z_rotation={ 90,0,0}}
	
	initial.up.anchor_point = {0,initial.up.h/2}
	initial.dn.anchor_point = {0,initial.dn.h/2}
	--up arrow
	function initial.up:on_enter()
	    
	    initial.up.source = base_imgs.arrow_f
	    
	    cursor.last_on = initial.up.on_enter
	    
	    cursor.on_obj = initial.up
	    
	    cursor.on_nothing = false
    	    
	    initial_index = i
	    
        end
	
        function initial.up:on_leave()
	    
	    cursor.last_on = nil
    	    
	    cursor.on_nothing = true
    	    
	    initial.up.source = base_imgs.arrow
	    
	end
	
	function initial.up:on_button_up()
	    
	    menu.keys[keys.Up]()
	    
	    return true
	    
	end
	--down arrow
	function initial.dn:on_enter()
	    
	    initial.dn.source = base_imgs.arrow_f
	    
	    cursor.last_on = initial.dn.on_enter
	    
	    cursor.on_obj = initial.dn
	    
	    cursor.on_nothing = false
    	    
	    initial_index = i
	    
        end
	
        function initial.dn:on_leave()
	    
	    cursor.last_on = nil
    	    
	    cursor.on_nothing = true
    	    
	    initial.dn.source = base_imgs.arrow
	    
	end
	
	function initial.dn:on_button_up()
	    
	    menu.keys[keys.Down]()
	    
	    return true
	    
	end
	menu.group:add(initial.up,initial.dn)
	
    end
    
    layers.splash:add(menu.group)
    menu.group:hide()
    
    local index_to_be   = 0
    local h_score_to_be = 0
    local medals        = {}
    local idle_loop     = nil
    
    function menu:lose_focus()
	
	menu.initials[initial_index].up.source = base_imgs.arrow
	menu.initials[initial_index].dn.source = base_imgs.arrow
	
    end
    function menu:animate_in(highscore,index,no_delay)
        dont_save_game = true
	if cursor.is_target then cursor:switch_to_pointer() end
	ok:lose_focus()
        local m
        local upper = state.curr_level-1
        if no_delay ~= nil then upper = state.curr_level end
        for i = 1, upper do
            m = Clone{source=base_imgs["medal_"..i], x=screen_w/2-100-200*(i-1),y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        end
	
	initial_index    = 1
        
        for i,initial in pairs(menu.initials) do
	    
	    initial.text = "A"
	    initial.anchor_point = {initial.w/2,initial.h/2}
	    
	    initial.up.reactive = true
	    initial.dn.reactive = true
	    
	    if i == initial_index and using_keys then
		
		initial.up.source = base_imgs.arrow_f
		initial.dn.source = base_imgs.arrow_f
		cursor.keys_on    = menu
	    else
		
		initial.up.source = base_imgs.arrow
		initial.dn.source = base_imgs.arrow
		
	    end
	end
	
	ok.reactive = true
	
        index_to_be      = index
        h_score_to_be    = highscore
        h_score_val.text = string.format("%06d",highscore).." pts"
        
        
        local iii = 3000
        if no_delay then iii = 100 end
        local timer = Timer{interval=iii}
        timer.on_timer = function()
            --remove_all_from_render_list()
            menu.group:show()
            --menu.group.opacity=255
            scrap_caches()
            state.curr_mode = "GAME_OVER_SAVE"
            timer:stop()
            timer = nil
            idle_loop = idle.on_idle
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
		if not ok.focused then
		    
		    menu.initials[initial_index].up.source = base_imgs.arrow
		    menu.initials[initial_index].dn.source = base_imgs.arrow
		    
		    initial_index = initial_index - 1
		    
		else
		    
		    ok:lose_focus()
		    
		    cursor.keys_on = menu
		end
		
		menu.initials[initial_index].up.source = base_imgs.arrow_f
		menu.initials[initial_index].dn.source = base_imgs.arrow_f
		
                arrow_up.x = arrow_up.x-100
                arrow_dn.x = arrow_dn.x-100
            end
        end,
        [keys.Right]  = function()
            if initial_index + 1 <= #menu.initials then
                
		menu.initials[initial_index].up.source = base_imgs.arrow
		menu.initials[initial_index].dn.source = base_imgs.arrow
		
		initial_index = initial_index + 1
		
		menu.initials[initial_index].up.source = base_imgs.arrow_f
		menu.initials[initial_index].dn.source = base_imgs.arrow_f
		
                arrow_up.x = arrow_up.x+100
                arrow_dn.x = arrow_dn.x+100
		
	    elseif not ok.focused then
		
		menu.initials[initial_index].up.source = base_imgs.arrow
		menu.initials[initial_index].dn.source = base_imgs.arrow
		
		ok:get_focus()
		cursor.keys_on = ok
            end
        end,
        [keys.Return] = function()
            assert(index_to_be > 0 and index_to_be < 11)
	    
	    if not ok.focused then return end
	    
	    for i,initial in pairs(menu.initials) do
		
		initial.up.reactive = true
		initial.dn.reactive = true
		
	    end
	    
	    ok.reactive = false
	    
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
            --menu.group.opacity=0
            menu.h_score_menu:animate_in()
            idle.on_idle = idle_loop
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
    --menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="GAME OVER",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local menu_index = 1
    
    local h_score_val = Text{text="000000",      font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-250}
    local high_scores = button{
	size          = "large",
	x             = screen_w/2-100,
	y             = screen_h/2+280,
	text          = "High Scores",
	on_enter      = function() menu_index = 2 end,
    }
    local play_again  = button{
	size          = "large",
	x             = screen_w/2-100,
	y             = screen_h/2+160,
	w             = high_scores.w,
	text          = "Play Again",
	on_enter      = function() menu_index = 1 end,
    }
    
    local quit        = button{
	size          = "large",
	x             = screen_w/2-100,
	y             = screen_h/2+400,
	w             = high_scores.w,
	text          = "Exit",
	on_enter      = function() menu_index = 3 end,
    }
    
    local sel_items = {play_again,high_scores,quit}
    menu.group:add(title,h_score_val,play_again,high_scores,quit)
    
    layers.splash:add(menu.group)
    menu.group:hide()
    
    local medals = {}
    function menu:animate_in(highscore,no_delay)
	
	play_again.reactive  = true
	high_scores.reactive = true
	quit.reactive        = true
	if cursor.is_target then cursor:switch_to_pointer() end
	cursor.keys_on = play_again
	
        local m
        local upper = state.curr_level-1
        if no_delay ~= nil then upper = state.curr_level end
        for i = 1, upper do
            m = Clone{source=base_imgs["medal_"..i], x=screen_w/2-100-200*(i-1),y=screen_h/2-250}
            table.insert(medals,m)
            self.group:add(m)
        end   
        
        sel_items[menu_index]:lose_focus()
        menu_index       = 1
	if using_keys then
	    sel_items[menu_index]:get_focus()
	end
        --arrow.y = play_again.y+40
        h_score_val.text = string.format("%06d",highscore).." pts"
        
        local iii = 3000
        if no_delay then iii = 100 end
        local timer = Timer{interval=iii}
        
        timer.on_timer = function()
            --remove_all_from_render_list()
            menu.group:show()
            --menu.group.opacity=255
            scrap_caches()
            state.curr_mode = "GAME_OVER"
            timer:stop()
            timer = nil
        end
        timer:start()
    end
    
    function menu:animate_out()
	play_again.reactive  = false
	high_scores.reactive = false
	quit.reactive        = false
	cursor:switch_to_target()
        menu.group:hide()
    end
    menu.h_score_menu=nil
    function menu:set_ptr_to_h_scores(obj)
        menu.h_score_menu = obj
    end
    menu.keys = {
        [keys.Up]     = function()
            if menu_index - 1 > 0 then
		sel_items[menu_index]:lose_focus()
                menu_index = menu_index - 1
		sel_items[menu_index]:get_focus()
                --arrow.y = screen_h/2+140+(menu_index-1)*80
            end
        end,
        [keys.Down]   = function()
            if menu_index + 1 < 4 then
                sel_items[menu_index]:lose_focus()
		menu_index = menu_index + 1
		sel_items[menu_index]:get_focus()
                --arrow.y = screen_h/2+140+(menu_index-1)*80
            end
        end,
        [keys.Return] = function()
            if menu_index == 1 then
		launch_new_game()
		--[[
		dont_save_game = false
                remove_all_from_render_list()
		cursor:switch_to_target()
                menu.group:hide()
                state.curr_mode  = "CAMPAIGN"
                state.curr_level = 1
		load_imgs[state.curr_level]()
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
		--]]
            elseif menu_index == 2 then
                menu.h_score_menu:animate_in()
            else
                exit()
            end
            menu:animate_out()
            --menu.group.opacity=0
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
    --menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="HIGH SCORES",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local menu_index = 1
    
    local h_score_val = Text{text="000000",      font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2-350}
    local play_again  = button{
	size          = "large",
	x             = screen_w/2,--750,
	y             = screen_h/2+100,
	text          = "Play Again",
	on_enter      = function() menu_index = 1 end,
	anchor_center = true,
    }
    local quit        = button{
	size          = "large",
	x             = screen_w/2,--750,
	y             = screen_h/2+220,
	w             = play_again.w,
	text          = "Exit",
	on_enter      = function() menu_index = 2 end,
	anchor_center = true,
    }
    
    --(screen_w/2-750, screen_h/2+120,"Exit",       function() menu_index = 2 end)--Text{text="Exit",        font=modal_font,color="FFFFFF", x = screen_w/2-750, y = screen_h/2+80}
    --local arrow       = Clone{source=base_imgs.arrow, x = play_again.x-50, y = play_again.y+20}
    local highscores_num  = Text{text="1:\n2:\n3:\n4:\n5:\n6:\n7:\n8:",      font=modal_font,color="FFFFFF", x = screen_w/2-play_again.w/2, y = screen_h/2-350}
    local highscores_sc   = Text{text="",      font=modal_font,color="FFFFFF", x = screen_w/2+400-play_again.w/2, y = screen_h/2-350}
    local highscores_ini  = Text{text="",      font=modal_font,color="FFFFFF", x = screen_w/2+150-play_again.w/2, y = screen_h/2-350}
    local medals          = Group{x = screen_w/2+600}
    menu.group:add(title,play_again,highscores_num,highscores_sc,highscores_ini,quit,medals)
    
    sel_items = {play_again,quit}
    
    layers.splash:add(menu.group)
    menu.group:hide()
        
    function menu:animate_in()
	
	play_again.reactive  = true
	quit.reactive        = true
	cursor:switch_to_pointer()
	cursor.keys_on = play_again
        medals:clear()
        highscores_ini.text = ""
        highscores_sc.text  = ""
        for i = 1,8 do
        --print(i)
            highscores_ini.text = highscores_ini.text..state.high_scores[i].initials.."\n"
            highscores_sc.text  = highscores_sc.text..state.high_scores[i].score.."\n"
            for j = 1,state.high_scores[i].medals do
                medals:add(Clone{source=base_imgs["medals_"..j.."_sm"], x = 40*j, y = 100*(i-1)})
            end
            
        end
	sel_items[menu_index]:lose_focus()
        menu_index       = 1
	if using_keys then
	    sel_items[menu_index]:get_focus()
	end
        menu.group:show()
        --menu.group.opacity=255
        state.curr_mode = "HIGH_SCORE"
    end
    

    
    menu.keys = {
        [keys.Up]     = function()
            if menu_index - 1 > 0 then
                sel_items[menu_index]:lose_focus()
		menu_index = menu_index - 1
		sel_items[menu_index]:get_focus()
                --arrow.y = screen_h/2-80+menu_index*100
            end
        end,
        [keys.Down]   = function()
            if menu_index + 1 < 3 then
                sel_items[menu_index]:lose_focus()
		menu_index = menu_index + 1
		sel_items[menu_index]:get_focus()
                --arrow.y = screen_h/2-80+menu_index*100
            end
        end,
        [keys.Return] = function()
            if menu_index == 1 then
		play_again.reactive  = false
		quit.reactive        = false
		
		launch_new_game()
		--[[
		remove_all_from_render_list()
		cursor:switch_to_target()
		dont_save_game = false
                menu.group:hide()
                state.curr_mode  = "CAMPAIGN"
                state.curr_level = 1
		load_imgs[state.curr_level]()
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
		--]]
            else
                exit()
            end
            menu.group:hide()
            --menu.group.opacity=0
            
        end,
    }
end)











Menu_Level_Complete = Class(function(menu, ...)
    
    menu.group = Group{}
    --menu.group:add(Rectangle{color="000000",w=screen_w,h=screen_h})
    
    local title = Text{text="LEVEL COMPLETE",font=modal_title,color="FFFFFF"}
    title.anchor_point = {title.w/2,title.h/2}
    title.position     = {screen_w/2,100}
    
    local h_score_val = Text{text="000000",      font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-250}
    local medal_name  = Text{text="",font=modal_font,color="FFFFFF", x = screen_w/2+150, y = screen_h/2-140}
    local enter       = Text{text="Press Enter to Continue",        font=modal_font,color="FFFFFF", x = screen_w/2, y = screen_h/2+300}
    enter.anchor_point = {enter.w/2,enter.h/2}
    menu.group:add(title,h_score_val,medal_name,enter)
    
    layers.splash:add(menu.group)
    menu.group:hide()
    local medals = {}
    local g_over = nil
    function menu:animate_in(score,from_splash)
	if my_plane.dead then return end
        --print("end of level")
        local m
        for i = 1, state.curr_level do
            m = Clone{source=base_imgs["medal_"..i], x=screen_w/2-100-200*(i-1),y=screen_h/2-250}
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
        
        play_sound_wrapper("audio/level-complete.mp3")
        local timer = Timer{interval=3000}
        timer.on_timer = function()
            if my_plane.dead then return end
	    --print("progressing to level "..state.counters[state.curr_level].lvl_points)
            h_score_val.text = string.format("%06d",state.counters[state.curr_level].lvl_points).." pts"
            --remove_all_from_render_list()
            menu.group:show()
            --menu.group.opacity=255
            scrap_caches()
            state.curr_mode = "LEVEL_END"
            timer:stop()
	    cursor:switch_to_pointer()
	    cursor.on_nothing = false
            timer = nil
        end
        if from_splash then
            timer.on_timer()
        else
            timer:start()
        end
    end
    menu.g_over_menu_save=nil
    menu.g_over_menu_no_save=nil
    function menu:set_ptr_to_g_over_save(obj)
        menu.g_over_menu_save = obj
    end
    function menu:set_ptr_to_g_over_no_save(obj)
        menu.g_over_menu_no_save = obj
    end

    menu.keys = {
        [keys.Return] = function()
	    state.in_lvl_complete = false
	    cursor.on_nothing = true
            if state.curr_level == max_level then
                menu.group:hide()
                local index = 0
                for i=1,8 do
                    if state.hud.curr_score > tonumber(state.high_scores[i].score) then
                        index = i
                        break
                    end
                end
                if index ~= 0 then
                    menu.g_over_menu_save:animate_in(state.hud.curr_score,index,true)
                else
                    menu.g_over_menu_no_save:animate_in(state.hud.curr_score,true)
                end
                local upper = #medals
                for i = 1,upper do
                    medals[i]:unparent()
                    medals[i] = nil
                end
            else
		remove_all_from_render_list()
		cursor:switch_to_target()
                --remove_from_render_list(lvlbg[state.curr_level])
                state.curr_level = state.curr_level + 1
		load_imgs[state.curr_level]()
                if lvlbg[state.curr_level] ~= nil then
                    add_to_render_list(my_plane)
                    add_to_render_list(lvlbg[ state.curr_level])
                    add_to_render_list(levels[state.curr_level])
                    state.curr_mode = "CAMPAIGN"
                end
                menu.group:hide()
                --menu.group.opacity=0
                local upper = #medals
                for i = 1,upper do
                    medals[i]:unparent()
                    medals[i] = nil
                end
            end
        end,
    }
end)
