--Circle

function createCircleMenu(offset, distance, params, menuType)

	local c = Group{}
	screen:add(c)
	
	local list = params

	CircleMenu = Menu.create(c, list)
	CircleMenu:create_key_functions()
	CircleMenu:button_directions()
	CircleMenu:create_circle(offset, distance)
	CircleMenu:circle_directions(offset, distance)
	CircleMenu.buttons.extra.up = nil
	CircleMenu.buttons.extra.down = nil
	--CircleMenu.buttons:grab_key_focus()
	CircleMenu.container.opacity=150
	
	-- Remember which item was last selected for the different menus and initialize by pressing left until this item is reached
	if not game.board.lastSelected then game.board.lastSelected = {} end
	local last = game.board.lastSelected
	
	if (not last[menuType]) or (last[menuType] > CircleMenu.max_x[1]) then last[menuType] = 1 end
		
	while last[menuType] > CircleMenu.x do
		CircleMenu.buttons.extra.left()
		CircleMenu.container.z_rotation = {CircleMenu.container.extra.angle, CircleMenu.container.z_rotation[2], CircleMenu.container.z_rotation[3]}
	end
	
	-- What happens when you press enter...
	CircleMenu.buttons.extra.r = function()
	
		-- Call the current button's function
		list[1][CircleMenu.x].extra.f()

		-- Then destroy the menu and return to the board
		last[menuType] = CircleMenu.x
		destroyCircleMenu(CircleMenu)
		--BoardMenu.buttons:grab_key_focus()
		
		ACTIVE_CONTAINER = BoardMenu
		keyboard_key_down = BoardMenu.buttons.on_key_down
	
	end
	
	
	ACTIVE_CONTAINER = CircleMenu
	keyboard_key_down = CircleMenu.buttons.on_key_down
	

	return CircleMenu

end

function destroyCircleMenu(obj)

	screen:remove(obj.container)
	obj = nil
	game.board.circle = nil
	
end

--[[unction buildTowerIfEmpty(name)

	--local board = game.board:getPathData()
	--board[BoardMenu.y][BoardMenu.x] = "X"
	
	--if pathExists(board,{4,1},{4,BW}) then
		game.board:buildTower(name)
		game.board:findPaths()
	--	return true
	--else
	--	return false
	--end

end]]

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

