Creep = { }

function Creep:new(args, x, y)
	local creepType = args.creepType
	local hp = args.hp
	local speed = args.speed
	local direction = args.direction or {0,1}
	local creepImage = Image { src = creepType , x = x, y = y-60}
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

	if (self.creepImage.x >= 0) then
		if (#self.path==0) then
			game.board.nodes = game.board:createNodes()
			local found
			found, self.path = astar.CalculatePath(game.board.nodes[ math.floor(self.creepImage.y/60)+1 ][ math.floor(self.creepImage.x/60)+1 ], game.board.nodes[ 7 ][ 32 ], MyNeighbourIterator, MyWalkableCheck, MyHeuristic, MyConditional)
		end
	end

	if (not self.creepImage.is_animating) then
		local path = self.path
		if #path > 1 then self.direction = {  - path[#path][1] + path[#path-1][1], - path[#path][2] + path[#path-1][2] } path[#path] = nil end
--		print (self.direction[1], self.direction[2])
		self.creepImage:animate {duration = 1/self.speed * 10000, x = self.creepImage.x + self.direction[2] * 60, y = self.creepImage.y + self.direction[1] * 60}
--		self.creepImage.x = self.creepImage.x + self.direction[2]*60*seconds
--		self.creepImage.y = self.creepImage.y + self.direction[1]*60*seconds

	end
	
	--	self.creepImage.x = self.creepImage.x + self.direction[1]*seconds*self.speed
--	self.creepImage.y = self.creepImage.y + self.direction[2]*seconds*self.speed
end
