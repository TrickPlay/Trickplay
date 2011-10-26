local duration = 500
local x, vx, y, vy, r, vr = 0, 0, 0, 0, 0, 0
local i

local anim = Timeline{ duration = duration,
	on_new_frame = function(self,ms,t)
        i = penguin.img
        i.x = x + vx*ms
		i.y = y + vy*ms + gravity*ms*ms/128
        i.z_rotation = {r + vr*ms,i.w/2,i.h/2}
        i.opacity = 255*(1-ms/duration)
	end,
	on_completed = function(self)
		update_reset(false)
		penguin.skating:start()
	end
}

local start = function(_x,_vx,_y,_vy,_r,_vr,_vo)
    x, vx, y, vy, r, vr = _x, _vx, _y, _vy, _r, _vr
    if anim.is_playing then
        anim.rewind()
    else
        anim:start()
    end
end

return {start = start, duration = duration, count = 0};