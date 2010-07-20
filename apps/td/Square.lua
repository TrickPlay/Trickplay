Square = {}

function Square:new(args)
	local x = args.x
	local y = args.y
	local state = args.state
	local isSelected = false
	local tower = nil
	local hasTower = false
	local object = {
		x = x,
		y = y,
		state = state,
		isSelected = isSelected,
		tower = tower,
		hasTower = hasTower		
	}
   setmetatable(object, self)
   self.__index = self
   return object
end

function Square:render()
	self.tower.towerImage.x = (self.x-1) * SPW
	self.tower.towerImage.y = (self.y-1) * SPH
	screen:add(self.tower.towerImage)
end
