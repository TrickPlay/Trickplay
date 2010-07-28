Bullet = {}

function Bullet:new(args, creep)

	--print(game.board.theme.themeName.."Bullet"..args.id)

	local object = {
		timer = Stopwatch(),
		image = AssetLoader:getImage(game.board.theme.themeName.."Bullet"..args.id,{z = 4} ),
		frames = args.frames,
		time = .2,
		speed = args.speed,
		creep = creep,
	}
	
	--screen:add(AssetLoader:getImage(game.board.theme.themeName.."Bullet"..args.id,{z = 10, x=200, y=200}))
	
	
	if object.frames then object.length = object.image.w/object.frames else object.length = object.image.w end
	--object.image.extra.parent = object
	
	-- Animate the bullet if it has frames
	if args.frames then object.animation = true end
	
	-- If it has speed, then create a group for it to move in
	--if object.speed then
	
		--local container = object.image.parent
		--print(container, ":)")
		--container:remove(object.image)
		--object.imageGroup = Group{}
		--object.imageGroup:add(object.image)
		--container:add(object.imageGroup)
	
	--end
	
	--print(object.image, "!")
	
	object.timer:start()
	
	setmetatable(object, self)
	self.__index = self
	return object
end

function Bullet:render(seconds)

	if self.animation then
	
		--print(1)

		for i=1, self.frames do
			if self.timer.elapsed_seconds < ( 1/self.frames ) * i * self.time and self.timer.elapsed_seconds > ( 1/self.frames) * (i-1) * self.time then
				self.image.x = - self.length * (i-1)
			end
		end
		
		--print(2)

		if self.timer.elapsed_seconds > self.time then
			self.imageGroup:remove(self.image)
			self.imageGroup.parent:remove(self.imageGroup)
			self = nil
			return
		end
		
		--print(3)
		
	end
	

	
	if self.speed then
	
		local xtarget = self.creep.creepGroup.x + self.creep.creepImageGroup.clip[3]/2
		local ytarget = self.creep.creepGroup.y + self.creep.creepImageGroup.clip[4]/2
	
		--local d = math.sqrt( (self.creep.creepGroup.x-self.imageGroup.x)^2 + (self.creep.creepGroup.y-self.imageGroup.y)^2 )
		--print(d)
		
		local dx = self.imageGroup.x - xtarget
		local dy = self.imageGroup.y - ytarget
		
		local xratio = dx/( math.abs(dx) + math.abs(dy) )
		local yratio = dy/( math.abs(dx) + math.abs(dy) )
		
		self.imageGroup.x = self.imageGroup.x - xratio * seconds * self.speed
		self.imageGroup.y = self.imageGroup.y - yratio * seconds * self.speed
		
		--self.imageGroup.x = self.imageGroup.x + self.speed*seconds --end if self.imageGroup.x < self.creepGroup.x then
		
		if (dx < 5 and dy < 5) or self.imageGroup.x > 1920 or self.imageGroup.x < 0 or self.imageGroup.y > 1080 or self.imageGroup.y < 0 then 
			self.imageGroup:remove(self.image)
			self.imageGroup.parent:remove(self.imageGroup)
			self = nil 
			return 
		end
	
	end

end

--math.sqrt( ( (self.creepGroup.x-self.imageGroup.x)(self.creepGroup.x-self.imageGroup.x) ) + ( (self.creepGroup.y-self.imageGroup.y)(self.creepGroup.y-self.imageGroup.y) )  )
