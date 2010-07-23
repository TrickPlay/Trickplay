Tower = {}

function Tower:new(args, prefix)
	-- Tower knows where it came from, so it can access its own data in "table"
	local table = args
	local levels = #table.upgrades
	local level = 0
	local prefix = prefix
	
	--local towerType = args.towerType
	local damage = args.damage
	local range = args.range
	local cost = args.cost
	local direction = args.direction
	local cooldown = args.cooldown
	local slow = args.slow
	local towerImage = AssetLoader:getImage(prefix..table.name,{ clip={0,0,SP,SP} })
	local isAttacking = false
	local bullets = {}
	--local levels = game.board.theme
	
	local timer = Stopwatch()
	
	local object = {
		table = table,
		levels = levels,
		level = level,
		prefix = prefix,
		
		towerType = towerType,
		damage = damage,
		range = range,
		direction = direction,
		slow = slow,
		cooldown = cooldown,
		cost = cost,
		towerImage = towerImage,
		isAttacking = isAttacking,
		bullets = bullets,
		timer = timer,
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Tower:destroy()
	self.towerImage.opacity = 0
	self.damage = 0
end

function Tower:attack()

end

function Tower:render(seconds, creeps)
	local creep_in_range = false	
	local creep_to_kill
	
	local current
	local s = self.timer.elapsed_seconds
	--print("1")
	if (s > self.cooldown) then
		self.timer:start()
		for i = 1, #creeps do
			if (creeps[i].creepGroup.x > self.x - self.range and creeps[i].creepGroup.x < self.x + self.range
					and creeps[i].creepGroup.y > self.y - self.range and creeps[i].creepGroup.y < self.y + self.range and creeps[i].hp ~=0 and self.damage ~=0) then
				creeps[i].speed = creeps[i].max_speed*(self.slow/100)
			
				if self.directionTable then --print("creep "..i.." in range") 
			
					local cx = creeps[i].creepGroup.x
					local cy = creeps[i].creepGroup.y					
					local d = self.directionTable
					local dir
					for i = 1, #d do
						local di = d[i]
						if cy >= di[1] and cy <= di[2] and cx >= di[3] and cx <= di[4] then dir = i break end
					end
					if dir == nil then print (cx, cy) end
				
					self.towerImage.x = self.x - SP * (dir - 1)
					self.towerImage.clip = { SP * (dir - 1), 0, SP, SP }
			
				end
			
				current = i		
		
				creep_in_range = true
			
				creeps[i].hp = creeps[i].hp - self.damage
			
				if (creeps[i].hp <=0) then creeps[i].hp =0 end
				break
			end
		end
		if not self.directionTable then
			print("CREATED DIRECTION TABLE")
			self.directionTable = {}	
			self.directionTable[1] = { self.y,	self.y+SP,	0		,self.x }
			self.directionTable[2] = { 0,		self.y,		0		,self.x }		
			self.directionTable[3] = { 0,		self.y,		self.x-30,	self.x+SP }
			self.directionTable[4] = { 0,		self.y,		self.x+SP,	1920 }
			self.directionTable[5] = { self.y,	self.y+SP,	self.x+SP, 	1920 }
			self.directionTable[6] = { self.y+50,	1080,		self.x+SP,	1920 }
			self.directionTable[7] = { self.y+50,	1080,		self.x-30,	self.x+SP }
			self.directionTable[8] = { self.y+50,	1080,		0,		self.x }	
		end
	end
end

function Tower:upgrade()

	assert(self.level < self.levels)
	self.level = self.level + 1
	
	local r = self.table.upgrades[self.level]
	
	self.damage = r.damage
	self.range = r.range
	self.cooldown = r.cooldown
	self.slow = r.slow
	self.cost = r.cost
	screen:remove(self.towerImage)
	self.towerImage = AssetLoader:getImage(self.prefix..self.table.name..self.level,{x=self.towerImage.x, y=self.towerImage.y, clip=self.towerImage.clip})
	screen:add(self.towerImage)
	print(self.prefix..self.table.name..self.level)

	game.board.player.gold = game.board.player.gold - r.cost
	goldtext.text = game.board.player.gold

end














--			local temp_bullet = Clone { source = bulletImage, x = self.towerImage.x, y = self.towerImage.y }
--			screen:add(temp_bullet)
--			table.insert(self.bullets,temp_bullet)
			

	--[[for k,v in pairs(self.bullets) do
		v:animate {duration = 500, x = x_velocity, y = y_velocity}
		if (v.x <= -50) then
			v.x = -50
		end
	end]]
	
