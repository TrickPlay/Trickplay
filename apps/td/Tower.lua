Tower = {}

function Tower:new(args, prefix, square, player)


	local object = {
		-- Tower defaults
		table = args,
		levels = 0,
		level = 0,
		prefix = prefix,
		square = square,
		owner = player,
                name = args.name,
		
		-- Position
		x = GTP(square.x),
		y = GTP(square.y),
		z = 1+GTP(GTP(square.y)),
		rotation = 0,
		
		-- Tower properties (from theme)
		bullet = args.bullet,
		damage = args.damage,
		range = args.range,
		direction = args.direction,
		attacksFlying = args.attacksFlying,
		slowammount = args.slowammount,
		slow = args.slow,
		slowlength = args.slowlength or 0,
		frames = args.frames,
		splash = args.splash,
		splashradius = args.splashradius,
		cooldown = args.cooldown,
		cost = args.cost,
		simpleRotate = args.simpleRotate,
		mode = args.mode or "none",
		attackMode = args.attackMode or "none",
		attackFrames = args.attackFrames or 1,
		damageAroundSelf = args.damageAroundSelf,
		
		-- Images
		towerImage = towerImage,
		towerImageGroup = towerImageGroup,
		fireImage = fireImage,
		-- Stopwatch
		timer = Stopwatch(),
                
                -- Bullet sound
                sound = args.sound or nil,
        }
        
   	local rangeCircle = Canvas{color=player.color, x=0, y=0, width=1920, height=1080, z = 0, opacity = 0}
        rangeCircle:begin_painting()
        rangeCircle:set_source_color(player.color)
        rangeCircle:arc(object.x+SP/2,object.y+SP/2,object.range,0,360)
        rangeCircle:fill() -- or c:stroke()
        rangeCircle:finish_painting()
        object.rangeCircle = rangeCircle
                
   	if args.upgrades then
                object.levels = #args.upgrades
                object.upgradeCost = args.upgrades[1].cost
        end

	-- Instructions for rotating through 8 sprites
	if args.mode == "sprite" then
	
		object.directionTable = {}
		local od = object.directionTable
		local x = object.x
		local y = object.y
		
		od[1] = { y,	y+SP,	0,		x }
		od[2] = { 0,	y,		0,		x }		
		od[3] = { 0,	y,		x-30,	x+SP }
		od[4] = { 0,	y,		x+SP,	1920 }
		od[5] = { y,	y+SP,	x+SP, 	1920 }
		od[6] = { y+50,	1080,	x+SP,	1920 }
		od[7] = { y+50,	1080,	x-30,	x+SP }
		od[8] = { y+50,	1080,	0,		x }	

	end
	
	-- If it has bullets, create the bullet group and add it to the screen
	if object.bullet then object.bgroup = Group{} screen:add(object.bgroup) end
   
	-- This is the actual image
	object.towerImage = AssetLoader:getImage(prefix..args.name,{})
	
	-- This is the clipping group
	object.towerImageGroup = Group{ clip={0,0,object.towerImage.w/object.frames,object.towerImage.h}}
	
	-- This is the firing overlay
	object.fireImage = AssetLoader:getImage(prefix..args.name.."Fire",{})
	
	object.towerImageGroup:add(object.towerImage)
	screen:add(object.towerImageGroup, rangeCircle)
        
        -- Add a colored rectangle behind the tower
        if game.board.player2 then
        
                if player == game.board.player then
                        
                        object.color = AssetLoader:getImage( "TowerShadow1",{ x=object.x - 10, y=object.y - 10} ) --Rectangle{w=SP,h=SP,x=object.x, y=object.y, opacity = 50, color=player.color}
                        screen:add(object.color)
                else
                        object.color = AssetLoader:getImage( "TowerShadow2",{ x=object.x - 10, y=object.y - 10} )
                        screen:add(object.color)
                
                end
        
        end
   
   setmetatable(object, self)
   self.__index = self
   return object
end

function Tower:destroy()
        screen:remove(self.color)
	self.towerImage.opacity = 0
	self.damage = 0
