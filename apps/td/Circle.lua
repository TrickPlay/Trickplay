--Circle

function createCircleMenu(offset, distance, params, menuType, player)

	local c = Group{}
	screen:add(c)
	
	local list = params
        
	local CircleMenu = Menu.create(c, list)
	CircleMenu:create_key_functions()
	CircleMenu:button_directions()
	CircleMenu:create_circle(offset, distance)
	CircleMenu:circle_directions(offset, distance)
	CircleMenu.buttons.extra.up = nil
	CircleMenu.buttons.extra.down = nil
	--CircleMenu.buttons:grab_key_focus()
	CircleMenu.container.opacity=150
        CircleMenu.container.z=5
        CircleMenu.owner = player
	
	-- Remember which item was last selected for the different menus and initialize by pressing left until this item is reached
	if not player.lastSelected then player.lastSelected = {} end
	local last = player.lastSelected
	
	if (not last[menuType]) or (last[menuType] > CircleMenu.max_x[1]) then last[menuType] = 1 end
		
	while last[menuType] > CircleMenu.x do
		CircleMenu.buttons.extra.left()
		CircleMenu.container.z_rotation = {CircleMenu.container.extra.angle, CircleMenu.container.z_rotation[2], CircleMenu.container.z_rotation[3]}
	end
	
	-- What happens when you press enter...
	CircleMenu.buttons.extra.r = function()
                
		-- Call the current button's function
                
                -- TODO Use the player to hold keypress function info
                -- then have a table for keyboard like that table for ipod
                -- That way I can do things like this on the player instead of having
                -- A special case for both
                ------------------------------------------
               
                if list[1][CircleMenu.x].extra.f() then
                        
                        -- Then destroy the menu and return to the board
                        last[menuType] = CircleMenu.x
                        CircleMenu.destroy()
                        --BoardMenu.buttons:grab_key_focus()
                                        
                        if player == game.board.player then
                                ACTIVE_CONTAINER = BoardMenu
                                keyboard_key_down = BoardMenu.buttons.on_key_down
                        elseif player == game.board.player2 then
                                ipod_keys(BoardMenu.hl2)
                        end
                        
                        player.position = nil
                        
                end
                
	end
	
        if player == game.board.player then
                print("Player 1 aquired CircleMenu")
                ACTIVE_CONTAINER = CircleMenu
                keyboard_key_down = CircleMenu.buttons.on_key_down
        elseif player == game.board.player2 then
                print("Player 2 aquired CircleMenu")
                ipod_keys(CircleMenu.buttons)
        end
        
        -- To destroy
        CircleMenu.destroy = function()
                
                screen:remove(CircleMenu.container)
                CircleMenu.owner.circle = nil
                CircleMenu = nil
                
	end
	
	return CircleMenu

end



-- Render circle rotation
function circleRender(c, seconds)

	if c.container.z_rotation[1] < c.container.extra.angle then
                
		local change = math.sqrt(math.abs(c.container.z_rotation[1] - c.container.extra.angle))
		c.container.z_rotation = {c.container.z_rotation[1] + 100*seconds*change,c.container.z_rotation[2], c.container.z_rotation[3]}
		if c.container.z_rotation[1] > c.container.extra.angle then c.container.z_rotation = {c.container.extra.angle,c.container.z_rotation[2], c.container.z_rotation[3]} end
                
	elseif c.container.z_rotation[1] > c.container.extra.angle then
                
		local change = math.sqrt(math.abs(c.container.z_rotation[1] - c.container.extra.angle))
		c.container.z_rotation = {c.container.z_rotation[1] - 100*seconds*change,c.container.z_rotation[2], c.container.z_rotation[3]}
		if c.container.z_rotation[1] < c.container.extra.angle then c.container.z_rotation = {c.container.extra.angle,c.container.z_rotation[2], c.container.z_rotation[3]} end
                
	end
	
end

