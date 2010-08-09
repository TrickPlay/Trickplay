dofile ("Square.lua")
dofile ("Obstacle.lua")
dofile ("Player.lua")
dofile ("aStar.lua")

Board = {}

-- Create a new board
function Board:new(args)

	

	local w = BW
	local h = BH

	-- Initialize squares
	local squareGrid = {}
	for i = 1, h do
	squareGrid[i] = {}
	end
	for i = 1, h do
		for j = 1, w do
			squareGrid[i][j] = Square:new {x = j, y = i}
			if (i <= 1 or j <= 1 or i > h - 1 or j > w - 1) then
				squareGrid[i][j].square[3] = FULL
			else
				squareGrid[i][j].square[3] = EMPTY
			end
			if (i >= 3 and i <= 7 and (j <=1 or j > w-1)) then
				squareGrid[i][j].square[3] = WALKABLE
			end
		end
	end
	
	-- Initialize obstacles
	local theme = args.theme	
	local obstacleImages = {}
	for i =1, #theme.obstacles[round] do
		squareGrid[theme.obstacles[round][i][1]][theme.obstacles[round][i][2]].square[3] = FULL
	end
	
	local object = {
		w = w,
		h = h,
		player = Player:new { name = "Player 1", gold = args.gold, lives = 30, color = {102,153,255} },
		squareGrid = squareGrid,
		squaresWithTowers = {},
		obstacleImages = obstacleImages,
		theme = theme,
		timer = Stopwatch(),
		creepWave = {},
	}
	
	setmetatable(object, self)
	self.__index = self
	return object
end

