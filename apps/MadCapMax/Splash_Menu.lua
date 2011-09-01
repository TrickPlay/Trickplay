Splash_Menu = Group{}

local bg,help,play,flash_play_hl
local index = 1
local splash_path_dir = "menus/splash/"
local enter_press = {
    function()
        
        Splash_Menu:animate{
            duration = 500,
            opacity=0,
            on_completed = function()
                --Animation_Loop:delete_animation(flash_play_hl)
                bg = nil
                help = nil
                play = nil
                Splash_Menu:clear()
                Splash_Menu:unparent()
                collectgarbage("collect")
            end
        }
        
        gamestate:change_state_to("ACTIVE")
        launch_lvl[1]()
        
    end,
    function() --[[DOES NOTHING]] end,
}

local focus_on

gamestate:add_state_change_function(
    function()
        Splash_Menu:load_assets(layers.menus)
    end,
    nil,"SPLASH"
)

function Splash_Menu:load_assets(parent)
    
    index = 1
    
    bg   = Image{src = assets_path_dir..splash_path_dir.."splash.jpg",scale = {4/3,4/3}}
    help = Image{src = assets_path_dir..splash_path_dir.."how-to-card.png", x=500, y=970}
    play = Image{src = assets_path_dir..splash_path_dir.."splash-arrow-highlight.png",scale = {4/3,4/3}, x=1064,y=568}
    
    
    flash_play_hl = make_flash_anim(    play, function() return index ~= 1 end )
    
    local help_y_up = Interval(970,200)
    local help_y_dn = Interval(200,970)
    local slide_up_help = {
        duration = .3,
        on_step = function(s,p)
            help.y = help_y_up:get_value(p)
        end
    }
    local slide_down_help = {
        duration = .3,
        on_step = function(s,p)
            help.y = help_y_dn:get_value(p)
        end
    }
    focus_out = {
        function()
            
            if Animation_Loop:has_animation(slide_down_help) then
                
                Animation_Loop:delete_animation(slide_down_help)
                
            end
            
        end,
        function()
            
            if Animation_Loop:has_animation(slide_up_help) then
                
                Animation_Loop:delete_animation(slide_up_help)
                
            end
            
        end,
    }
    focus_on = {
        function()
            print(1)
            if  not Animation_Loop:has_animation(flash_play_hl) then
                print(2)
                Animation_Loop:add_animation(flash_play_hl)
            end
            
            help_y_dn.from = help.y
            
            Animation_Loop:add_animation(slide_down_help)
            
        end,
        function()
            
            help_y_up.from = help.y
            
            Animation_Loop:add_animation(slide_up_help)
            
        end,
    }
    
    
    dolater(focus_on[index])
    
    Splash_Menu.opacity = 255
    
    Splash_Menu:add(bg,play,help)
    parent:add(Splash_Menu)
    
    Splash_Menu:grab_key_focus()
end


local keys = {
    [keys.Up] = function()
        
        if index ~= 1 then
            
            focus_out[index]()
            
            index = index - 1
            
            focus_on[index]()
            
        end
        
    end,
    [keys.Down] = function()
        
        if index ~= # focus_on then
            
            focus_out[index]()
            
            index = index + 1
            
            focus_on[index]()
            
        end
        
    end,
    [keys.OK] = function()
        
        enter_press[index]()
        
    end,
}

function Splash_Menu:on_key_down(k)
    
    if keys[k] then keys[k]() end
    
    return true
    
end

return Splash_Menu