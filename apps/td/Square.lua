Square = {}

function Square:new(args)
	local x = args.x
	local y = args.y
	local 	
	local object = {
		x = x,
		y = y
   }
   setmetatable(object, self)
   self.__index = self
   return object
end
