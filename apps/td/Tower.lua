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

	bullet[1] = Clone { source = bulletImage }

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
	tower_elapsed_time = tower_elapsed_time + seconds
	if (math.floor(elapsed_time) % 3 == 0) then
		elapsed_time = elapsed_time + 1
		print ("shoot")
	end
	for i =1, self.bullet do
		if (self.bullet[i].x <= -50) then
			--screen:remove(self.bullet)
			self.bullet[i].x = -50
		else
			self.bullet[i]:animate {duration = 100, x = self.bullet[i].x - self.cooldown}
		end
	end
end
