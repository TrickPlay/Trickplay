dofile ("Square.lua")
dofile ("Player.lua")
dofile ("aStar.lua")

Board = {
	render = function (self, seconds)
		seconds_elapsed = seconds_elapsed + seconds
		wave_counter = 0
		if (seconds_elapsed >= 20) then
			for i=1,#self.creepWave do
				if (self.creepWave[i].hp ~= 0) then
					self.creepWave[i]:render(seconds)
				else
					wave_counter = wave_counter + 1
					self.creepWave[i].greenBar.width = 0
					self.creepWave[i].creepImage.opacity = 0
				end
			end
			phasetext.text = "Wave Phase!"
		else
			countdowntimer.text = "Time till next wave: "..19 - math.floor(seconds_elapsed)
			phasetext.text = "Build Phase!"
		end
--		print (wave_counter)
		if (wave_counter == CREEP_WAVE_LENGTH) then
			print (" in here")
			for i =1, CREEP_WAVE_LENGTH do
--				self.creepWave[i].hp = self.creepWave[i].max_hp
--				self.creepWave[i].creepImage.src = self.theme.creeps.mediumCreep.creepType
--				self.creepWave[i].path = {}
				self.creepWave[i].creepImage.opacity = 0
				table.remove(self.creepWave, i)
				print ("removing "..i)
			end
			for i =1, CREEP_WAVE_LENGTH do
				self.creepWave[i] = Creep:new(self.theme.creeps.mediumCreep, -240*i,420)
				self.creepWave[i].creepImage.src = self.theme.creeps.mediumCreep.creepType
			end
			
			phasetext.text = "Build Phase!"
			seconds_elapsed = 0
		end
		for i = 1, #self.squaresWithTowers do
			self.squaresWithTowers[i].tower:render(seconds, self.creepWave)
		end
	end
}

