Tower = {}
local tower_elapsed_time = 0

function Tower:new(args)
	local towerType = args.towerType
	local damage = args.damage
	local range = args.range
	local cost = args.cost
	local direction = args.direction
	local cooldown = args.cooldown
	local towerImage = Image {src = towerType}
	local isAttacking = false
	local bullet = {}
--	screen:add(bullet)

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

function Tower:render(seconds, creeps)
	--tower_elapsed_time = tower_elapsed_time + seconds
	--print (tower_elapsed_time)
	if (self.bullet.x <= 0) then
		--screen:remove(self.bullet)
		self.bullet.x = 0
	end
	print (creeps.creepImage[1].x)
	self.bullet:animate {duration = 100, x = self.bullet.x - self.cooldown}
	
end
