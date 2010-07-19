Creep = { }

function Creep:new(args, x, y)
	local x = x
	local y = y
	local creepType = args.creepType
	local hp = args.hp
	local speed = args.speed
	local direction = args.direction or {1,0}
	local creepImage = Image { src = creepType , x = x, y = y}
	local object = {
		x = x,
		y = y,
		hp = hp,
		speed = speed,
		direction = direction,
		creepType = creepType,
		creepImage = creepImage
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Creep:render(seconds)
	if (not self.creepImage.is_animating) then 	
		self.creepImage:animate {duration = 1/self.speed * 10000, x = self.creepImage.x + self.direction[1] * 60}
	end
--	self.creepImage.x = self.creepImage.x + self.direction[1]*seconds*self.speed
--	self.creepImage.y = self.creepImage.y + self.direction[2]*seconds*self.speed
end
