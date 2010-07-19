dofile ("Square.lua")

Board = {
	render = function (self, seconds)
		for i=1,#self.creepWave do
			self.creepWave[i]:render(seconds)
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
	for i = 1, h do
      squareGrid[i] = {}
	end
	for i =1, CREEP_WAVE_LENGTH do
		creepWave[i] = Creep:new(theme.creeps.normalCreep)
		creepWave[i].x = -100
		creepWave[i].y = 400

	end
	for i = 1, h do
		for j = 1, w do
			squareGrid[i][j] = Square:new {x = j, y = i}
			if (i <= 2 or j <= 2 or i > h - 2 or j > w - 2) then
				squareGrid[i][j].state = FULL
			else
				squareGrid[i][j].state = EMPTY
			end
			if (i >= 6 and i <= 13 and (j <=2 or j > w-2)) then
				squareGrid[i][j].state = WALKABLE
			end
	   end
	end
	local object = {
		w = w,
		h = h,
		squareGrid = squareGrid,
		squaresWithTowers = squaresWithTowers,
		theme = theme,
		creepWave = creepWave
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Board:init()
	for i = 1, self.h do
		local total = ""
		for j = 1, self.w do
			total = total..self.squareGrid[i][j].state
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
			g[j] = Group{w=SPW, h=SPH, name=s[j].state}
	   end
	end
	backgroundImage = Image {src = self.theme.boardBackground }

	local b = Group{}
	screen:add(backgroundImage, b)
	local hl = Rectangle{h=70, w=70, color="FF00CC"}

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
		if (self.squareGrid[BoardMenu.y][BoardMenu.x].state == EMPTY) then
			self.squareGrid[BoardMenu.y][BoardMenu.x].tower = Tower:new(self.theme.towers.normalTower)
			table.insert(self.squaresWithTowers, self.squareGrid[BoardMenu.y][BoardMenu.x])
			self.squareGrid[BoardMenu.y][BoardMenu.x].state = FULL
			BoardMenu.list[BoardMenu.y][BoardMenu.x].extra.text.text = 0
			self.squareGrid[BoardMenu.y][BoardMenu.x]:render()
		end
	end
	
	BoardMenu.buttons.extra.space = function()
		local c = self:getPathData()
		--print("Path?", pathExists(c, {BoardMenu.y,BoardMenu.x} , {3,3}) )
		c[BoardMenu.y][BoardMenu.x] = 1
		print("Path?", recordPath(c, {BoardMenu.y,BoardMenu.x} , {3,3}, 1) )
		local path = {}
		tracePath(c, {3, 3}, c[3][3], path)
		print(#path)
		for i=1,#path do print(path[i][1]..","..path[i][2]) end
		--ninePrint(c)
	end
	
	add_to_render_list(self)
	for i=1,#self.creepWave do
		--self.creepWave[i].creepImage.x = i*100
		screen:add(self.creepWave[i].creepImage)
	end
end

function Board:p()
	for i = 1, self.h do
		local total = ""
		for j = 1, self.w do
			total = total..self.squareGrid[i][j].state
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
			if self.squareGrid[i][j].state == FULL then
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


