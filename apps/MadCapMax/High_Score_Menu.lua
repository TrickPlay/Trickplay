High_Score_Menu = Group{name="High_Score_Menu"}

--consts
local max_name_len = 15

local list_len = 8

local font = "Gladatur Rum"

local hs_path_dir = "menus/highscore/"

--visual pieces
local bg, continue, continue_hl, arrow_src, blue_box

local text_layer = Group{}

local curr_letter = Text{font =font.." 70px",color="333333",text = "a" }

--indexing
local index, insert_at_i, text_input_i = 1,1,1

--init-ed
local player, sk



local scores
local names


local names_txt  = {}
local scores_txt = {}

local enter_press = {
    function()
        
        names_txt[insert_at_i].text = names_txt[insert_at_i].text..curr_letter.text
        curr_letter:hide()
        --blue_box.opacity = 0
        index = 2
        Animation_Loop:add_animation(continue_hl.flash)
        Animation_Loop:delete_animation(curr_letter.blink)
    end,
    function()
        print(insert_at_i)
        names[insert_at_i] = names_txt[insert_at_i].text
        
        bg:unparent()
        continue:unparent()
        continue_hl:unparent()
        arrow_src:unparent()
        
        bg = nil
        continue = nil
        continue_hl = nil
        arrow_src = nil
        
        High_Score_Menu:unparent()
        
        gamestate:change_state_to("SPLASH")
        
    end,
}


High_Score_Menu:add(text_layer)


function High_Score_Menu:init(t)
    
    player = t.player or error("failed to pass Max to Transition Menu",2)
    sk     = t.sk     or error("failed to pass ScoreKeeper to Transition Menu",2)
    
end
 

if settings.scores == nil or settings.names == nil then
    print("new tables")
    scores = {}
    names  = {}
    
    for i = 1,list_len do
        
        names[i]  = "max"
        scores[i] = 0
        
    end
    
else
    
    scores = settings.scores
    names  = settings.names
    
end




local base_y = 450
local y_interval = 65

for i = 1,list_len do
    
    scores_txt[i] = Text{
        name  = i.." score",
        font  = font.." 90px",
        text  = scores[i],
        color = "000000",
        x     = 950,
        y     = base_y + y_interval * (i-1)-15,
    }
    
    names_txt[i] = Text{
        name  = i.." name",
        text  = names[i],
        font  = font.." 70px",
        color = "000000",
        x     = 350,
        y     = base_y + y_interval * (i-1),
    }
    text_layer:add(scores_txt[i],names_txt[i])
end
text_layer:add(curr_letter)
local set_score_list = function()
    
    for i = 1,list_len do
        
        names_txt[i].text  = names[i]
        scores_txt[i].text = scores[i]
        
    end

end




local blue_box_x_off = 5


function High_Score_Menu:load_assets(parent, score)
    
    new_score = score
    
    index =  (new_score > scores[# scores]) and 1 or 2
    
    bg          = Image{src = assets_path_dir..hs_path_dir.."high-score-01.jpg", scale = {4/3,4/3} }
    continue    = Image{src = assets_path_dir..hs_path_dir.."continue.png",    x = 1400,y=800}
    continue_hl = Image{src = assets_path_dir..hs_path_dir.."continue-hl.png", x = 1400,y=800,opacity=0}
    
    arrow_src   = Image{src = assets_path_dir..hs_path_dir.."arrow.png"}
    
    continue_hl.flash = make_flash_anim( continue_hl, function() return index ~= 2 end )
    
    if new_score > scores[# scores] then
        
        index = 1
        
        insert_at_i = 1
        
        for i = #scores,1,-1 do
            
            if new_score < scores[i] then
                
                insert_at_i = i+1
                
                break
                
            end
            
        end
        
        table.insert(scores,insert_at_i,new_score)
        table.insert(names ,insert_at_i,"")
        
        scores[#scores] = nil
        names[#names]   = nil
        
        set_score_list()
        
        curr_letter:show()
        
        text_input_i  = 1
        
        curr_letter.text = "a"
        dumptable(names_txt)
        print(insert_at_i)
        curr_letter.x    = names_txt[insert_at_i].x
        curr_letter.y    = names_txt[insert_at_i].y
        Animation_Loop:add_animation(curr_letter.blink,"HS_MENU")
        --blue_box.opacity = 255
        --blue_box.x       = curr_letter.x - blue_box_x_off
        --blue_box.y       = curr_letter.y
    else
        
        index = 2
        Animation_Loop:add_animation(continue_hl.flash,"HS_MENU")
        
        curr_letter:hide()
        
    end
    
    
    High_Score_Menu:add(bg,continue,continue_hl,blue_box)
    
    High_Score_Menu.opacity = 255
    
    parent:add(High_Score_Menu)
    
    text_layer:raise_to_top()
    
    High_Score_Menu:grab_key_focus()
    
    print("donez")
    
end




local a = "a"; a = a:byte()
local z = "z"; z = z:byte()

curr_letter.letter_up = function(self)
	
	self.text = string.char(
		
		(  (self.text:byte() + 1) - a  )  %
		
		( z - a + 1 ) + a
		
	)
	
end
curr_letter.letter_dn = function(self)
	
	self.text = string.char(
		
		(  (self.text:byte() - 1) - a  )  %
		
		( z - a + 1 ) + a
		
	)
    
end
local black = true
curr_letter.blink = {
    duration = .5,
    loop = true,
    on_step = function() end,
    on_loop = function()
        if black then
            print("a")
            curr_letter.color = "7696b9"
            
        else
            print("b")
            curr_letter.color = "000000"
            
        end
        
        black = not black
        
    end
}


local keys = {
    [keys.Up] = function()
        
        if index == 1 then
            
            curr_letter:letter_up()
            
        end
        
    end,
    [keys.Down] = function()
        
        if index == 1 then
            
            curr_letter:letter_dn()
            
        end
        
    end,
    [keys.Left] = function()
        
        if index == 1 and text_input_i ~= 1 then
            
            text_input_i = text_input_i - 1
            
            names_txt[insert_at_i].text =
                string.sub(
                    names_txt[insert_at_i].text,
                    1,
                    string.len(names_txt[insert_at_i].text) - 1
                )
            
            curr_letter.x =
                names_txt[insert_at_i].x +
                names_txt[insert_at_i].w
            --blue_box.x = curr_letter.x - blue_box_x_off
            
        end
        
    end,
    [keys.Right] = function()
        
        if index == 1 and text_input_i ~= max_name_len then
            
            text_input_i = text_input_i + 1
            
            names_txt[insert_at_i].text = names_txt[insert_at_i].text..curr_letter.text
            
            curr_letter.x =
                names_txt[insert_at_i].x +
                names_txt[insert_at_i].w
            --blue_box.x = curr_letter.x - blue_box_x_off
            
        end
        
    end,
    [keys.OK] = function()
        
        enter_press[index]()
        
    end,
}

function High_Score_Menu:on_key_down(k)
    
    if keys[k] then keys[k]() end
    
    return true
    
end


function app:on_closing()
    
    if names[insert_at_i] == "" then
        
        names[insert_at_i] = "max"
        
    end
    
    settings.scores = scores
    settings.names  = names
    
end

return High_Score_Menu