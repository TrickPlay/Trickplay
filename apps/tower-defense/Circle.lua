local print = function() end

function createCircleMenu(offset, distance, params, menuType, player)

        if player.info then
                --player.info.fade = "out"
                player.info.group.y = player.info.group.y - 90
        end
        
        local desc = Group{z=3}
        
        --[[
        if player == game.board.player then
        
                descImage = AssetLoader:getImage("DescriptionRight",{})
                desc:add(descImage)
                desc.anchor_point = {desc.w, desc.h}
                desc.position = {screen.w, screen.h - 130}
        
        else
        
                descImage = AssetLoader:getImage("DescriptionLeft",{})
                desc:add(descImage)
                desc.anchor_point = {0, desc.h}
                desc.position = {0, screen.h - 130}
        
        end
        
        player.description = Popup:new{group = desc, opacity = 200, fadeSpeed = 800, on_fade_in = function() end}
        desc:raise_to_top()
        ]]

        
        
        
        print("Should create a button menu")

	local c = Group{}
	screen:add(c)
	
	local list = params
        
        local focusBump = AssetLoader:getImage("BuyFocus",{})
        local focusRound = AssetLoader:getImage("BuyFocusCircle",{})
        
        for i=1, #list[1] do
                if list[1][i].extra.p then list[1][i].extra.overlay = focusBump
                else list[1][i].extra.overlay = focusRound
                end
        end
        
        local hl = AssetLoader:getImage("BuyFocus",{})
        local CircleMenu = Menu.create(c, list, hl)
        CircleMenu:create_key_functions()
        CircleMenu:button_directions()
        CircleMenu:create_buttons(-20, "Sans 20px")	        
        CircleMenu:update_cursor_position()
        CircleMenu:overlay()
	CircleMenu.updateOverlays()
        
        CircleMenu:addSound("themes/robot/sounds/BeepHigh.mp3", "themes/robot/sounds/BeepLow.mp3")
        
        CircleMenu.debug = true -- TURN THIS OFF LATER
        
        print("Created a button menu")
        
	CircleMenu.buttons.extra.up = nil
	CircleMenu.buttons.extra.down = nil
        
        CircleMenu.hl.opacity = 0
	--CircleMenu.container.opacity=230
        CircleMenu.container.z=5
        CircleMenu.owner = player
        
        local circlePopup = Popup:new{group = CircleMenu.container, fadeSpeed = 800, on_fade_in = function() end, on_fade_out = function() CircleMenu.destroy() end}
        
        CircleMenu.list = list
        
        print("ADDED LIST")
        
        --CircleMenu.container.scale = {.6,.6}
        
        if player == game.board.player then 
        
                CircleMenu.container.anchor_point = { CircleMenu.container.w, 0 }
                CircleMenu.container.x = 1920
                CircleMenu.container.y = 1080 - 130
                
        else
        
                CircleMenu.container.x = 5
                CircleMenu.container.y = 1080 - 130
        
        end
        
        
        print("Modified parameters")
	
	-- Remember which item was last selected for the different menus and initialize by pressing left until this item is reached
	if not player.lastSelected then player.lastSelected = {} end
	local last = player.lastSelected
	
	if (not last[menuType]) or (last[menuType] > CircleMenu.max_x[1]) then last[menuType] = CircleMenu.max_x[1]-1 end
		
	while last[menuType] > CircleMenu.x do
		CircleMenu.buttons.extra.right()
                CircleMenu:update_cursor_position()

		--CircleMenu.container.z_rotation = {CircleMenu.container.extra.angle, CircleMenu.container.z_rotation[2], CircleMenu.container.z_rotation[3]}
	end
        
        print("Changled selection")
	
	-- What happens when you press enter...
	CircleMenu.buttons.extra.r = function()
                
		-- Call the current button's function
                if list[1][CircleMenu.x].extra.f() then
                        
                        -- Then destroy the menu and return to the board
                        last[menuType] = CircleMenu.x
                        --BoardMenu.buttons:grab_key_focus()
                                        
                        if player == game.board.player then
                                ACTIVE_CONTAINER = BoardMenu
                                keyboard_key_down = BoardMenu.buttons.on_key_down
                        elseif player == game.board.player2 then
                                ipod_keys(BoardMenu.hl2)
                        end
                        
                        player.position = nil
                        player.towerInfo.fade = "out"
                        
                        if player.info then
                                --player.info.fade = "in"
                                player.info.group.y = player.info.group.y + 90
                        end
                        
                        if player.description then
                                player.description.fade = "out"
                        end
                        
                        circlePopup.fade = "out"
                        
                elseif SOUND then
                
                        mediaplayer:play_sound("themes/robot/sounds/Error.mp3")
                
                end
                
	end
	
        if player == game.board.player then
                print("Player 1 aquired CircleMenu")
                ACTIVE_CONTAINER = CircleMenu
                keyboard_key_down = CircleMenu.buttons.on_key_down
        elseif player == game.board.player2 then
                print("Player 2 aquired CircleMenu")
                --ipod_keys(CircleMenu.buttons)
                ipod_k = CircleMenu.actions
        end
        
        -- To destroy
        CircleMenu.destroy = function()
                
                screen:remove(CircleMenu.container)
                CircleMenu.owner.circle = nil
                CircleMenu = nil
                
	end
        
        
        -- text stuff
        for i=1, #CircleMenu.list[1] do
                local c = CircleMenu.list[1][i].extra.text
                c.position = {c.x + 30, c.y - 30}
                c.color = "000000"
        end
	
	return CircleMenu

end



-- Render circle rotation
--[[function circleRender(c, seconds)

	if c.container.z_rotation[1] < c.container.extra.angle then
                
		local change = math.sqrt(math.abs(c.container.z_rotation[1] - c.container.extra.angle))
		c.container.z_rotation = {c.container.z_rotation[1] + 100*seconds*change,c.container.z_rotation[2], c.container.z_rotation[3]}
		if c.container.z_rotation[1] > c.container.extra.angle then c.container.z_rotation = {c.container.extra.angle,c.container.z_rotation[2], c.container.z_rotation[3]} end
                
	elseif c.container.z_rotation[1] > c.container.extra.angle then
                
		local change = math.sqrt(math.abs(c.container.z_rotation[1] - c.container.extra.angle))
		c.container.z_rotation = {c.container.z_rotation[1] - 100*seconds*change,c.container.z_rotation[2], c.container.z_rotation[3]}
		if c.container.z_rotation[1] < c.container.extra.angle then c.container.z_rotation = {c.container.extra.angle,c.container.z_rotation[2], c.container.z_rotation[3]} end
                
	end
	
end]]

