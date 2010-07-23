Creep = { }

function Creep:new(args, x, y, name)
	local creepType = args.creepType
	local hp = args.hp
	local max_hp = hp
	local speed = args.speed
	local max_speed = speed
	local direction = args.direction or {0,1}
	local timer = Stopwatch()
	timer:start()
	
	-- Image/Group stuff
	local creepImage = AssetLoader:getImage(name, {clip={0,0,SP,SP} })
	local greenBar = Clone {source = healthbar, color = "00FF00"}
	local redBar = Clone {source = healthbar, color = "FF0000", width = 0}
	local creepGroup = Group{opacity=255, x = x, y = y}
	creepGroup:add(creepImage, greenBar, redBar)
	
	--local path = {}
	local dead = false
	local bounty = args.bounty
	local flying = args.flying
	local object = {
		hp = hp,
		max_hp = max_hp,
		speed = speed,
		max_speed = max_speed,
		direction = direction,
		creepType = creepType,
		creepImage = creepImage,
		greenBar = greenBar,
		redBar = redBar,
		--path = path,
		dead = dead,
		bounty = bounty,
		flying = flying,
		creepGroup = creepGroup,
		timer = timer
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Creep:render(seconds)

	local MOVE = self.speed*seconds*10
	-- Current x and y values
	local cx = self.creepGroup.x
	local cy = self.creepGroup.y
--	CREEP_START[1] = math.random(5)+2
	-- When the creep is off the board
	if not self.found and cx < 0 then
		self.creepGroup.x = cx + MOVE
		
	-- Find a path if none exists and the creep is on the board
	elseif cx >= 0 and not self.path then
		self.found, self.path = astar.CalculatePath(game.board.nodes[ CREEP_START[1] ][ CREEP_START[2] ], game.board.nodes[ CREEP_END[1] ][ CREEP_END[2] ], MyNeighbourIterator, MyWalkableCheck, MyHeuristic)
		--self.creepImage.position = { GTP(self.path[#self.path][2]), GTP(self.path[#self.path][1]) }
		--self:pop()
	 
	-- If the creep runs out of steps
	elseif cx >= 0 and #self.path == 0 then
		self.hp = 0
		wave_counter = wave_counter + 1
		game.board.player.lives = game.board.player.lives - 1
		game.board.player.gold = game.board.player.gold - self.bounty
		print (game.board.player.lives)
		self.creepGroup.x = wave_counter*-240
		
	-- Otherwise, move the creep
	else 
		local path = self.path
		local size = #path
		
		if self.complete or (not self.order) then
			self.complete = nil
			self.order = self:pathTop()
		end
				
		local order = self.order
		
		-- Pick a direction
		if cx < order[2] then
			-- If it's less, then calculate the new position
			local pos = cx + MOVE
		
			-- If the new position would overshoot
			if pos >= order[2] then
				-- Find the remainder and move in the other axis that much
				local d = math.abs(order[2] - self.creepGroup.x)
				self:pop()
				local new = self:pathTop()
				-- Check which direction the next order would have it move
				if self.creepGroup.x < new[2] then self:step(d, 0)
				elseif self.creepGroup.y > new[1] then self.creepGroup.x = order[2] self:step(0, d)
				elseif self.creepGroup.y < new[1] then self.creepGroup.x = order[2] self:step(0, -d)
				end
				
				self.complete = true
			else
			-- If the new position doesn't overshoot, move normally
				self:step(MOVE, 0)
			end
			
		elseif cx > order[2] then 
			--print("left")
			local pos = cx - MOVE
			
			if pos <= order[2] then
				local d = math.abs(order[2] - self.creepGroup.x)
				self:pop()
				local new = self:pathTop()
				if self.creepGroup.y > new[1] then self.creepGroup.x = order[2] self:step(0, d)
				elseif self.creepGroup.y < new[1] then self.creepGroup.x = order[2] self:step(0, -d)
				end
				
				self.complete = true

			else
				self:step(-MOVE, 0)
			end
			
		elseif cy < order[1] then 
			--print("down")
			local pos = cy + MOVE
			
			if pos >= order[1] then
				local d = math.abs(order[1] - self.creepGroup.y)
				self:pop()
				local new = self:pathTop()
				if self.creepGroup.x > new[2] then self.creepGroup.y = order[1] self:step(d, 0)
				elseif self.creepGroup.x < new[2] then self.creepGroup.y = order[1] self:step(-d, 0)
				end
				
				self.complete = true
			else
				self:step(0, MOVE)
			end
			
		elseif cy > order[1] then 
			--print("up", self.creepGroup.y, self.creepGroup.x, order[1], order[2])
			local pos = cy - MOVE
			
			if pos <= order[1] then
				local d = math.abs(order[1] - self.creepGroup.y)
				self:pop()
				local new = self:pathTop()
				if self.creepGroup.x > new[2] then self.creepGroup.y = order[1] self:step(d, 0)
				elseif self.creepGroup.x < new[2] then self.creepGroup.y = order[1] self:step(-d, 0)
				end
				
				self.complete = true
			else
				self:step(0, -MOVE)
			end
		end
		
		self.greenBar.width = SP*(self.hp/self.max_hp)
		
	end
	
	if (self.hp == 0) then 
		dead = true
		self.greenBar.width = 0
		self.creepGroup.opacity = 0
	end
	
	self:animate()
end

function Creep:reset()
	
end

function Creep:step(x, y)

	self.creepGroup.x = self.creepGroup.x + x
	self.creepGroup.y = self.creepGroup.y + y

end

function Creep:pathTop()

	return { GTP(self.path[#self.path][1]), GTP(self.path[#self.path][2]) }

end

function Creep:pop()

	--print("pop", self.path[#self.path][1], self.path[#self.path][2] , #self.path)
	self.path[#self.path] = nil

end

function Creep:animate()

	--self.timer:start()
	
	local anim = {
	{ 0, {0,0,SP,SP} },
	{ -SP, {SP,0,SP,SP} },
	{ 0, {0,0,SP,SP} },
	{ -SP*2, {SP*2,0,SP,SP} },
	}
	
	for i=1, #anim do
		if self.timer.elapsed_seconds < ( 1/#anim ) * i and self.timer.elapsed_seconds > ( 1/#anim) * (i-1) then
			self.creepImage.x = anim[i][1]
			self.creepImage.clip = {anim[i][2][1], anim[i][2][2], anim[i][2][3], anim[i][2][4]}
			--print("Using image: ", i)
			--print(self.has_clip)
		end
	end
	
	--print(self.timer.elapsed_seconds)
	
	if self.timer.elapsed_seconds > 1 then
		self.timer:start()
	end
	
end
