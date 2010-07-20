Player = {}

function Player:new(args)
	local name = args.name
	local gold = args.gold
	local object = {
		name = name,
		gold = gold
	}
   setmetatable(object, self)
   self.__index = self
   return object
end
