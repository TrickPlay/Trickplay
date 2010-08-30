render_list = {}

Game = {}

function Game:new(args)
	local theme = args.theme
	savedTheme = theme
         
	local gold = args.gold
	local board = Board:new {
		--board args to be passed in
		theme = theme, gold = gold
	}
	
	local object = {
		-- properties of game
		board = board,
		theme = theme,
		popups = {},
		bulletSounds = 0,
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Game:startGame()
	gamestarted = true
	self.board:init()
	self.board:createBoard()

end


function Game:killGame(status)

	paused = false
	if status == 1 then
		
		local n = game.theme.themeName
		
		--Global
		lastThemePlayed = n
		print (settings[n].currentLevel, currentLevel)
		if settings[n].currentLevel == currentLevel then
			currentLevel = currentLevel + 1
			settings[n] = { currentLevel = currentLevel }
		
		end
		
		createLevelMenu(settings[n].currentLevel)
			
		LevelMenu.container.opacity = 255
		LevelMenu.hl.opacity = 255
		LevelMenu:update_cursor_position()
		LevelMenu.theme = game.theme

	end
	
	bloodGroup:clear()
	print ("kill me")
	--debug()
	screen:clear()
	resumed = false
	render_list = {}
	savedTowerType = {}
	savedTowerOwner = {}
	savedTowerPos = {}
	savedTowerUpgrades = {}
	savedGold = nil
	savedRound = nil
	savedLives = nil
	savedLevel = nil
	settings.level = nil
	settings.round = nil
	settings.gold = nil
	settings.lives = nil
	settings.towerPos = {}
	settings.towerOwner = {}
	settings.towerType = {}
	settings.towerUpgrades = {}
	tnum = 1
	gamestarted = false

	game.board = nil
	game = nil
	BoardMenu = nil
	
	assert(not game)
	assert(not BoardMenu)
	
	AssetLoader:addAllToScreen()
	
	screen:add(TitleBackground)

	
	screen:add(LevelMenu.container)
	print("\n\n\n\n\n\n\n\n\n\n\n\nadded Level Menu")
	screen:add(MainMenu.container)
	screen:add(ThemeMenu.container)
	
	
	MainMenu.container.opacity = 0
	ThemeMenu.container.opacity = 0
	LevelMenu.container.opacity = 255
	
	ACTIVE_CONTAINER = LevelMenu
	keyboard_key_down = LevelMenu.buttons.on_key_down
	
	WAIT_TIME = FIRST_WAIT
	
	--debug()
	
	
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

