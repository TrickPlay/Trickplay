Obstacle = {}

function Obstacle:new(args)
	local x = args.x
	local y = args.y
	local timer = Stopwatch()
	local obstacleImage = AssetLoader:getImage("obstacles", {})
	local obstacleGroup = Group{x = x, y = y, z = 1, clip = {0,0,SP,SP}}
	local frames = args.frames
	obstacleGroup:add(obstacleImage)
	
	local object = {
		timer = timer,
		obstacleImage = obstacleImage,
		obstacleGroup = obstacleGroup,
		x = x,
		y = y,
		frames = frames,
	}
   setmetatable(object, self)
   self.__index = self
   return object
end

function Obstacle:animate()
	local time = self.frames/10
	
	for i=1, self.frames do
		if self.timer.elapsed_seconds < ( 1/self.frames ) * i * time and self.timer.elapsed_seconds > ( 1/self.frames) * (i-1) * time then

			self.obstacleImage.x = - SP * (i-1)

		end
	end
	
	if self.timer.elapsed_seconds > time then
		self.timer:start()
	end
end
	

