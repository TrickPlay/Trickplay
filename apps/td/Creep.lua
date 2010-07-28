Creep = { }

function Creep:new(args, x, y, name)
	local creepType = args.creepType
	local hp = args.hp
	local max_hp = hp
	local x_offset = args.x_offset or 0
	local y_offset = args.y_offset or 0
	local speed = args.speed
	local max_speed = speed
	local direction = args.direction or {0,1}
	local timer = Stopwatch()
	local deathtimer = Stopwatch()
	local frames = args.frames
	timer:start()
	
	-- Image/Group stuff
	local creepImage = AssetLoader:getImage(name, {})
	--local creepImageGroup = Group{x = -SP/2, y=-SP, z=1, clip={0,0,SP*2,SP*2} }
	local creepImageGroup = Group{z=1, clip={0,0,creepImage.w/frames,creepImage.h}, x = x_offset, y = y_offset }
	
	creepImageGroup:add(creepImage)
	local greenBar = Clone {source = healthbar, color = "00FF00", y = y_offset-10}
	local redBar = Clone {source = healthbarblack, color = "000000", width = SP, y = y_offset-10}
	local creepGroup = Group{opacity=255, x = x, y = y}
	creepGroup.z_rotation = {0,SP,0}

	creepGroup:add(creepImageGroup, redBar, greenBar)
	
	--local path = {}
	local dead = false
	local deadanimate = false
	local bounty = args.bounty
	local flying = args.flying
	if (flying) then creepGroup.z = 2 end

	local object = {
		hp = hp,
		max_hp = max_hp,
		speed = speed,
		max_speed = max_speed,
		direction = direction,
		creepType = creepType,
		creepImage = creepImage,
		creepImageGroup = creepImageGroup,
		greenBar = greenBar,
		redBar = redBar,
		x_offset = x_offset,
		y_offset = y_offset,
		frames = frames,
		dead = dead,
		deathtimer = deathtimer,
		deadanimate = deadanimate,
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
	if self.flying then
	
		self.creepGroup.x = cx + MOVE
	
		if cx > 1920 then
			self.hp = 0
			wave_counter = wave_counter + 1
			self.dead = true
			game.board.player.lives = game.board.player.lives - 1
			game.board.player.gold = game.board.player.gold - self.bounty
			--print (game.board.player.lives)
			self.creepGroup.x = wave_counter*-240
		end
	
	elseif (not self.found and cx < 0) then
		local new = cx + MOVE
		if new > 0 then
			self.creepGroup.x = .1
		else
			self.creepGroup.x = new
		end

	-- Find a path if none exists and the creep is on the board
	elseif cx >= 0 and not self.path then
		self.found, self.path = astar.CalculatePath(game.board.nodes[ CREEP_START[1] ][ CREEP_START[2] ], game.board.nodes[ CREEP_END[1] ][ CREEP_END[2] ], MyNeighbourIterator, MyWalkableCheck, MyHeuristic)
		--self.creepImage.position = { GTP(self.path[#self.path][2]), GTP(self.path[#self.path][1]) }
		--self:pop()
	 
	-- If the creep runs out of steps
	elseif cx >= 0 and #self.path == 0 then
		self.hp = 0
		wave_counter = wave_counter + 1
		self.dead = true
		game.board.player.lives = game.board.player.lives - 1
		game.board.player.gold = game.board.player.gold - self.bounty
		--print (game.board.player.lives)
		self.creepGroup.x = wave_counter*-240
		
	-- Otherwise, move the creep
	else 
		--print("Moving")
		local path = self.path
		local size = #path
		
		if self.complete or (not self.order) then
			self.complete = nil
			self.order = self:pathTop()
		end
				
		local order = self.order
		
		-- Pick a direction [right]
		if cx < order[2] then
			-- If it's less, then calculate the new position
			local pos = cx + MOVE
			
			self.creepImageGroup.y_rotation = {0, SP/2, 0}
			self.face = 1

			--self.creepImageGroup.y_rotation = {0, self.creepImageGroup.w/4, 0}
			
			-- If the new position would overshoot
			if pos >= order[2] then
				--self.creepImageGroup.y_rotation = {180, self.creepImageGroup.w/4, 0}

			
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
			
			if cx > 5 then self.creepImageGroup.y_rotation = {180, SP, 0} end
			--self.creepImageGroup.opacity = 100
			self.face = -1

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
	end
	self.greenBar.width = SP*(self.hp/self.max_hp)
	self.creepGroup.z = 0.9 + PTG(self.creepGroup.y) * 0.1
	if (self.flying) then self.creepGroup.z = 2 end
	self:animate()
end

--insert whatever happens when you hit a creep, e.g body parts fall or blood drips
function Creep:bleed()
	local x = self.creepGroup.x + math.random(SP)
	local y = self.creepGroup.y + math.random(SP)
--	local blood = Rectangle {color = "FF0000", width = 1, height = 1, x = x, y = y}
--	screen:add(blood)
end

-- insert whatever happens on death here, you can use seconds or deathtimer
function Creep:deathAnimation()
--	self.creepGroup.opacity = 0
	--print (self.face)
	if self.face == 1 then
		self.creepGroup.z_rotation = {-180*self.deathtimer.elapsed_seconds, self.creepImage.h/SP * SP/2,0}
		if self.creepGroup.z_rotation[1] <= -90 then
			self.creepGroup.opacity = 0
			return true
		end
	elseif self.face == -1 then
		self.creepGroup.z_rotation = {180*self.deathtimer.elapsed_seconds, self.creepImage.h/SP * SP/8,0}

		if self.creepGroup.z_rotation[1] >= 90 then
			self.creepGroup.opacity = 0
		end
	end
	return false
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
	
	--[[local anim = {
	{ 0, {0,0,SP,SP} },
	{ -SP, {SP,0,SP,SP} },
	{ 0, {0,0,SP,SP} },
	{ -SP*2, {SP*2,0,SP,SP} },
	}]]
	
	--local frames = self.creepImage.w/(SP*2)
	
	local time = self.frames/7
	--print(time)
	
	for i=1, self.frames do
		if self.timer.elapsed_seconds < ( 1/self.frames ) * i * time and self.timer.elapsed_seconds > ( 1/self.frames) * (i-1) * time then
			self.creepImage.x = - self.creepImage.w/self.frames * (i-1)
			
			--self.creepImage.clip = {SP*2 * (i-1),0,SP*2,SP*2}
			--print("Using image: ", i)
			--print(self.has_clip)
		end
	end
	
	--print(self.timer.elapsed_seconds)
	
	if self.timer.elapsed_seconds > time then
		self.timer:start()
	end
	
end
