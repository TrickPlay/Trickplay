Transition_Menu = Group{}

local bg,help,play,flash_play_hl
local index = 1
local splash_path_dir = "menus/transition/"

local prev_lvl, next_lvl

local enter_press = {
    function()
        
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
        
        
        gamestate:change_state_to("ACTIVE")
        launch_lvl[prev_lvl]()
        
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

local focus_on

gamestate:add_state_change_function(
    function()
        Transition_Menu:load_assets(layers.menus,LVL_Object:curr_lvl())
    end,
    "ACTIVE","LVL_TRANSITION"
)

function Transition_Menu:load_assets(parent,prev_level)
    
    prev_lvl = prev_level
    
    index = 2
    
    bg          = Image{src = assets_path_dir..splash_path_dir.."level-transition.jpg", }
    retry       = Image{src = assets_path_dir..splash_path_dir.."retry.png",       x =  100,y=400}
    retry_hl    = Image{src = assets_path_dir..splash_path_dir.."retry-hl.png",    x =  100,y=400,opacity=0}
    continue    = Image{src = assets_path_dir..splash_path_dir.."continue.png",    x = 1500,y=400}
    continue_hl = Image{src = assets_path_dir..splash_path_dir.."continue-hl.png", x = 1500,y=400,opacity=0}
    
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
        
        if index ~= # focus_on then
            
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