--Circle

function createCircleMenu(offset, distance)

	local c = Group{}
	screen:add(c)

	local list = {
						{	AssetLoader:getImage( "normalRobotBuy", { } ),--clip={0,0,SP,SP} } ), 
							AssetLoader:getImage( "wall", { } ), 
							AssetLoader:getImage( "slowTower", { } ), 
							Rectangle{color="FFFFFF", opacity=50, w=100, h=100}, 
							Rectangle{color="FFFFFF", opacity=50, w=100, h=100},	
							Rectangle{color="FFFFFF", opacity=50, w=100, h=100}, 
							Rectangle{color="FFFFFF", opacity=50, w=100, h=100} }
					 }

	CircleMenu = Menu.create(c, list)
	CircleMenu:create_key_functions()
	CircleMenu:button_directions()
	CircleMenu:create_circle(offset, distance)
	CircleMenu:circle_directions(offset, distance)
	CircleMenu.buttons.extra.up = nil
	CircleMenu.buttons.extra.down = nil


	CircleMenu.buttons:grab_key_focus()

	CircleMenu.container.opacity=150
	
	
	
	CircleMenu.buttons.extra.r = function()
	
		-- Temporary way to build a tower
		if CircleMenu.x == 1 then
			local board = game.board:getPathData()
			board[BoardMenu.y][BoardMenu.x] = "X"
			if pathExists(board,{4,1},{4,BW}) then game.board:buildTower("normalRobot") end
		elseif CircleMenu.x == 2 then
			local board = game.board:getPathData()
			board[BoardMenu.y][BoardMenu.x] = "X"
			if pathExists(board,{4,1},{4,BW}) then game.board:buildTower("wall") end
		elseif CircleMenu.x == 3 then
			local board = game.board:getPathData()
			board[BoardMenu.y][BoardMenu.x] = "X"
			if pathExists(board,{4,1},{4,BW}) then game.board:buildTower("slowTower") end
		end
		
		destroyCircleMenu(CircleMenu)
		BoardMenu.buttons:grab_key_focus()
	
	end
	
	
	
	return CircleMenu

end

function destroyCircleMenu(obj)

	screen:remove(obj.container)
	obj = nil

end
