local loopuri, looptime
local recent = {}
local on = false --true

local play = function(uri,force)
	if on and not recent[uri] or force then
		mediaplayer:play_sound("audio/" .. uri .. ".mp3")
		recent[uri] = 1
	end
end

local timer = Timer{on_timer = function(self)
	play(loopuri,true)
	self.interval = looptime
end}

local loop = function(uri,time)
	loopuri = uri
	looptime = time
	if timer.interval == 0 then
		play(uri)--,true)
		timer.interval = time
	end
	timer:start()
end

local toggle = function()
	on = not on
end

evFrame[mediaplayer] = function()
	if on then
		recent = {}
	end
end

return {play = play, loop = loop, toggle = toggle}