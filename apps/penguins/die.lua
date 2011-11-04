local x, vx, y, vy, r, vr = 0, 0, 0, 0, 0, 0
local sink = false

local anim = Timeline{ duration = 500,
	on_new_frame = function(self,ms,t)
		penguin.x = x + vx*ms
		penguin.y = y + vy*ms + gravity*ms*ms/128
		penguin.z_rotation = {r + vr*ms,penguin.w/2,penguin.h/2}
		penguin.opacity = 255*(1-ms/self.duration)
		if sink and penguin.y > y+40 then
			self:stop()
			self.on_completed()
		end
	end,
	on_completed = function(self)
		if sink then
			explode()
		end
		penguin.reset(1,1)
		penguin.skating:start()
	end
}

return function(_vx,_vy,_vr,_s)
	x, y, r = penguin.x, penguin.y, penguin.z_rotation[1]
	vx, vy, vr = _vx, _vy, _vr
	sink = _s
	if sink then
		anim.duration = 200
	else
		anim.duration = 500
	end
	anim:rewind()
	anim:start()
end