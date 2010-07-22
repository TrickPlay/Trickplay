Creep = { }

function Creep:new(args, x, y, name)
	local creepType = args.creepType
	local hp = args.hp
	local max_hp = hp
	local speed = args.speed
	local direction = args.direction or {0,1}
	local creepImage = AssetLoader:getImage(name, {x = x, y = y})
	local greenBar = Clone {source = healthbar, color = "00FF00", x = x, y = y}
	local redBar = Clone {source = healthbar, color = "FF0000", width = 0, x = x , y = y} 
	--local path = {}
	local dead = false
	local bounty = args.bounty
	local flying = args.flying
	local object = {
		hp = hp,
		max_hp = max_hp,
		speed = speed,
		direction = direction,
		creepType = creepType,
		creepImage = creepImage,
		greenBar = greenBar,
		redBar = redBar,
		--path = path,
		dead = dead,
		bounty = bounty,
		flying = flying
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Creep:render(seconds)

	local MOVE = self.speed*seconds*10

	-- Current x and y values
	local cx = self.creepImage.x
	local cy = self.creepImage.y
	
	-- When the creep is off the board
	if not self.found and cx < 0 then
		self.creepImage.x = cx + MOVE
		print(self.creepImage.y)
		
	-- Find a path if none exists and the creep is on the board
	elseif cx >= 0 and not self.path then
		self.found, self.path = astar.CalculatePath(game.board.nodes[ CREEP_START[1] ][ CREEP_START[2] ], game.board.nodes[ CREEP_END[1] ][ CREEP_END[2] ], MyNeighbourIterator, MyWalkableCheck, MyHeuristic)
		--self.creepImage.position = { GTP(self.path[#self.path][2]), GTP(self.path[#self.path][1]) }
		--self:pop()
	 
	-- If the creep runs out of steps
	elseif cx >= 0 and #self.path == 0 then
		self.hp = 0
		wave_counter = wave_counter + 1
		self.creepImage.x = wave_counter*-240
		
	-- Otherwise, move the creep
	else 
		local path = self.path
		local size = #path
		local order = self:pathTop()
				
		-- Pick a direction
		if cx < order[2] then
			-- If it's less, then calculate the new position
			local pos = cx + MOVE
		
			-- If the new position would overshoot
			if pos >= order[2] then
				-- Find the remainder and move in the other axis that much
				local d = math.abs(order[2] - self.creepImage.x)
				self:pop()
				local new = self:pathTop()
				-- Check which direction the next order would have it move
				if self.creepImage.x < new[2] then self:step(d, 0)
				elseif self.creepImage.y > new[1] then self.creepImage.x = order[2] self:step(0, d)
				elseif self.creepImage.y < new[1] then self.creepImage.x = order[2] self:step(0, -d)
				end
			else
			-- If the new position doesn't overshoot, move normally
				self:step(MOVE, 0)
			end
			
		elseif cx > order[2] then 
			--print("left")
			local pos = cx - MOVE
			
			if pos <= order[2] then
				local d = math.abs(order[2] - self.creepImage.x)
				self:pop()
				local new = self:pathTop()
				if self.creepImage.y > new[1] then self.creepImage.x = order[2] self:step(0, d)
				elseif self.creepImage.y < new[1] then self.creepImage.x = order[2] self:step(0, -d)
				end
			else
				self:step(-MOVE, 0)
			end
			
		elseif cy < order[1] then 
			--print("down")
			local pos = cy + MOVE
			
			if pos >= order[1] then
				local d = math.abs(order[1] - self.creepImage.y)
				self:pop()
				local new = self:pathTop()
				if self.creepImage.x > new[2] then self.creepImage.y = order[1] self:step(d, 0)
				elseif self.creepImage.x < new[2] then self.creepImage.y = order[1] self:step(-d, 0)
				end
			else
				self:step(0, MOVE)
			end
			
		elseif cy > order[1] then 
			--print("up", self.creepImage.y, self.creepImage.x, order[1], order[2])
			local pos = cy - MOVE
			
			if pos <= order[1] then
				local d = math.abs(order[1] - self.creepImage.y)
				self:pop()
				local new = self:pathTop()
				if self.creepImage.x > new[2] then self.creepImage.y = order[1] self:step(d, 0)
				elseif self.creepImage.x < new[2] then self.creepImage.y = order[1] self:step(-d, 0)
				end
			else
				self:step(0, -MOVE)
			end
		end
		
	end
	
	if (self.hp == 0) then 
		dead = true
		self.greenBar.width = 0
		self.creepImage.opacity = 0
	end
end

function Creep:reset()
	
end

function Creep:step(x, y)

	self.creepImage.x = self.creepImage.x + x
	self.creepImage.y = self.creepImage.y + y

end

function Creep:pathTop()

	return { GTP(self.path[#self.path][1]), GTP(self.path[#self.path][2]) }

end

function Creep:pop()

	--print("pop", self.path[#self.path][1], self.path[#self.path][2] , #self.path)
	self.path[#self.path] = nil

end