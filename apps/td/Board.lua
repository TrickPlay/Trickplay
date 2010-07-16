dofile ("Square.lua")

Board = {}

function Board:new(args)
	local w = BOARD_WIDTH
	local h = BOARD_HEIGHT
	local squareGrid = {}
	local squaresWithTowers = {}

	for i = 1, h do
      squareGrid[i] = {}
	end
	
	for i = 1, h do
		for j = 1, w do
			squareGrid[i][j] = Square:new {x = i, y = j}
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
		squaresWithTowers = squaresWithTowers
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Board:init()
	for i = 1, self.board.h do
		local total = ""
		for j = 1, self.board.w do
			total = total..self.board.squareGrid[i][j].state
		end
		print(total)
	end
end
