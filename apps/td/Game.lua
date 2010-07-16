Game = {}

function Game:new(args)
	local theme = Themes.robot
	local board = Board:new {
		--board args to be passed in
		theme = theme
	}
	
	local object = {
		-- properties of game
		board = board,
		theme = theme
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Game:startGame()
	self.board:init()
	self.board:createBoard()
end

