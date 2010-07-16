dofile ("Square.lua")

Board = {}

function Board:new(args)
	local width = BOARD_WIDTH
	local height = BOARD_HEIGHT
	local square_grid = {}
	
	for i = 1, width do
      square_grid[i] = {}
	end
	
	for i = 1, width do
		for j = 1, height do
			square_grid[i][j] = Square:new {x = i, y = j}
	   end
	end
	
	local object = {
		width = width,
		height = height,
		square_grid = square_grid
   }
   setmetatable(object, self)
   self.__index = self
   return object
end
