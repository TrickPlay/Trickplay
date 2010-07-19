render_list = {}

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



function add_to_render_list( item )
	if item then
		table.insert( render_list , item )
	end
end
-------------------------------------------------------------------------------
-- Game loop, renders everything in the render list

paused = false

function idle.on_idle( idle , seconds )   
	if not paused then    
		for _ , item in ipairs( render_list ) do 
			pcall( item.render , item , seconds ) 
		end        
	end    
end

-------------------------------------------------------------------------------
