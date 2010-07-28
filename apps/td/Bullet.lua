Bullet = {}

function Bullet:new(args)
	local object = {
		timer = Stopwatch(),
		image = AssetLoader:getImage(game.board.theme.themeName.."Bullet"..args.id,{}),
		frames = args.frames,
		time = .2,
		speed = args.speed,
	}
	
	object.length = object.image.w/object.frames
	object.image.extra.parent = object
	
	-- Animate the bullet if it has frames
	if args.frames then object.animation = true end
	
	-- If it has speed, then create a group for it to move in
	if object.speed then
	
		self.image.parent:remove(self.image)
		self.imageGroup = Group{}
		self.imageGroup:add(self.image)
		self.image.parent:add(self.imageGroup)
	
	end
	
	object.timer:start()
	
	setmetatable(object, self)
	self.__index = self
	return object
end

function Bullet:render()

	if self.animation then

		for i=1, self.frames do
			if self.timer.elapsed_seconds < ( 1/self.frames ) * i * self.time and self.timer.elapsed_seconds > ( 1/self.frames) * (i-1) * self.time then
				self.image.x = - self.length * (i-1)
			end
		end

		if self.timer.elapsed_seconds > self.time then
			self.image.parent:remove(self.image)
			self = nil
		end
		
	end

end
