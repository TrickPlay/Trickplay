Player = {}

function Player:new(args)

	local object = {
		name = args.name,
		gold = args.gold,
		lives = args.lives,
		color = args.color,
	}
	
   setmetatable(object, self)
   self.__index = self
   return object
end
