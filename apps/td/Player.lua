Player = {}

function Player:new(args)
	local name = args.name
	local gold = args.gold
	local lives = args.lives
	local object = {
		name = name,
		gold = gold,
		lives = lives
	}
   setmetatable(object, self)
   self.__index = self
   return object
end
