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

	if self.tower.mode == "sprite" then
		self.tower.towerImageGroup.x = (self.x-1) * SP
		self.tower.towerImageGroup.y = (self.y-1) * SP - (self.tower.towerImage.h/SP - 1)*SP
	elseif self.tower.mode == "rotate" or self.tower.mode == "fire"  or self.tower.mode == "none" then
		self.tower.towerImageGroup.x = GTP(self.x-1) + self.tower.towerImage.w/2 - SP/2
		self.tower.towerImageGroup.y = GTP(self.y-1) + self.tower.towerImage.h/2 - SP/2
	end
	self.tower.towerImageGroup.z = 0.9+self.y*0.1
	--screen:add(self.tower.towerImage)
end

