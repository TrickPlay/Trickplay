local duration = 40 * #explosion.children
local frame = 1
local y = 0
local vy = 0

local timer = Timer(40,function(timer)
	if frame > #explosion.children then
		return false
	elseif frame > 1 then
		explosion.children[frame-1].opacity = 0
	end
	explosion.children[frame].opacity = 255
	frame = frame + 1
end)
timer:stop()

local anim = Timeline{ duration = duration,
	on_new_frame = function(self,ms,t)
		penguin.img.y = y + vy*ms + gravity*ms*ms/128
	end,
	on_completed = function(self)
		timer:stop()
		
		for k,v in pairs(explosion.children) do
			v.opacity = 0
		end
		screen:remove(explosion)
		frame = 1
		
		update_reset(false)
		penguin.skating:start()
	end
}

local start = function(_y,_vy)
	y = _y
	vy = _vy
	timer:start()
	anim:start()
end

return {start = start, duration = duration, count = 0};