Board.render = function (self, seconds)
	local s =self.timer.elapsed_seconds 
	CREEP_WAVE_LENGTH = self.theme.wave[level].size
	if seconds_elapsed.elapsed_seconds > WAIT_TIME - 3 and seconds_elapsed.elapsed_seconds < WAIT_TIME - 2 then createRedArrow() end
	
	if (seconds_elapsed.elapsed_seconds >= WAIT_TIME) then
		WAIT_TIME = WAIT
		waveProgress.x = waveProgress.x + seconds*((level)/#self.theme.wave * progressBar.w)/CREEP_WAVE_LENGTH
		if (waveProgress.x >= 720 + (level)/#self.theme.wave * (progressBar.w-3*waveProgress.w)) then
			waveProgress.x = 720 + (level)/#self.theme.wave * (progressBar.w-3*waveProgress.w)
		end

		local sp = self.theme.wave[level][wavePartCounter].speed or 1 
		if (s > sp) then 
			self.timer:start()
			if (creepnum <= CREEP_WAVE_LENGTH) then
				local i = wavePartCounter
				for j=1, #self.theme.wave[level][i] do
					local wave = self.theme.creeps[self.theme.waveTable[(self.theme.wave[level][i][j].name)]]
					CREEP_START[1] = math.random(3)+3
					self.creepWave[creepnum] = Creep:new(wave, -SP*2, GTP(CREEP_START[1]) , self.theme.themeName .. wave.name, self.theme.wave[level][i].buffs)
					self.creepWave[creepnum].start = CREEP_START[1]
					screen:add(self.creepWave[creepnum].creepGroup)
					creepGold[creepnum] = 0
					creepnum = creepnum + 1
					creeppartnum = creeppartnum +1
					if (creeppartnum == self.theme.wave[level][i].size+1) then
						creeppartnum = 1
						if (wavePartCounter < #self.theme.wave[level]) then
							wavePartCounter = wavePartCounter + 1
						end
					end
				end
			end
		end
		
		for k,v in pairs(self.creepWave) do
			if (v.hp ~= 0 and v.dead == false) then
				v:render(seconds)
			elseif (v.dead == false) then
				if SOUND and v.deathSound then mediaplayer:play_sound("themes/"..self.theme.themeName.."/sounds/"..v.deathSound) end
				v.greenBar.width = 0
				v.dead = true	
				v.deathtimer:start()
				v.redBar.opacity = 0
				v.greenBar.opacity = 0
				if (game.board.theme.themeName ~= "pacman") then
					v.creepImageGroup:remove(v.creepImage)
					v.creepImageGroup:add(v.deathImage)
				end				
				wave_counter = wave_counter + 1
				if (creepGold[k] ==0) then
					creepGold[k] = 1
					
					self.player.gold = self.player.gold + v.bounty
					self:updateGold(self.player)
					
					if self.player2 then 
						self.player2.gold = self.player2.gold + v.bounty 
						self:updateGold(self.player2)
					end
					
				end
			end
			if (v.dead) then
				local done = v:deathAnimation()					
			end
		end
		phasetext.text = "Wave Phase!"
	else
		phasetext.text = "Build Phase!"
		--bloodGroup:clear()
		bloodGroup.opacity = 155 - s*(155/WAIT_TIME)
		if (bloodGroup.opacity <=10) then
			bloodGroup:clear()
		end	
	end
	leveltext.text = "Level "..round.."    Wave  "..level.."/"..#self.theme.wave
	
	if (wave_counter == CREEP_WAVE_LENGTH) then
		for k,v in pairs(self.creepWave) do
			v.creepGroup.opacity = 0
		end
		for k,v in pairs(self.creepWave) do
			screen:remove(self.creepWave[k].creepGroup)
			--screen:remove(self.creepWave[k].creepImageGroup)
			table.remove(self.creepWave,k)
		end
		wave_counter = 0
		creepnum = 1
		seconds_elapsed:start()
		level = level + 1
		
		savedLevel = level
		savedGold = self.player.gold
		savedLives = self.player.lives
		
		wavePartCounter = 1
		creeppartnum = 1
		
		if (level-1 == #self.theme.wave) then
			--game:killGame(1)
			
			level = 1
			
			endGamePopup(1, "You win!")
			
			
			
		end
		
	end
	
	for i = 1, #self.squaresWithTowers do
		self.squaresWithTowers[i].tower:render(seconds, self.creepWave)
	end
	
	for i = 1, #self.obstacleImages do
		self.obstacleImages[i]:animate()
	end
	
	--[[if self.player.circle then
		circleRender(self.player.circle, seconds)
	end
	
	if self.player2 then
		if self.player2.circle then
			circleRender(self.player2.circle, seconds)
		end
	end]]
	
	--print("render!")
	self.player:render(seconds)
	if self.player2 then self.player2:render(seconds) end
	
	for k,v in pairs(game.popups) do
		v:render(seconds)
	end
		
end

function Board:init()

	--Popup:new{text = "Get Ready!"}

	for i = 1, self.h do
		local total = ""
		for j = 1, self.w do
			total = total..self.squareGrid[i][j].square[3]
		end
		print(total)
	end
end

function Board:addPlayer(args)

	if not self.player2 then
		self.player2 = Player:new { name = args.name, gold = args.gold, lives = args.lives, color = args.color }
	else
		print( "There is already a player 2" )
	end
	
	return self.player2

end

function Board:createBoard()

	local groups = {}
	self.timer:start()
	seconds_elapsed:start()
	for i = 1, self.h do
		groups[i] = {}
		local g = groups[i]
		local s = self.squareGrid[i]
		for j = 1, self.w do
		g[j] = Group{w=SP, h=SP} --, name=self.squareGrid[i][j].square[3]}
	   end
	end
	
	self.backgroundImage = AssetLoader:getImage( self.theme.themeName.."Background", { } ) --Image {src = self.theme.boardBackground }
	self.overlayImage = AssetLoader:getImage( self.theme.themeName.."Overlay", {z = 2.5} )
	progressBar = AssetLoader:getImage("ProgressBar", {x = 700, y = 990 })
	waveProgress = AssetLoader:getImage("WaveProgress", {x = 720 , y = 998, scale = {1.8,1.8}})
	savedLevel = level
	savedGold = self.player.gold
	savedLives = self.player.lives
	livestext.text = game.board.player.lives
	--infobar = AssetLoader:getImage("InfoBar",{x = 600, y = 1000, z = 2.5})
	if (self.theme.obstacles[round].insert) then
		for i =1, #self.theme.obstacles[round] do
			self.obstacleImages[i] = Obstacle:new { x = GTP(self.theme.obstacles[round][i][2]), y = GTP(self.theme.obstacles[round][i][1]), frames = self.theme.obstacles[round].frames}
			screen:add(self.obstacleImages[i].obstacleGroup)
			self.obstacleImages[i].timer:start()
		end
	end
	local b = Group{}

	screen:add(self.backgroundImage, self.overlayImage, b, progressBar, waveProgress)

	--screen:add(backgroundImage, overlayImage, b, infobar)

	local hl = AssetLoader:getImage( "select", { scale={.9,.9}, opacity=200 } )
	--Rectangle{h=SP, w=SP, color="A52A2A"}
	self.nodes = self:createNodes()

	--print("Board created")

	BoardMenu = Menu.create(b, groups, hl)
	BoardMenu:create_key_functions()
	BoardMenu:button_directions()
	BoardMenu:create_buttons(0)
	
	BoardMenu:addSound(nil, "themes/robot/sounds/BeepLow.wav")
	
	-- These will slow everything.. maybe take out?
	--BoardMenu.ban = AssetLoader:getImage( "FocusBan", { } )
	--BoardMenu:overlay()
	--BoardMenu.updateOverlays()
	
	BoardMenu.x = 2
	BoardMenu.y = 2
	
	BoardMenu:update_cursor_position()
	BoardMenu.hl.opacity = 255
	
	local tmp = { BoardMenu.buttons.extra.right, BoardMenu.buttons.extra.left, BoardMenu.buttons.extra.up, BoardMenu.buttons.extra.down }
	BoardMenu.buttons.extra.right = function() if BoardMenu.x < (BW - 1) then tmp[1]() end end
	BoardMenu.buttons.extra.left = function() if BoardMenu.x > (2) then tmp[2]() end end
	BoardMenu.buttons.extra.up = function() if BoardMenu.y > (2) then tmp[3]() end end
	BoardMenu.buttons.extra.down = function() if BoardMenu.y < (BH - 1) then tmp[4]() end end
	
	BoardMenu.container.opacity=255
	if (resumed) then
		savedTowerType = settings.towerType
		savedTowerOwner = settings.towerOwner
		savedTowerPos = settings.towerPos
		savedTowerUpgrades = settings.towerUpgrades
		level = settings.level
		
		if (settings.towerType) then
			for i=1, #settings.towerType do
				local selection = settings.towerType[i]
				self.player.position = settings.towerPos[i]
				self.player.gold = self.player.gold + selection.cost
				self:buildTower(selection,self.player)
				if (settings.towerUpgrades[i] == 1) then
					self.player.gold = self.player.gold + selection.upgrades[1].cost
					self:upgradeTower(self.player)
				elseif (settings.towerUpgrades[i] == 2) then
					self.player.gold = self.player.gold + selection.upgrades[1].cost
					self.player.gold = self.player.gold + selection.upgrades[2].cost
					
					self:upgradeTower(self.player)
					self:upgradeTower(self.player)
				end
				
			end
		end
	end
	waveProgress.x = 720 + (level-1)/#self.theme.wave * (progressBar.w-waveProgress.w)
		
	BoardMenu.buttons.extra.r = function(args)
	
		if not args then args = {} end
		
		local x = args.x or BoardMenu.x
		local y = args.y or BoardMenu.y
		
		-- Populate the circle menu with buttons
		local list = {}
		
		-- Towers		
		local towers = self.theme.towers
		
		local menuType
		
		local player = args.player or self.player
		
		-- To place the tower in the proper place
		player.position = {y, x}
		
		-- Make sure the players aren't building on the same square
		if self.player and self.player2 then
			
			--print("Both players exist")
			
			if self.player.position and self.player2.position then
				
				--print("Both players have positions")
				
				if self.player.position[1] == self.player2.position[1] and self.player.position[2] == self.player2.position[2] then
					
					player.position = nil
					return
				end
				
			end
			
		end
		
		local notEnoughMoney = function()
			
			local a
			if player == self.player then
				a = Group{x=1410, y=795, opacity = 0}
			else
				a = Group{x=50, y=795, opacity = 0}
			end
			a:add( AssetLoader:getImage( "NotEnoughMoney", { } ) )
			Popup:new{group = a, fadeSpeed = 400, time=.8, opacity = 180}
			
		end
		
		if (self.squareGrid[y][x].square[3] == EMPTY) then
			menuType = "Empty"
			
			-- Make sure it's possible to build here without blocking the path
			local board = game.board:getPathData()
			board[y][x] = "X"
			
			if pathExists(board,{4,1},{4,BW}) then
				
				for i,v in pairs(towers) do
				
					list[#list+1] = AssetLoader:getImage( self.theme.themeName..towers[i].name.."Icon", { name = towers[i].cost } )
					list[#list].extra.t = towers[i]
					list[#list].extra.p = true -- Means there is a cost number for focus purposes
					list[#list].extra.f = function()
						if (player.gold - towers[i].cost >=0) then
							
							local status, result = pcall ( self.checkForCreeps, self, { player.position[1], player.position[2] } )
							
							if result or not status then
								
								self:buildTower(towers[i], player)
								self:findPaths()
								return true
								
							else
								
								Popup:new{text = "You can't build on enemies!", fadeSpeed = 400, time=.8, opacity = 180}
								
							end
						else
							notEnoughMoney()
						end
					end
				end
			elseif SOUND then
			
				Popup:new{text = "You can't block the path!", fadeSpeed = 400, time=.8, opacity = 180}
				mediaplayer:play_sound("themes/robot/sounds/Error.wav")
				
			
			end
		elseif (self.squareGrid[y][x].square[3] == FULL and self.squareGrid[y][x].hasTower == true and self.squareGrid[y][x].tower.owner.name == player.name) then
			menuType = "Full"
			
			local tower = self.squareGrid[y][x].tower
			
			list[#list+1] = AssetLoader:getImage( "sellIcon", { name = math.ceil(tower.cost / 2) } )
			list[#list].extra.p = true
			list[#list].extra.f = function()
				self:removeTower(player)
				self:findPaths()
				return true
			end
			
			if tower.level < tower.levels then 
				
				--print(player.gold)
				--print(tower.table.upgrades[tower.level+1].cost)
				
				list[#list+1] = AssetLoader:getImage( "upgradeIcon", { name = tower.table.upgrades[tower.level+1].cost } )
				list[#list].extra.p = true
				list[#list].extra.f = function()
					
					--print(player.gold, tower.table.upgrades[tower.level+1].cost, player.gold - tower.table.upgrades[tower.level+1].cost)
					
					if (player.gold - tower.table.upgrades[tower.level+1].cost >= 0) then
							
						return self:upgradeTower(player)
					else
						notEnoughMoney()
					end
					
				end
				
			end
			
		end
		
		if #list > 0 then
			
			list[#list+1] = AssetLoader:getImage( "backIcon", { } )
			list[#list].extra.f = function()
				return true
			end
			
			-- Put this list within a table... for menu purposes
			local params = {list}
				
			-- Create the circular menu
			player.circle = createCircleMenu( { GTP(y)+SP/2, GTP(x)+SP/2 }, 150, params, menuType, player)
		end
		
	end
	
	self.player.playertext.text = self.player.name
	self.player.goldtext.text = self.player.gold
	BoardMenu.buttons.extra.p = function()
		paused = not paused
		
		if paused then	
			game.board.timer:stop()
			seconds_elapsed:stop()
			PauseMenu:show()
		else
			game.board.timer:continue()
			seconds_elapsed:continue()
			PauseMenu:hide()
		end
		
		--[[ipaused = not ipaused
		if (ipaused) then
--			screen:animate {duration = 500, y_rotation = 180}
			screen:animate {duration = 500, scale = {0.1,0.1}}
		else
--			screen:animate {duration = 500, y_rotation = 0}
			screen:animate {duration = 500, scale = {0.5,0.5}}

		end]]
	end
	
	BoardMenu.buttons.extra.space = function()

		--seconds_elapsed.elapsed_seconds = WAIT_TIME
		bloodGroup:clear()
	end
	
	BoardMenu.buttons.extra.s = function()
	
		SOUND = not SOUND
		
		if SOUND then mediaplayer:play() else mediaplayer:pause() end
	
	end
	
	
	add_to_render_list(self)
	for i=1,#self.creepWave do
		--self.creepWave[i].creepGroup.x = i*100
		print(self.creepWave[i].creepGroup)
		screen:add(self.creepWave[i].creepGroup)
		assert(self.creepWave[i])
	end
	
	ACTIVE_CONTAINER = BoardMenu
	keyboard_key_down = BoardMenu.buttons.on_key_down

end

function Board:updateBan()

	for i=1,BH do
		for j=1, BW do
		
		if self.squareGrid[i][j].square[3] == FULL then BoardMenu.list[i][j].extra.overlay = self.ban
		else BoardMenu.list[i][j].extra.overlay = nil end
		
		end
	end

end

function Board:findPaths()

	for i = 1, #self.creepWave do
		if (self.creepWave[i].creepGroup.x >= 0 and self.creepWave[i].creepGroup.x <= 1800) then
			local found
			if self.creepWave[i].path then
				local size = #self.creepWave[i].path
				if size > 0 then
					found, self.creepWave[i].path = astar.CalculatePath( self.nodes[ self.creepWave[i].path[size][1] ][ self.creepWave[i].path[size][2] ], self.nodes[CREEP_END[1]][CREEP_END[2]], MyNeighbourIterator, MyWalkableCheck, MyHeuristic, MyConditional)
				end
			end
		end
	end

end

function Board:checkForCreeps(square)

	for i, creep in pairs(self.creepWave) do
		
		if creep and not creep.flying and not creep.dead and creep.hp > 0 then
			
			--print(i,creep.path, creep.path[#creep.path])
			
			--print("CREEP:", creep.path[#creep.path][1], creep.path[#creep.path][2])
			--print("TOWER:", square[1], square[2])
			
			if creep.path[#creep.path][1] == square[1] and creep.path[#creep.path][2] == square[2] then
				--print("CAN'T BUILD HERE")
				return
			end
		end
	end
	
	--print("OK, GOOD")
	return true

end

function Board:updateGold(player)

	if player == self.player then
		player.goldtext.text = player.gold
	else
		game.gold2.text = player.gold
	end

end

function Board:buildTower(selection, player)
	
	if self.squareGrid[ player.position[1] ][ player.position[2] ].square[3] ~= EMPTY then return end
	
	local current = self.squareGrid[ player.position[1] ][ player.position[2] ]
	
	if player.gold - selection.cost >= 0 then
		
		savedTowerType[tnum] = selection
		savedTowerPos[tnum] = player.position
		savedTowerUpgrades[tnum] = 0

		
		-- Build a new tower if the player has enough money
		current.tower = Tower:new(selection, self.theme.themeName, current, player)
		current.tower.tnum = tnum
		tnum = tnum + 1

		current.hasTower = true
		table.insert(self.squaresWithTowers, current)
		current.square[3] = FULL
		current:render()
		player.gold = player.gold - current.tower.cost
		savedGold = self.player.gold		
		
		self:updateGold(self.player)
		
		current.tower.timer:start()
		local n = current.square.children
		local m = current.square.cut
		
		if n.north then m.north = n.north n.north.children.south = nil end
		if n.south then m.south = n.south n.south.children.north = nil end
		if n.east then m.east = n.east n.east.children.west = nil end
		if n.west then m.west = n.west n.west.children.east = nil end
	end	
end

function Board:removeTower(player)

	-- in reality this would call the circle menu asking for whether you want to sell or upgrade tower
	local current = self.squareGrid[ player.position[1] ][ player.position[2] ]
	
	current.tower:destroy()
	current.square[3] = EMPTY	
	player.gold = math.ceil(player.gold + current.tower.cost * 0.5)
	
	self:updateGold(player)
	
	current.hasTower = false

	
	local m = current.square.cut
	
	if m.north then m.north.children.south = current.square m.north = nil end
	if m.south then m.south.children.north = current.square m.south = nil end
	if m.east then m.east.children.west = current.square m.east = nil end
	if m.west then m.west.children.east = current.square m.west = nil end
	
	return true

end

function Board:upgradeTower(player)

	-- in reality this would call the circle menu asking for whether you want to sell or upgrade tower
	local current = self.squareGrid[ player.position[1] ][ player.position[2] ]
	return current.tower:upgrade()

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
	--printTable(board)
	
	-- If start == finish
	if st[1] == fn[1] and st[2] == fn[2] then return true
	else board[ st[1] ][ st[2] ] = " " end
		
	local found = false
		
	-- Check all directions
	if st[2] > 1 and board[ st[1] ][ st[2]-1 ] == 0 and not found then
		found = pathExists(board, { st[1] , st[2]-1 }, fn) end
		
	if st[1] > 1 and board[ st[1]-1 ][ st[2] ] == 0 and not found then
		found = pathExists(board, { st[1]-1 , st[2] }, fn) end
		
	if st[1] < BH and board[ st[1]+1 ][ st[2] ] == 0 and not found then
		found = pathExists(board, { st[1]+1 , st[2] }, fn) end
		
	if st[2] < BW and board[ st[1] ][ st[2]+1 ] == 0 and not found then
		found = pathExists(board, { st[1] , st[2]+1 }, fn) end
	
	return found
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
			if n[1] < BH and self.squareGrid[i+1][j].square[3] ~= FULL then c.south = self.squareGrid[i+1][j].square end
			if n[2] > 1 and self.squareGrid[i][j-1].square[3] ~= FULL then c.west = self.squareGrid[i][j-1].square end			
			if n[2] < BW and self.squareGrid[i][j+1].square[3] ~= FULL then c.east = self.squareGrid[i][j+1].square end			
			
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



--[[function Board:zoomIn()
	print("in")
	screen:animate { duration = 500, scale={math.sqrt(2),2}, position = {-GTP(BoardMenu.x-4)*2,-GTP(BoardMenu.y-2)*2}}

--	screen.scale={2,2}
--	screen.position = {-GTP(BoardMenu.x-4)*2,-GTP(BoardMenu.y-2)*2}
end

function Board:zoomOut()
	print("out")
	screen:animate { duration = 500, scale = {0.5,0.5}, position = {0,0}}
	screen.position = {0, 0}
	screen.scale={.5,.5}
end]]

--[[if not self.zoom then
	self:zoomIn()
	self.zoom = true
else
	self:zoomOut()
	self.zoom = nil
end]]
