Tower = {}

function Tower:new(args, prefix)
	-- Tower knows where it came from, so it can access its own data in "table"
	local table = args
	local levels
	if table.upgrades then levels = #table.upgrades else levels = 0 end
	local level = 0
	local prefix = prefix
	
	--local towerType = args.towerType
	local damage = args.damage
	local range = args.range
	local cost = args.cost
	local direction = args.direction
	local cooldown = args.cooldown
	local slowammount = args.slowammount
	local slow = args.slow
	local splash = args.splash
	local splashradius = args.splashradius
	local frames = args.frames

	-- Image stuff
	local towerImage = AssetLoader:getImage(prefix..table.name,{})
	local towerImageGroup = Group{ clip={0,0,towerImage.w/frames,towerImage.h}}
--	towerImageGroup.y = towerImageGroup.y - ((towerImage.h/SP)-1)*SP
	local fireImage = AssetLoader:getImage(prefix..table.name.."Fire",{})
	towerImageGroup:add(towerImage)
	screen:add(towerImageGroup)
	
	local isAttacking = false
	local bullet = Clone {source = shootAnimation, opacity = 0}
	screen:add(bullet)
	--local levels = game.board.theme
	
	local timer = Stopwatch()
	
	local object = {
		table = table,
		levels = levels,
		level = level,
		prefix = prefix,
		bullet = bullet,
		towerType = towerType,
		damage = damage,
		range = range,
		direction = direction,
		slowammount = slowammount,
		slow = slow,
		frames = frames,
		splash = splash,
		splashradius = splashradius,
		cooldown = cooldown,
		cost = cost,
		towerImage = towerImage,
		towerImageGroup = towerImageGroup,
		isAttacking = isAttacking,
		timer = timer,
		fireImage = fireImage,
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

	local s = self.timer.elapsed_seconds
	self.bullet.x = self.x
	self.bullet.y = self.y
	self.bullet.z = 2	
	self.bullet.opacity = 0
	
	if self.fired and s > self.cooldown/4 then self.towerImageGroup:remove(self.fireImage) self.fired = nil end
	--print("1")
	if (s > self.cooldown) then
		self.timer:start()
		for i = 1, #creeps do
			local cx = creeps[i].creepGroup.x
			local cy = creeps[i].creepGroup.y					
			creeps[i].speed = creeps[i].max_speed
	
			if (cx > self.x - self.range and cx < self.x + self.range and cy > self.y - self.range and cy < self.y + self.range and creeps[i].hp ~=0 and self.damage ~=0) then
				self:attackCreep(creeps,i,1)
				if (self.splash) then
					self:animateFire()
					self:checkSplash(creeps,i)
				end
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
	
	if (game.board.player.gold - r.cost >0) then
	
		self.damage = r.damage
		self.range = r.range
		self.cooldown = r.cooldown
		self.slowammount = r.slowammount
		self.cost = self.cost + r.cost
		self.towerImageGroup:remove(self.towerImage)
		self.towerImage = AssetLoader:getImage(self.prefix..self.table.name..self.level,{x=self.towerImage.x, y=self.towerImage.y, clip=self.towerImage.clip})
		self.towerImageGroup:add(self.towerImage)
		print(self.prefix..self.table.name..self.level)

		game.board.player.gold = game.board.player.gold - r.cost
		goldtext.text = game.board.player.gold
	else
		self.level = self.level -1 	
	end
	
end

function Tower:animateFire()
	
	
end

function Tower:checkSplash(creeps,i)
	-- if self.splash is true or something
	local cx = creeps[i].creepGroup.x
	local cy = creeps[i].creepGroup.y	
	local radius = self.splashradius

	for j =1, #creeps do
		local cxj = creeps[j].creepGroup.x
		local cyj = creeps[j].creepGroup.y
		local distance = math.sqrt(((cxj-cx)*(cxj-cx))+((cyj-cy)*(cyj-cy)))
		local intensity = 1-(radius-distance)/radius
		if (cxj > cx - radius and cxj < cx + radius and cyj > cy - radius and cyj < cy + radius and j ~= i) then
			--print ("Distance: "..distance)
			--print ("Intensity: "..intensity)
			self:attackCreep(creeps,j,intensity)
		end
	end
end

function Tower:attackCreep(creeps, i, intensity)
	--self.bullet.opacity = 255
	local cx = creeps[i].creepGroup.x
	local cy = creeps[i].creepGroup.y
	if (self.slow) then creeps[i].speed = creeps[i].max_speed*(self.slowammount/100)*intensity end

	if self.directionTable then 
		local d = self.directionTable
		local dir
		for i = 1, #d do
			local di = d[i]
			if cy >= di[1] and cy <= di[2] and cx >= di[3] and cx <= di[4] then dir = i break end
		end
		if dir == nil then print (cx, cy) end
	
		self.towerImage.x = - SP * (dir - 1)
	
		self.fireImage.x = self.towerImage.x
		
		self.towerImageGroup:add(self.fireImage)
		self.fired = true
		--self.towerImage.x = self.x - SP * (dir - 1)
		--self.towerImage.clip = { SP * (dir - 1), 0, SP, SP }

	end
			
	creep_in_range = true

	creeps[i].hp = creeps[i].hp - self.damage*intensity
	creeps[i]:bleed()
	
	if (creeps[i].hp <=0) then creeps[i].hp =0 end

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
	
