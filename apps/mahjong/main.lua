Components = {
    COMPONENTS_FIRST = 1,
    GAME = 1,
    MENU = 2,
    NO_MOVES_DIALOG = 3,
    NEW_MAP_DIALOG = 4,
    HELP = 5,
    COMPONENTS_LAST = 5
}

Events = {
    KEYBOARD = 1,
    TIMER = 2,
    NOTIFY = 3
}

using_keys = true

dofile("DoFiles.lua")

local splash = Image{src = "assets/Mahjong_Splash.jpg", size = {1920, 1080}}
local start_button_focus = Image{
    src = "assets/StartGlow.png",
    opacity = 0,
    position = {800,650}
}

cursor = Image{src = "assets/pointer-mahjong.png",anchor_point={3,2}}

cursor:hide()

screen:add(splash, start_button_focus,cursor)
screen:show()

local timer = Timer()
timer.interval = 500
timer.on_timer = function(timer)
    timer:stop()
    screen.on_key_down = nil
    timer.on_timer = nil

    mediaplayer:play_sound("assets/audio/start-sound.mp3")

    start_button_focus:animate{duration = 1000, opacity = 255,
    on_completed = function()

        -- Router initialization
        router = Router()
        dofile("EventHandling.lua")
        disable_event_listeners()


        GridPositions = {}
        for i = 1,GRID_WIDTH do
            GridPositions[i] = {}
            for j = 1,GRID_HEIGHT do
                GridPositions[i][j] = {}
                for k = 1,GRID_DEPTH do
                    GridPositions[i][j][k] = 
                    {
                        47*(i-1) - (k-1)*16 + 460,
                        59*(j-1) - (k-1)*21 + 60
                    }
                end
            end
        end
        GridPositions.TOP = Utils.deepcopy(GridPositions[7][4][4])
        GridPositions.TOP[1] = GridPositions.TOP[1] + 40
        GridPositions.TOP[2] = GridPositions.TOP[2] + 40

        -- Animation loop initialization
        gameloop = GameLoop()

        -- View/Controller initialization
        game = GameControl(router, Components.GAME)
        game_menu = MenuView(router)
        game_menu:initialize()
        local no_moves_dialog = DialogBox("Sorry!\nThere are no\nmore moves.", Components.NO_MOVES_DIALOG, router)
        local new_map_dialog = DialogBox("Start a new game\non this layout?", Components.NEW_MAP_DIALOG, router)

        splash:unparent()
        start_button_focus:unparent()

        router:start_app(Components.GAME)
        --router:start_app(Components.NO_MOVES_DIALOG)
        --router:start_app(Components.NEW_MAP_DIALOG)

        -- load the tile image that was used from the previous game
        router:get_controller(Components.MENU):load_tile_type()

        timer.interval = 400
        timer.on_timer = function()
            enable_event_listeners()
            timer:stop()
            timer.on_timer = nil
        end
        
        timer:start()
        
        cursor:raise_to_top()
        
        local g_w =  94--(1920 - 460 - 60)/GRID_WIDTH
        local g_h = 121--(1080 -  60 - 60)/GRID_HEIGHT
        local sel_tile
        
        local sel_tile_z
        
        local state = game:get_state()
        
        screen.on_button_up = function(self,x,y)
            
            if router:get_active_component() ~= Components.GAME then return end
            --game.state:find_selectable_tiles()
            
            
            --local t_g = game.state:get_top_grid()
            
            local t_t = state:get_top_tiles()
            
            --[[
            local i = math.ceil((x-460)/g_w)
            local j = math.ceil((y-60)/g_h)
            
            print(i,j)
            
            if t_g[i] and  t_g[i][j] and #t_g[i][j] ~= 0 then
                
                print(i,j,t_g[i][j][ #t_g[i][j] ])
                
            end            
            --]]
            
            --if sel_tile ~= nil then sel_tile:hide_yellow() end
            
            sel_tile   = nil
            
            sel_tile_z = nil
            
            for _,t in pairs(t_t) do
                
                if  x > t.group.x       and
                    y > t.group.y       and
                    x < t.group.x + g_w and
                    y < t.group.y + g_h then
                    
                    
                    if  sel_tile == nil   or   sel_tile_z < t.position[3]  then
                        
                        sel_tile   = t
                        
                        sel_tile_z = t.position[3]
                        
                    end
                end
                
            end
            if sel_tile ~= nil then 
                
                game:set_selector{
                    
                    x = sel_tile.position[ 1 ],
                    
                    y = sel_tile.position[ 2 ],
                    
                    z = sel_tile.position[ 3 ]
                    
                }
                
                game:return_pressed()
                
            end
            
        end
    end}
end

timer:start()

screen.on_key_down = function()
    screen.on_key_down = nil
    timer:on_timer(timer)
end



controllers:start_pointer()

screen.reactive = true

screen.on_motion = function(self,x,y)
    
    if using_keys then
        
        using_keys = false
        
        cursor:show()
        
        --[[
        if router:get_active_component() ~= Components.GAME and game then
            
            game:get_presentation():hide_focus()
            
        end
        --]]
        
        if router then router:get_active_controller():hide_focus() end
        
        if cursor.curr_focus_on then cursor.curr_focus_on(cursor.curr_focus_p) end
        
    end
    
    cursor.x = x
    
    cursor.y = y
    
end
