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
	local bullets = {}
	local tower_elapsed_time = 0
	
	local object = {
		towerType = towerType,
		damage = damage,
		range = range,
		direction = direction,
		cooldown = cooldown,
		cost = cost,
		towerImage = towerImage,
		isAttacking = isAttacking,
		bullets = bullets,
		tower_elapsed_time = tower_elapsed_time
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
	self.tower_elapsed_time = self.tower_elapsed_time + seconds
	
	for i = 1, #creeps do
		if (creeps[i].creepImage.x > self.towerImage.x - self.range and creeps[i].creepImage.x < self.towerImage.x + self.range
				and creeps[i].creepImage.y > self.towerImage.y - self.range and creeps[i].creepImage.y < self.towerImage.y + self.range) then
			print ("creep "..i.." in range")
		end
	end
	
	if (math.floor(self.tower_elapsed_time) % 2 == 0) then
		local temp_bullet = Clone { source = bulletImage, x = self.towerImage.x, y = self.towerImage.y }
		screen:add(temp_bullet)
		table.insert(self.bullets,temp_bullet)
		self.tower_elapsed_time = self.tower_elapsed_time + 1
	end
	for i=1, #self.bullets do
		self.bullets[i]:animate {duration = 100, x = self.bullets[i].x - self.cooldown}
		if (self.bullets[i].x <= -50) then
			--screen:remove(self.bullet)
			self.bullets[i].x = -50
		end
	end
	
end
