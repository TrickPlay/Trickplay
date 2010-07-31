render_list = {}

Game = {}

function Game:new(args)
	local theme = args.theme
	local gold = args.gold
	local board = Board:new {
		--board args to be passed in
		theme = theme, gold = gold
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


function Game:killGame()
	print ("kill me")
	screen:clear()
	
	--deleteAll(game)
	--print("hi")
	
	--[[for i=1,#game.board.squareGrid do
		for j=1, #game.board.squareGrid[i] do
			game.board.squareGrid[i][j].tower = nil
		end
	end
	
	for k,v in pairs(game.board) do
	
		v = nil
	
	end
	
	print("done")]]
	
	render_list = {}
	
	game.board = nil
	game = nil
	BoardMenu = nil
	
	assert(not game)
	assert(not BoardMenu)
	
	screen:add(LevelMenu.container)
	screen:add(MainMenu.container)
	screen:add(ThemeMenu.container)
	
	LevelMenu.buttons:grab_key_focus()
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

--[[function deleteAll(tab)

	if type(tab) == "table" then
	
		for k,v in pairs(tab) do
		
			deleteAll(v)
			v = nil
			
			--assert(#tab == 0)
			--tab = nil
		
		end
		
		tab = nil
	
	end

end]]
