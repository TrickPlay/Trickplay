local loopuri, looptime
local recent = {}
local on = true

local play = function(uri)
	if on and not recent[uri] then
		mediaplayer:play_sound("audio/" .. uri .. ".mp3")
		recent[uri] = 1
	end
end

local timer = Timer{on_timer = function(self)
		play(loopuri)
		self.interval = looptime
	end}
local loop = function(uri,time)
	loopuri = uri
	looptime = time
	if timer.interval == 0 then
		play(loopuri)
		timer.interval = time
	end
	timer:start()
end

local fresh = function()
	recent = {}
end

local toggle = function()
	on = not on
end

return {play = play, loop = loop, fresh = fresh, toggle = toggle}