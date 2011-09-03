Transition_Menu = Group{}

local bg, retry, retry_hl, continue, continue_hl

local index = 1
local trans_path_dir = "menus/transition/"

local player

local prev_lvl, next_lvl

local enter_press = {
    function()
        --[[
        Transition_Menu:animate{
            duration = 500,
            opacity=30,
            on_completed = function()
                --Animation_Loop:delete_animation(flash_play_hl)
                bg = nil
                retry = nil
                retry_hl = nil
                continue = nil
                continue_hl = nil
                Transition_Menu:clear()
                Transition_Menu:unparent()
                collectgarbage("collect")
            end
        }
        --]]
        
        gamestate:change_state_to("ACTIVE")
        launch_lvl[prev_lvl](Transition_Menu)
        
    end,
    function() 
        Transition_Menu:animate{
            duration = 500,
            opacity=30,
            on_completed = function()
                --Animation_Loop:delete_animation(flash_play_hl)
                retry_hl.flash = nil
                continue_hl.flash = nil
                bg = nil
                retry = nil
                retry_hl = nil
                continue = nil
                continue_hl = nil
                Transition_Menu:clear()
                Transition_Menu:unparent()
                collectgarbage("collect")
            end
        }
        
        if launch_lvl[prev_lvl+1] then
            
            gamestate:change_state_to("ACTIVE")
            launch_lvl[prev_lvl+1]()
        else
            
            gamestate:change_state_to("SPLASH")
        end
    end,
}

local focus_on, right_i
local prog  = Rectangle{x = 40, y = screen_h - 100, w=10,         h = 30,color="f69024dd"}
local track = Rectangle{x = 40, y = screen_h - 100, w=screen_w-80,h = 30,color="00000066"}

Transition_Menu:add(track,prog)


local num_assets, num_loaded

function Transition_Menu.set_progress(amt)
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
        
        
        gamestate:change_state_to("ACTIVE")
        
    end
    
    prog.w = num_loaded/num_assets*track.w
    
end


gamestate:add_state_change_function(
    function()
        Transition_Menu:load_assets(layers.menus,LVL_Object:curr_lvl())
    end,
    "ACTIVE","LVL_TRANSITION"
)

function Transition_Menu:init(t)
    
    player = t.player
    
end

function Transition_Menu:load_assets(parent,prev_level)
    
    prev_lvl = prev_level
    
    index   = player.dead and 1 or 2
    right_i = player.dead and 1 or 2
    
    bg          = Image{src = assets_path_dir..trans_path_dir.."level-transition.jpg", scale = {4/3,4/3} }
    retry       = Image{src = assets_path_dir..trans_path_dir.."retry.png",       x =   50,y=800}
    retry_hl    = Image{src = assets_path_dir..trans_path_dir.."retry-hl.png",    x =   50,y=800,opacity=0}
    continue    = Image{src = assets_path_dir..trans_path_dir.."continue.png",    x = 1400,y=800}
    continue_hl = Image{src = assets_path_dir..trans_path_dir.."continue-hl.png", x = 1400,y=800,opacity=0}
    
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
    
    dolater(focus_on[index])
    
    Transition_Menu:add(bg,retry,retry_hl,continue,continue_hl)
    
    Transition_Menu.opacity = 255
    
    parent:add(Transition_Menu)
    
    Transition_Menu:grab_key_focus()
    print("added")
end


local keys = {
    [keys.Left] = function()
        
        if index ~= 1 then
            
            index = index - 1
            
            focus_on[index]()
            
        end
        
    end,
    [keys.Right] = function()
        
        if index ~= right_i then
            
            index = index + 1
            
            focus_on[index]()
            
        end
        
    end,
    [keys.OK] = function()
        
        enter_press[index]()
        
    end,
}

function Transition_Menu:on_key_down(k)
    
    if keys[k] then keys[k]() end
    
    return true
    
end

return Transition_Menu