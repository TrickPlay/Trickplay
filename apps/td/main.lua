dofile ("Assets.lua")
dofile ("Globals.lua")
dofile ("menu/menu.lua")
dofile ("Game.lua")
dofile ("Board.lua")
dofile ("Creep.lua")
dofile ("Tower.lua")
dofile ("Bullet.lua")
dofile ("TowerInfo.lua")

screen:show()

function app.on_loaded()
    dofile ("Themes.lua")
    
    -- Everything is loaded
    AssetLoader.on_preload_ready = function()

        dofile ("Circle.lua")
        dofile ("ThemeMenu.lua")
        dofile ("Levels.lua")
        
        local mainMenuList = {
            { Rectangle{color="CC00FF", w=400, h=150, name="Single Player", x=500, y=400} },
            { Rectangle{color="CC00FF", w=400, h=150, name="Cooperative", x=500} },
            --{ Rectangle{color="CC00FF", w=400, h=150, name="Competetive", x=500} }
        }
        
        local mainMenuFocus = Rectangle{color="FF00CC", w=420, h=170}
        
        local g = Group{}
        screen:add(g)

        MainMenu = Menu.create(g, mainMenuList, mainMenuFocus)
        MainMenu:create_key_functions()
        MainMenu:button_directions()
        MainMenu:create_buttons(10, "Sans 34px")
        MainMenu:apply_color_change("FFFFFF", "000000")
        --MainMenu.buttons:grab_key_focus()
        
        MainMenu:update_cursor_position()
        MainMenu.hl.opacity = 255
        
        MainMenu.buttons.extra.r = function()
		
        	if MainMenu.y == 2 then
			
			createLevelMenu(1)
			
			LevelMenu.theme = Themes.robot
			LevelMenu.theme.wave = dofile("themes/"..LevelMenu.theme.themeName.."/coop.lua")
			
			round = 2
			
			game = Game:new{ theme = LevelMenu.theme , gold = LevelMenu.theme.wave.money/2}
			game:startGame()
			
			local hl2 = AssetLoader:getImage( "select2",{} )
			BoardMenu:add_hl( hl2 )
			BoardMenu:update_cursor_position(hl2)
			BoardMenu:controller_directions(hl2)
			
			local player = game.board:addPlayer{name = "Player 2", gold = LevelMenu.theme.wave.money/2, lives = 30, color = "008AFE"}
			
			hl2.extra.r = function() BoardMenu.buttons.extra.r{ x=hl2.extra.x, y=hl2.extra.y, player=player } end
			ipod_keys(hl2)
			
			game.p2info = Group{}
			game.infobar2 = AssetLoader:getImage("InfoBar2",{y = 1005, z = 2.5})
			game.name2 = Text {font = "Sans 30px", text = player.name, x =320, y = 1015, z=3, color = "000000"}
			game.gold2 = Text {font = "Sans 30px", text = player.gold, x =100, y = 1015, z=3, color = "000000" }
			
			game.p2info:add(game.infobar2, game.name2, game.gold2)
			screen:add(game.p2info)
			
			screen:add(countdowntimer, phasetext, playertext, goldtext,livestext)
			screen:add(bulletImage, healthbar, shootAnimation, healthbarblack, bloodGroup, obstaclesGroup)
			
		else
		    
		    	print("Switching to theme menu")
		    	ACTIVE_CONTAINER = ThemeMenu
		    	keyboard_key_down = ThemeMenu.buttons.on_key_down
		    	--ThemeMenu.buttons:grab_key_focus()
			ThemeMenu.container.opacity = 255
			
		end
		
    	end
    	
    	ACTIVE_CONTAINER = MainMenu
    	keyboard_key_down = MainMenu.buttons.on_key_down
    
    	--screen:add( AssetLoader:getImage("InfoBar2",{name="robot", x=200, y=200}) )
    	--screen:add(AssetLoader:getImage("InfoBar",{x = 500, y = 500}))
    end
end

function controllers:on_controller_connected(controller)
	print( "NEW ONE CONNECTED" , controller.name )
	
	function controller.on_disconnected( controller )
	end
	
	function controller.on_key_down( controller , k )
	    if controller.name == "Keyboard" then
	        keyboard_key_down( ACTIVE_CONTAINER.buttons, k )
	    else
	        print( "FROM" , controller.name , "KEY DOWN" , k )
	        print("-"..controller.name.."-")
	        
	        pcall(ipod_key_down, k)
	    end
	end

end

--[[function grab_focus(controller, k)

	print(controller, k)
	if k == keys.Up then print("UP!!!") end

end]]

function ipod_key_down( k )
    
	print("Ipod key:", k)
	
	ipod_k[k]()

end

function ipod_keys(object)

	if not ipod_k then ipod_k = {} end
	
	ipod_k[keys.Up] = object.extra.up
	ipod_k[keys.Down] = object.extra.down
	ipod_k[keys.Left] = object.extra.left
	ipod_k[keys.Right] = object.extra.right
	ipod_k[keys.space] = object.extra.space
	ipod_k[keys.Return] = object.extra.r

end
