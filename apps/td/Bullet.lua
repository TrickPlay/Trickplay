Bullet = {}

function Bullet:new(args)
	local object = {
		timer = Stopwatch(),
		image = AssetLoader:getImage(game.board.theme.themeName.."Bullet"..args.id,{}),
		frames = args.frames,
		time = .2,
	}
	
	print(game.board.theme.themeName.."Bullet"..args.id)
	
	if args.frames then object.animation = true end
	object.timer:start()
	object.image.extra.parent = object
	object.length = object.image.w/object.frames
	
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
