Game = {}

function Game:new(args)
	local board = Board:new {
		--board args to be passed in
	}
	
	local object = {
		-- properties of game
		board = board
   }
   setmetatable(object, self)
   self.__index = self
   return object
end