function Board:new(args)
	local w = BOARD_WIDTH
	local h = BOARD_HEIGHT
	local squareGrid = {}
	local creepWave = {}
	local squaresWithTowers = {}
	local theme = args.theme
	local player = Player:new {
		name = "Player 1",
		gold = 500
	}
	for i = 1, h do
      squareGrid[i] = {}
	end
	for i =1, CREEP_WAVE_LENGTH do
		creepWave[i] = Creep:new(theme.creeps.normalCreep, -240*i, 420)
	end
	for i = 1, h do
		for j = 1, w do
			squareGrid[i][j] = Square:new {x = j, y = i}
			if (i <= 2 or j <= 2 or i > h - 2 or j > w - 2) then
				squareGrid[i][j].square[3] = FULL
			else
				squareGrid[i][j].square[3] = EMPTY
			end
			if (i >= 6 and i <= 13 and (j <=2 or j > w-2)) then
				squareGrid[i][j].square[3] = WALKABLE
			end
	   end
	end
	local object = {
		w = w,
		h = h,
		player = player,
		squareGrid = squareGrid,
		squaresWithTowers = squaresWithTowers,
		theme = theme,
		creepWave = creepWave,
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Board:init()
	for i = 1, self.h do
		local total = ""
		for j = 1, self.w do
			total = total..self.squareGrid[i][j].square[3]
		end
		print(total)
	end
end

function Board:createBoard()

	local groups = {}
	
	for i = 1, self.h do
		groups[i] = {}
		local g = groups[i]
		local s = self.squareGrid[i]
		for j = 1, self.w do
			--if (s[j].square[3] == FULL) then
				g[j] = Group{w=SPW, h=SPH, name=""}
			--else
			--	g[j] = Group{w=SPW, h=SPH, name=s[j].square[3]}
			--end
	   end
	end
	backgroundImage = Image {src = self.theme.boardBackground }
	
	local b = Group{}
	screen:add(backgroundImage, b)
	local hl = Rectangle{h=70, w=70, color="FF00CC"}
	
	self.nodes = self:createNodes()

	BoardMenu = Menu.create(b, groups, hl)
	BoardMenu:create_key_functions()
	BoardMenu:button_directions()
	BoardMenu:create_buttons(0, "Sans 34px")
	BoardMenu:apply_color_change("FFFFFF", "000000")
	BoardMenu.buttons:grab_key_focus()
	BoardMenu:update_cursor_position()
	BoardMenu.hl.opacity = 255
	BoardMenu.container.opacity=255
	
	BoardMenu.buttons.extra.r = function()
		if (self.squareGrid[BoardMenu.y][BoardMenu.x].square[3] == EMPTY) then
			self:buildTower()
		elseif (self.squareGrid[BoardMenu.y][BoardMenu.x].square[3] == FULL and self.squareGrid[BoardMenu.y][BoardMenu.x].hasTower == true) then
			self:removeTower()
		end
		
		playertext.text = self.player.name
		goldtext.text = self.player.gold

		for i = 1, #self.creepWave do
			if (self.creepWave[i].creepImage.x >= 0 and self.creepWave[i].creepImage.x <= 1800) then
				local found
				found, self.creepWave[i].path = astar.CalculatePath(self.nodes[math.floor(self.creepWave[i].creepImage.y/60)+1][math.floor(self.creepWave[i].creepImage.x/60)+1], self.nodes[7][32], MyNeighbourIterator, MyWalkableCheck, MyHeuristic, MyConditional)
				self.creepWave[i].path[#self.creepWave[i].path] = nil
			end
		end
	end
	
	playertext.text = self.player.name
	goldtext.text = self.player.gold
		
	BoardMenu.buttons.extra.space = function()
		if not self.zoom then
			self:zoomIn()
			self.zoom = true
		else
			self:zoomOut()
			self.zoom = nil
		end
	end
	
	add_to_render_list(self)
	for i=1,#self.creepWave do
		--self.creepWave[i].creepImage.x = i*100
		screen:add(self.creepWave[i].creepImage, self.creepWave[i].greenBar, self.creepWave[i].redBar)
	end
end

function Board:zoomIn()
	print("in")
	screen.scale={2,2}
	screen.position = {-GTP(BoardMenu.x-4)*2,-GTP(BoardMenu.y-2)*2}
end

function Board:zoomOut()
	print("out")
	screen.position = {0, 0}
	screen.scale={.5,.5}
end

function Board:buildTower()

	local current = self.squareGrid[BoardMenu.y][BoardMenu.x]

	-- in reality this would call the circle menu asking for what to do with the square
	current.tower = Tower:new(self.theme.towers.normalTower)
	current.hasTower = true
	table.insert(self.squaresWithTowers, current)
	current.square[3] = FULL
	current:render()
	self.player.gold = self.player.gold - current.tower.cost
	
	local n = current.square.children
	local m = current.square.cut

	if n.north then m.north = n.north n.north.children.south = nil end
	if n.south then m.south = n.south n.south.children.north = nil end
	if n.east then m.east = n.east n.east.children.west = nil end
	if n.west then m.west = n.west n.west.children.east = nil end
	
end

function Board:removeTower()

	-- in reality this would call the circle menu asking for whether you want to sell or upgrade tower
	local current = self.squareGrid[BoardMenu.y][BoardMenu.x]
	
	current.tower:destroy()
	current.square[3] = EMPTY	
	self.player.gold = self.player.gold + current.tower.cost * 0.5
	current.hasTower = false
	
	local m = current.square.cut
	
	if m.north then m.north.children.south = current.square m.north = nil end
	if m.south then m.south.children.north = current.square m.south = nil end
	if m.east then m.east.children.west = current.square m.east = nil end
	if m.west then m.west.children.east = current.square m.west = nil end	

end

function Board:p()
	for i = 1, self.h do
		local total = ""
		for j = 1, self.w do
			total = total..self.squareGrid[i][j].square[3]
		end
		print(total)
	end
end

function printTable(table)
	for i = 1, #table do
		local total = ""
		for j = 1, #table[i] do
			total = total..table[i][j]
		end
	
		print(total)
	end
end

function copyTable(old)

	local new = {}
	for k,v in ipairs(old) do
		new[k] = {}
		for key,val in ipairs(v) do
			new[k][key] = val
		end
	end
	return new

end

function Board:getPathData()

	local t = {}
	for i = 1, self.h do
		t[i] = {}
		for j = 1, self.w do
			if self.squareGrid[i][j].square[3] == FULL then
				t[i][j] = "X"
			else
				t[i][j] = 0
			end
		end
	end
	return t

end

-- Start and finish are {y, x}
function pathExists(board, st, fn)

	-- Some assertions
	assert(type(st) == "table", "Start must have an x and a y coordinate")
	assert(type(fn) == "table", "Finish must have an x and a y coordinate")
	printTable(board)
	
	-- If start == finish
	if st[1] == fn[1] and st[2] == fn[2] then return true
	else board[ st[1] ][ st[2] ] = " " end
		
	local found = false
		
	-- Check all directions
	if st[2] > 1 and board[ st[1] ][ st[2]-1 ] == 0 and not found then
		print("Right") found = pathExists(board, { st[1] , st[2]-1 }, fn) end
		
	if st[1] > 1 and board[ st[1]-1 ][ st[2] ] == 0 and not found then
		print("Down") found = pathExists(board, { st[1]-1 , st[2] }, fn) end
		
	if st[1] < 18 and board[ st[1]+1 ][ st[2] ] == 0 and not found then
		print("Up") found = pathExists(board, { st[1]+1 , st[2] }, fn) end
		
	if st[2] < 32 and board[ st[1] ][ st[2]+1 ] == 0 and not found then
		print("Left") found = pathExists(board, { st[1] , st[2]+1 }, fn) end
	
	return found
end

function ninePrint(table)
	for i = 1, #table do
		local total = ""
		for j = 1, #table[i] do
			if table[i][j] == "X" then total = total.."X" elseif table[i][j] > 9 then total = total..9 else total = total..table[i][j] end
		end
		print(total)
	end
end

-- Start and finish are {y, x}
function recordPath(board, st, fn, step)

	-- Some assertions
	assert(type(st) == "table", "Start must have an x and a y coordinate")
	assert(type(fn) == "table", "Finish must have an x and a y coordinate")
	if st[1] <= 0 or st[1] >= 19 or st[2] <= 0 or st[2] >= 33 then print(st[1]..", "..st[2]) end
	assert(st[1] > 0 and st[1] < 19 and st[2] > 0 and st[2] < 33)
	
	-- Left
	if st[2] > 1 and board[ st[1] ][ st[2]-1 ] ~= "X" and (board[ st[1] ][ st[2]-1 ] == 0 or board[ st[1] ][ st[2]-1 ] > step + 1) then 
		board[ st[1] ][ st[2]-1 ] = step + 1
		recordPath(board, { st[1] , st[2]-1 }, fn, step + 1)
	end
	
	-- Right
	if st[2] < 32 and board[ st[1] ][ st[2]+1 ] ~= "X" and (board[ st[1] ][ st[2]+1 ] == 0 or board[ st[1] ][ st[2]+1 ] > step + 1) then 
		board[ st[1] ][ st[2]+1 ] = step + 1
		recordPath(board, { st[1] , st[2]+1 }, fn, step + 1)
	end
	
	-- Down
	if st[1] > 1 and board[ st[1]-1 ][ st[2] ] ~= "X" and (board[ st[1]-1 ][ st[2] ] == 0 or board[ st[1]-1 ][ st[2] ] > step + 1) then
		board[ st[1]-1 ][ st[2] ] = step + 1
		recordPath(board, { st[1]-1 , st[2] }, fn, step + 1)
	end
	
	-- Up
	if st[1] < 18 and board[ st[1]+1 ][ st[2] ] ~= "X" and (board[ st[1]+1 ][ st[2] ] == 0 or board[ st[1]+1 ][ st[2] ] > step + 1) then
		board[ st[1]+1 ][ st[2] ] = step + 1
		recordPath(board, { st[1]+1 , st[2] }, fn, step + 1)
	end
	
end

function tracePath(board, fn, step, path)

	path[#path + 1] = { fn[1], fn[2] }

	if board[ fn[1] ][ fn[2]-1 ] == step-1 then tracePath(board, { fn[1], fn[2]-1 }, step-1, path)
	elseif board[ fn[1] ][ fn[2]+1 ] == step-1 then tracePath(board, { fn[1], fn[2]+1 }, step-1, path)
	elseif board[ fn[1]-1 ][ fn[2] ] == step-1 then tracePath(board, { fn[1]-1, fn[2] }, step-1, path)
	elseif board[ fn[1]+1 ][ fn[2] ] == step-1 then tracePath(board, { fn[1]+1, fn[2] }, step-1, path) end

end

function Board:createNodes()
	
	local nodes = {}
	
	for i = 1, self.h do
		nodes[i] = {}
		for j = 1, self.w do
			local n = self.squareGrid[i][j].square
			nodes[i][j] = n
			n.children = {}
			n.cut = {}
			local c = n.children
			
			if n[1] > 1 and self.squareGrid[i-1][j].square[3] ~= FULL then c.north = self.squareGrid[i-1][j].square end
			if n[1] < 18 and self.squareGrid[i+1][j].square[3] ~= FULL then c.south = self.squareGrid[i+1][j].square end
			if n[2] > 1 and self.squareGrid[i][j-1].square[3] ~= FULL then c.west = self.squareGrid[i][j-1].square end			
			if n[2] < 32 and self.squareGrid[i][j+1].square[3] ~= FULL then c.east = self.squareGrid[i][j+1].square end			
			
		end
	end
	
	return nodes

end

function MyNeighbourIterator(node)
	return pairs(node.children)
end

function MyWalkableCheck(current_node)
	if current_node[3] ~= FULL then
		return true
	else
		return false
	end
end

function MyHeuristic(node_a, node_b)
	return ( math.abs(node_a[1]-node_b[1]) + math.abs(node_a[2]-node_b[2]) )
end
