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
	
	deleteAll(game)
	print("hi")
	
	--[[for k,v in pairs(game) do
	
		print(k, v)
		v = nil
	
	end]]
	
	--BoardMenu = nil
	--game = nil
	
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

function deleteAll(tab)

	if type(tab) == "table" then
	
		for k,v in pairs(tab) do
		
			deleteAll(v)
		
			v = nil
			
			assert(#tab == 0)
			
			for key,val in pairs(tab) do
			
				print(key,val)
				--assert(not val)
			
			end
		
			--print("Removing", v, "from table", tab, ".")
			--table.remove(tab, k)
		
			
		
		end
	
	end

end
