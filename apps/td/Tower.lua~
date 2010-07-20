Tower = {}

function Tower:new(args)
	local towerType = args.towerType
	local damage = args.damage
	local range = args.range
	local cost = args.cost
	local direction = args.direction
	local cooldown = args.cooldown
	local towerImage = Image {src = towerType}
	local isAttacking = false
	local bullet = Rectangle { color = "FF0000", x = towerImage.x, y = towerImage.y, z = 2, width = 15, height = 15}
	screen:add(bullet)

	local object = {
		towerType = towerType,
		damage = damage,
		range = range,
		direction = direction,
		cooldown = cooldown,
		cost = cost,
		towerImage = towerImage,
		isAttacking = isAttacking,
		bullet = bullet
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Tower:destroy()
	self.towerImage.opacity = 0
end

function Tower:attack()

end

function Tower:render(seconds)
	self.bullet.x = self.bullet.x - seconds * self.cooldown
--	if (self.bullet.x <= 0) then
--		remove(self.bullet)
--	end	
end
