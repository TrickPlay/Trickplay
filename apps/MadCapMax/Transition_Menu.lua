Transition_Menu = Group{}

local bg, retry, retry_hl, continue, continue_hl, title

local text_layer = Group{}

local index = 1
local trans_path_dir = "menus/transition/"

local player, sk, hs

local prev_lvl, next_lvl

local lvl_total = {}
local current_lvl = {}
local multipliers = {}
local totals = {}
local total_score, lvl_txt

local enter_press = {
    function()
        
        sk:reset_lvl()
        
        fade_out_mediaplayer(2)
        
        launch_lvl(prev_lvl,Transition_Menu)
        
    end,
    function()
        
        if lvl_params[prev_lvl+1] then
            
            sk:new_lvl()
            
            fade_out_mediaplayer(2)
            
            launch_lvl(prev_lvl+1,Transition_Menu)
            
        else
            
            sk:reset_all()
            
            retry_hl.flash = nil
            continue_hl.flash = nil
            continue:unparent()    
            continue_hl:unparent() 
            retry:unparent()   
            retry_hl:unparent()
            title:unparent()
            title = nil
            continue = nil
            continue_hl = nil
            retry = nil
            retry_hl = nil
            
            bg:unparent()
            bg = nil
            Transition_Menu:unparent()
            
            High_Score_Menu:load_assets(layers.menus, total_score.score)
            
            gamestate:change_state_to("HS_MENU")
            
        end
    end,
}

local focus_on, right_i
local prog  = Rectangle{x = 40, y = screen_h - 100, w=10,          h = 30, color="f69024dd"}
local track = Rectangle{x = 40, y = screen_h - 100, w=screen_w-80, h = 30, color="00000066"}

Transition_Menu:add(track,prog,text_layer)


local num_assets, num_loaded

function Transition_Menu.set_progress(amt)
    retry_hl.flash = nil
    continue_hl.flash = nil
    continue:unparent()    
    continue_hl:unparent() 
    retry:unparent()   
    retry_hl:unparent()
    title:unparent()
    title = nil
    continue = nil
    continue_hl = nil
    retry = nil
    retry_hl = nil
    collectgarbage("collect")
    
    if type(amt) ~= "number" then
        
        error("must pass a number for the number of assets",2)
        
    end
    
    track:raise_to_top()
    track:show()
    prog:raise_to_top()
    prog:show()
    
    num_assets = amt
    num_loaded = 0
end
function Transition_Menu:inc_progress()
    
    num_loaded = num_loaded + 1
    
    if num_loaded > num_assets then
        
        error("miscalculation with progress",2)
        
    elseif num_loaded == num_assets then
        
        bg:unparent()
        bg = nil
        Transition_Menu:unparent()
        
        collectgarbage("collect")
        
        
        dolater(
            gamestate.change_state_to,
            gamestate,
            "ACTIVE"
        )
        
    end
    
    prog.w = num_loaded/num_assets*track.w
    
end


gamestate:add_state_change_function(
    function()
        Transition_Menu:load_assets(layers.menus,LVL_Object:curr_lvl())
    end,
    "ACTIVE","LVL_TRANSITION"
)
gamestate:add_state_change_function(
    function()
        
        retry_hl.flash = nil
        continue_hl.flash = nil
        continue:unparent()    
        continue_hl:unparent() 
        retry:unparent()   
        retry_hl:unparent()
        continue = nil
        continue_hl = nil
        retry = nil
        retry_hl = nil
        bg:unparent()
        bg = nil
        title:unparent()
        title = nil
        
        Transition_Menu:unparent()
        
        hs:load_assets(layers.menus, total_score.score)
        
    end,
    "LVL_TRANSITION","SPLASH"
)

local font = "Andika"

function Transition_Menu:init(t)
    
    player = t.player  or error("failed to pass Max to Transition Menu",2)
    sk     = t.sk      or error("failed to pass ScoreKeeper to Transition Menu",2)
    hs     = t.hs_menu or error("failed to pass High_Score_Menu to Transition Menu",2)
    
end

local categor_multipliers = {5,5,20,10}
local categories = {"seeds","crackers","cherries","poop"}

local categories_r = {}

for i,c in pairs(categories) do
    
    categories_r[c] = i
    
end


local base_y = 530
local y_interval = 90