end

function Tower:render(seconds, creeps)

	local s = self.timer.elapsed_seconds
	
	self.rangeCircle.opacity = 0
	-- Render bullets
	if self.bgroup then self.bgroup:foreach_child( function(child) child.extra.parent:render(seconds)  end ) end
	
	
	--print(self.mode, self.fired, self.attackFrames > 1, s < self.cooldown/4)
	if (self.mode == "fire" or self.attackMode == "fire") and self.fired and self.attackFrames > 1 and s < self.cooldown/4 then
		
		local w = self.fireImage.w/self.attackFrames
		
		local percentage = s / (self.cooldown/4)
		
		self.fireImage.x = - w * ( math.floor( self.attackFrames * percentage ) )
		
	end
	
	
	if self.fired and s > self.cooldown/4 then self.towerImageGroup:remove(self.fireImage) self.fired = nil end
	--print("1")
	if (s > self.cooldown) then
		self.timer:start()
		for i = 1, #creeps do
			local cx = creeps[i].creepGroup.x
			local cy = creeps[i].creepGroup.y					
			if (creeps[i].slowtimer.elapsed_seconds > self.slowlength and self.slow) then
				creeps[i].speed = creeps[i].max_speed
				creeps[i].slowed = false
			end
			if (cx > self.x - self.range and cx < self.x + self.range and cy > self.y - self.range and cy < self.y + self.range and creeps[i].hp ~=0 and self.damage ~=0 and cx > 0) then
				if (creeps[i].flying and self.attacksFlying == false) then break end
				self:animateTower(creeps,i)
				self:attackCreep(creeps,i,1)
				self:animateFire(seconds, creeps[i])
				if (self.splash) then
					self:checkSplash(creeps,i)
				end
				creeps[i].attacked = true
				break
			else
				creeps[i].attacked = false
			end
		end

	end
end

function Tower:upgrade()


	assert(self.level < self.levels)
	self.level = self.level + 1
	
	local r = self.table.upgrades[self.level]
	
	if (self.owner.gold - r.cost >= 0) then
		local b = savedTowerUpgrades[self.tnum]
		savedTowerUpgrades[self.tnum] = b + 1
	
		self.damage = r.damage
		self.range = r.range
		self.rangeCircle:clear_surface()
		self.rangeCircle:begin_painting()
		self.rangeCircle:set_source_color(self.owner.color)
		self.rangeCircle:arc(self.x+SP/2,self.y+SP/2,self.range,0,360)
		self.rangeCircle:fill() -- or c:stroke()
		self.rangeCircle:finish_painting()
		self.cooldown = r.cooldown
		self.slowammount = r.slowammount
		self.splash = r.splash or self.splash
		self.cost = self.cost + r.cost
		self.towerImageGroup:remove(self.towerImage, self.fireImage)
		self.fireImage = AssetLoader:getImage(self.prefix..self.table.name.."Fire"..self.level,{x=self.fireImage.x, y=self.fireImage.y, clip=self.fireImage.clip})
		self.towerImage = AssetLoader:getImage(self.prefix..self.table.name..self.level,{x=self.towerImage.x, y=self.towerImage.y, clip=self.towerImage.clip})
		self.towerImageGroup:add(self.towerImage)
		print(self.prefix..self.table.name..self.level)
                
                if self.table.upgrades[self.level+1] then
                        self.upgradeCost = self.table.upgrades[self.level+1].cost
                end
		
		--screen:add(AssetLoader:getImage(self.prefix..self.table.name.."Fire"..self.level,{x=self.fireImage.x, y=self.fireImage.y}))
	
		self.owner.gold = self.owner.gold - r.cost
		savedGold = self.owner.gold
		
		game.board:updateGold(self.owner)
		
		return true
	else
		self.level = self.level -1
	end
	
end

