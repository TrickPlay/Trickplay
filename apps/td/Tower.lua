Tower = {}

function Tower:new(args)
	local towerType = args.towerType
	local damage = args.damage
	local range = args.range
	local direction = args.direction
	local cooldown = args.cooldown
	local towerImage = Image {src = towerType}
	local isAttacking = false
	
	local object = {
		towerType = towerType,
		damage = damage,
		range = range,
		direction = direction,
		cooldown = cooldown,
		towerImage = towerImage,
		isAttacking = isAttacking
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Tower:destroy()

end

function Tower:attack()

end

function Tower:render()
	
end
