local ms = 0

evFrame = Event()
	
local timeline = Timeline{loop = true, on_new_frame = function(self)
	ms = ms + self.delta
	evFrame(self.delta,ms)
end}

evFrame.stop = function()
	timeline:stop()
end

evFrame.start = function()
	timeline:start()
end

timeline:start()