-- Tower rotation
-- or sprite movement
function Tower:animateTower(creeps,i)
	local cx = creeps[i].creepGroup.x
	local cy = creeps[i].creepGroup.y
        
        if game.board.theme.themeName ~= "pacman" then
                creeps[i]:bleed()
        end
	
	-- Simple rotation
	if self.mode == "rotate" then
		
		local dx = cx - (self.towerImageGroup.x + SP/2)
		local dy = cy - (self.towerImageGroup.y + SP/2)
		--print("rotating!")
		
		if dx == 0 then dx = 0.1 end
		
		local dir = (180/math.pi) * math.atan((dy)/(dx)) + 180
		if dx >= 0 then dir = dir + 180 end
		
		self.rotation = dir
		
		-- Rotate the image group only, not the image or the fire image
		
		self.towerImageGroup.z_rotation = { dir , self.towerImage.w/2 , self.towerImage.h/2 }
		
		if self.attackMode == "none" then self.towerImageGroup:add(self.fireImage) self.fired = true end
		
	
	-- Sprites with a direction table
	elseif self.mode == "sprite" then 
	
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

	end
	
	if self.attackMode == "fire" then
		
		self.fireImage.x = self.towerImage.x
		self.towerImageGroup:add(self.fireImage)
		self.fired = true
	
	end
end

function Tower:animateFire(seconds, creep)

	--print("Fire")

	-- Creep needs a bullet number in order to fire
	if self.bullet then
	
		local bullet = Bullet:new( game.board.theme.bullets[self.bullet], creep, self.rotation, self.damage )
		
		local frames = bullet.frames or 1

		-- Create a bullet group if none exists
		if not self.bgroup then
			self.bgroup = Group{}
			screen:add(self.bgroup)
		end
		
		-- This group handles position, clipping, and rotation for the bullet
		bullet.imageGroup = 
			Group {
				x = self.x + SP/2, 
				y = self.y + SP/2, 
				h = bullet.image.h, 
				w = bullet.image.w/frames, 
				anchor_point = { bullet.image.w/(frames*2), bullet.image.h/2 }, 
				clip={0, 0, bullet.image.w/(frames), bullet.image.h},
			}
		bullet.imageGroup.z_rotation = {self.rotation, 0, 0}
			
		bullet.imageGroup:add(bullet.image)
		bullet.imageGroup.extra.parent = bullet
		self.bgroup:add(bullet.imageGroup)
		
		if game.bulletSounds < BULLET_SOUND_LIMIT then
                        bullet.sound = true
                        game.bulletSounds = game.bulletSounds + 1
                        print(game.bulletSounds)
                        mediaplayer:play_sound("themes/"..game.board.theme.themeName.."/sounds/"..self.sound)
                end
	
	elseif self.sound then
        
                mediaplayer:play_sound("themes/"..game.board.theme.themeName.."/sounds/"..self.sound)
        
        end

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
		
		if self.damageAroundSelf and cxj > self.x - radius and cxj < self.x + radius and cyj > self.y - radius and cyj < self.y + radius then
			self:attackCreep(creeps,j,intensity)			
		
		elseif (cxj > cx - radius and cxj < cx + radius and cyj > cy - radius and cyj < cy + radius and j ~= i) then
			--print ("Distance: "..distance)
			--print ("Intensity: "..intensity)
			if (not self.bullet) then
				self:attackCreep(creeps,j,intensity)
			end
		end
	end
end

function Tower:attackCreep(creeps, i, intensity)
	local cx = creeps[i].creepGroup.x
	local cy = creeps[i].creepGroup.y
	if (creeps[i].flying and self.attacksFlying == false) then
		return
	end
	if (self.slow) then 
		creeps[i].slowtimer:start()
--		creeps[i].speed = creeps[i].max_speed*(self.slowammount/100)*intensity 
		if (creeps[i].slowed == false) then
			creeps[i].slowed = true
			creeps[i].speed = creeps[i].max_speed*(self.slowammount/100)*intensity 
		end
	end
	if (not self.bullet) then
		creeps[i].hp = creeps[i].hp - self.damage*intensity
		if (creeps[i].hp <=0 ) then creeps[i].hp = 0 end
--		creeps[i].hit = false
	end	
	
end
