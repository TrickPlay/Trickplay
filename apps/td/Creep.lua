Creep = { }

function Creep:new(args, x, y)
	local creepType = args.creepType
	local hp = args.hp
	local speed = args.speed
	local direction = args.direction or {0,1}
	local creepImage = Image { src = creepType , x = x, y = y}
	local path = {}
	local object = {
		hp = hp,
		speed = speed,
		direction = direction,
		creepType = creepType,
		creepImage = creepImage,
		path = path
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
			game.board.nodes = game.board:createNodes()
			local found
			found, self.path = astar.CalculatePath(game.board.nodes[ PTG(cy) ][ PTG(cx) ], game.board.nodes[ 8 ][ 32 ], MyNeighbourIterator, MyWalkableCheck, MyHeuristic, MyConditional)
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
			path[size] = nil
		end
	end

end

function Creep:reset()
	
end



--		self.creepImage.x = self.creepImage.x + self.direction[2]*60*seconds
--		self.creepImage.y = self.creepImage.y + self.direction[1]*60*seconds
--		self.creepImage.x = self.creepImage.x + self.direction[1]*seconds*self.speed
--		self.creepImage.y = self.creepImage.y + self.direction[2]*seconds*self.speed

