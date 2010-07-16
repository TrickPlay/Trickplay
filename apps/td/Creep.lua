Creep = {}

function Creep:new(args)
	local x = args.x
	local y = args.y
	local creepType = args.creepType
	local hp = args.hp
	local speed = args.speed
	local direction = args.direction
	local object = {
		x = x,
		y = y,
		creepType = creepType
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Creep:render()
	
end