for i,c in pairs(categories) do
    
    lvl_total[i] = Text{
        name  = c.." pre_lvl_total",
        font  = font.." 40px",
        color = "000000",
        x     = 870,
        y     = base_y + y_interval * (i-1),
    }
    
    multipliers[i] = Text{
        name  = c.." multiplier",
        font  = font.." 40px",
        text  = categor_multipliers[i],
        color = "000000",
        x     = 1000,
        y     = base_y + y_interval * (i-1),
    }
    
    totals[i] = Text{
        name  = c.." total",
        font  = font.." 40px",
        color = "000000",
        x     = 1070,
        y     = base_y + y_interval * (i-1),
    }
    text_layer:add(
        lvl_total[i],
        Text{
            name  = c.." x",
            font  = font.." 40px",
            text  = "x",
            color = "000000",
            x     = 965,
            y     = base_y + y_interval * (i-1),
        },
        multipliers[i],
        totals[i]
    )
end

total_score = Text{font = font.." 50px",color="000000", x = 920+155, y = 958}
lvl_txt     = Text{font = font.." 70px",color="000000", x = screen_w/2+40, y = 397, text = "0"}

text_layer:add(lvl_txt,total_score)

function Transition_Menu:load_assets(parent,prev_level)
    
    mediaplayer:load("audio/opening theme quiet.mp3")
    
    prev_lvl = prev_level
    
    index   = player.dead and 1 or 2
    right_i = player.dead and 1 or 2
    
    bg          = Image{src = assets_path_dir..trans_path_dir.."level-transition.jpg", scale = {4/3,4/3} }
    retry       = Image{src = assets_path_dir..trans_path_dir.."retry.png",       x =   50,y=800}
    retry_hl    = Image{src = assets_path_dir..trans_path_dir.."retry-hl.png",    x =   50,y=800,opacity=0}
    continue    = Image{src = assets_path_dir..trans_path_dir.."continue.png",    x = 1415,y=800}
    continue_hl = Image{src = assets_path_dir..trans_path_dir.."continue-hl.png", x = 1415,y=800,opacity=0}
    
    title = player.dead and
        Image{src = assets_path_dir..trans_path_dir.."transition-tryagain.png", x = 350,y=100} or
        Image{src = assets_path_dir..trans_path_dir.."transition-hurray.png",   x = 540,y=100}
    
    continue.opacity = player.dead and 255*.25 or 255
    
    retry_hl.flash    = make_flash_anim(    retry_hl, function() return index ~= 1 end )
    continue_hl.flash = make_flash_anim( continue_hl, function() return index ~= 2 end )
    
    focus_on = {
        function()
            
            if  not Animation_Loop:has_animation(retry_hl.flash) then
                Animation_Loop:add_animation(retry_hl.flash)
            end
            
        end,
        function()
            
            if  not Animation_Loop:has_animation(continue_hl.flash) then
                Animation_Loop:add_animation(continue_hl.flash)
            end
            
        end,
    }
    
    local pre_tot  = sk:total()
    local curr_lvl = sk:current_level()
    
    total_score.score = 0
    for i,c in pairs(categories) do
        
        lvl_total[ i ].text = ((pre_tot[c] or 0) + (curr_lvl[c] or 0))
        
        totals[ i ].score       = ((pre_tot[c] or 0) + (curr_lvl[c] or 0))* categor_multipliers[ i ]
        
        totals[ i ].text        = "= "..totals[ i ].score
        
        total_score.score       = total_score.score + totals[ i ].score
    end
    
    
    total_score.text = total_score.score
    total_score.anchor_point = {total_score.w,0}
    --[[
    for c,amt in pairs(sk:total()) do
        
        lvl_total[  categories_r[c]  ].text = ((pre_tot[c] or 0) + (curr_lvl[c] or 0))
        
    end
    
    for c,amt in pairs(sk:current_level()) do
        
        current_lvl[  categories_r[c]  ].text = "+ "..amt
        
    end
    --]]
    lvl_txt.text = prev_level
    
    dolater(focus_on[index])
    
    Transition_Menu:add(bg,retry,retry_hl,continue,continue_hl,title)
    
    Transition_Menu.opacity = 255
    
    parent:add(Transition_Menu)
    
    text_layer:raise_to_top()
    
    Transition_Menu:grab_key_focus()
    print("added")
end


local keys = {
    [keys.Left] = function()
        
        if index ~= 1 then
            
            mediaplayer:play_sound("audio/wing-flap-4.mp3")
            
            index = index - 1
            
            focus_on[index]()
            
        end
        
    end,
    [keys.Right] = function()
        
        if index ~= right_i then
            
            mediaplayer:play_sound("audio/wing-flap-4.mp3")
            
            index = index + 1
            
            focus_on[index]()
            
        end
        
    end,
    [keys.OK] = function()
        
        mediaplayer:play_sound("audio/start.mp3")
        
        enter_press[index]()
        
    end,
}

function Transition_Menu:on_key_down(k)
    
    if keys[k] then keys[k]() end
    
    return true
    
end

return Transition_Menu