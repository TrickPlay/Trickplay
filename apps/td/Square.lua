Square = {}

function Square:new(args)
	local x = args.x
	local y = args.y
	local state = args.state
	local isSelected = false
		
	local object = {
		x = x,
		y = y,
		state = state,
		isSelected = isSelected
   }
   setmetatable(object, self)
   self.__index = self
   return object
end
