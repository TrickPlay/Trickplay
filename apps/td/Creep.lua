Creep = { }

function Creep:new(args)
	local x = args.x
	local y = args.y
	local creepType = args.creepType
	local hp = args.hp
	local speed = args.speed
	local direction = args.direction or {1,0}
	local creepImage = Image { src = creepType , x = -100, y = 600}
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
	if (self.direction[1] ==1) then
		self.creepImage.x = self.creepImage.x + seconds*self.speed
	end
end
