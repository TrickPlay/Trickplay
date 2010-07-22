Square = {}

function Square:new(args)
	local square = {args.y, args.x, args.state}
	local x = args.x
	local y = args.y
	local isSelected = false
	local tower = nil
	local hasTower = false
	local object = {
		square = square,
		x = x,
		y = y,
		isSelected = isSelected,
		tower = tower,
		hasTower = hasTower		
	}
   setmetatable(object, self)
   self.__index = self
   return object
end

function Square:render()
	self.tower.towerImage.x = (self.x-1) * SP
	self.tower.towerImage.y = (self.y-1) * SP
	screen:add(self.tower.towerImage)
end

