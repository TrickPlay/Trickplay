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
	local path = {}
	local dead = false
	local bounty = args.bounty
	local object = {
		hp = hp,
		max_hp = max_hp,
		speed = speed,
		direction = direction,
		creepType = creepType,
		creepImage = creepImage,
		greenBar = greenBar,
		redBar = redBar,
		path = path,
		dead = dead,
		bounty = bounty
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Creep:render(seconds)

	local cx = self.creepImage.x
	local cy = self.creepImage.y
	if (cx >= 0) then
		if (#self.path==0) then
			local found
			found, self.path = astar.CalculatePath(game.board.nodes[ PTG(cy) ][ PTG(cx) ], game.board.nodes[ 4 ][ BW ], MyNeighbourIterator, MyWalkableCheck, MyHeuristic)
			
		end
	end
	
	if cx < 0 and (not self.creepImage.is_animating) then
		self.creepImage.x = cx + self.speed*seconds*2
		
	elseif (cx >1920) then
		self.hp = 0
		wave_counter = wave_counter + 1
		self.creepImage.x = wave_counter*-240
		
	elseif (not self.creepImage.is_animating) then
		local path = self.path
		local size = #path
		if size > 0 then
			self.creepImage:animate {duration = 1/self.speed * 10000, x = GTP( path[size][2] ), y = GTP( path[size][1] ) }
			self.greenBar:animate {duration = 1/self.speed * 10000, x = GTP( path[size][2] ), y = GTP( path[size][1] ), width = SP*self.hp/self.max_hp}
			path[size] = nil
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



--		self.creepImage.x = self.creepImage.x + self.direction[2]*60*seconds
--		self.creepImage.y = self.creepImage.y + self.direction[1]*60*seconds
--		self.creepImage.x = self.creepImage.x + self.direction[1]*seconds*self.speed
--		self.creepImage.y = self.creepImage.y + self.direction[2]*seconds*self.speed

