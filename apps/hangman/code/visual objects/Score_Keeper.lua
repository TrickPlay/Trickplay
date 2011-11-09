

local score_keeper = Group{ name = "Score Keeper", y = 20}


local make_button, player_1_txt, player_2_txt,max_x_s
local player_1_x_s = {}
local player_2_x_s = {}

local initialized = false

function score_keeper:init(t)
    
    if initialized then error("Score_Keeper has already been initialized",2) end
    
    if type(t)          ~= "table"  then  error("must pass a table",    2) end
    if type(t.font)     ~= "string" then  error("must give a font",     2) end
    if type(t.img_srcs) ~= "table"  then  error("must give a img_srcs", 2) end
    
    make_button = t.make_button or error("Didn't pass score_keeper make_button",2)
    max_x_s     = t.max_x_s or error("Didn't pass score_keeper max_x_s",2)
    
    local player_1_box = Clone{
        source         =  t.img_srcs.player_box,
        x              = screen_w/2-50,
        anchor_point   = {t.img_srcs.player_box.w,0}
    }
    
    local player_2_box = Clone{
        source         = t.img_srcs.player_box,
        x              = screen_w/2+50,
    }
    
    
    local vs = Clone{
        source = t.img_srcs.vs
    }
    
    for i = 1,t.max_x_s do
        
        player_1_x_s[i]     = make_button{
            clone           = true,
            unfocus_fades   = false,
            select_function = function() print("player 1 lost") end,
            unfocused_image = t.img_srcs.x_off,
            focused_image   = t.img_srcs.x_on,
        }
        player_2_x_s[i]     = make_button{
            clone           = true,
            unfocus_fades   = false,
            select_function = function() print("player 2 lost") end,
            unfocused_image = t.img_srcs.x_off,
            focused_image   = t.img_srcs.x_on,
        }
        
        player_1_x_s[i].x = player_1_box.x - player_1_box.w - 47*(i-1) - 10 - t.img_srcs.x_off.w - 8 -- minus '8' for the stupid shadow
        player_2_x_s[i].x = player_2_box.x + player_2_box.w + 47*(i-1) + 10
        
        player_1_x_s[i].y = 10
        player_2_x_s[i].y = 10
        
        score_keeper:add(player_1_x_s[i],player_2_x_s[i])
        
    end
    
    
    vs.x = screen_w/2 - vs.w/2
    vs.y = 15
    
    player_1_txt  = Text{
        text      = "Player_1",
        font      = t.font.." 35px",
        color     = "b1bcbe",
        x         = player_1_box.x - player_1_box.w/2,
        y         = 10,
        ellipsize = "END",
        w         = player_1_box.w-30,
    }
    player_1_txt.anchor_point = {player_1_txt.w/2,0}
    
    player_2_txt  = Text{
        text      = "Player_2",
        font      = t.font.." 35px",
        color     = "b1bcbe",
        x         = player_2_box.x + player_2_box.w/2,
        y         = 10,
        ellipsize = "END",
        w         = player_2_box.w-30,
    }
    player_2_txt.anchor_point = {player_2_txt.w/2,0}
    
    score_keeper:add(player_1_box,player_2_box,player_1_txt,player_2_txt,vs)
    
end

function score_keeper:update(t)
    
    if type(t.my_score)       ~= "number" or t.my_score       > max_x_s then error("player1's score is invalid",2) end
    if type(t.opponent_score) ~= "number" or t.opponent_score > max_x_s then error("player2's score is invalid",2) end
    
    for i = 1, max_x_s do
        
        if t.my_score < i then
            
            player_1_x_s[i]:set_state("UNFOCUSED")
            
        else
            
            player_1_x_s[i]:set_state("FOCUSED")
            
        end
        
        if t.opponent_score < i then
            
            player_2_x_s[i]:set_state("UNFOCUSED")
            
        else
            
            player_2_x_s[i]:set_state("FOCUSED")
            
        end
        
    end
    
    player_1_txt.text = g_user.name      or ""
    player_2_txt.text = t.opponent_name or ""
    
    player_1_txt.anchor_point = {player_1_txt.w/2,0}
    player_2_txt.anchor_point = {player_2_txt.w/2,0}
    
end

return score_keeper