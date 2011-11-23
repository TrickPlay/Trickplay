local i, d, t1, s, m2, mz1
local snow   = {"explode-16","explode-24","explode-32"}

local group = Group{name = "explosion"}
overlay:add(group)
group:raise(penguin)

local anim = Timeline{duration = 2300}

function anim:on_new_frame(ms,t)
	t1 = t*t*100
	s = 1+t*3
	m2 = ms/2^(ms/1000)
	mz1 = ms*ms/8000
	for k,v in ipairs(group.children) do
		v.opacity = math.max(0,v.oo+v.vo*ms)
		if v.opacity == 0 then
			v:free()
		else
			v.x = v.ox + v.vx*m2 + t1*6
			v.y = v.oy + v.vy*m2 + t1
			if v.z1 then
				v.z_rotation = {v.z1+mz1,v.z2,v.z3}
			else
				v.scale = {v.os*s,v.os*s}
			end
		end
	end
end

return function(vx,vy)
	if anim.is_playing then
		local ms = anim.elapsed
		local t = ms/anim.duration
		m2 = 1/2^(ms/1000)
		t1 = t*200/anim.duration
		
		for k,v in ipairs(group.children) do
			v.ox, v.oy = v.x, v.y
			v.vx, v.vy = v.vx*m2 + t1*6, v.vy*m2 + t1
			if v.z1 then
				v.z1 = v.z_rotation[1]
			end
			v.os = v.scale[1]
			v.oo = v.opacity
		end
	end
	
	local px, py = penguin.x + penguin.w/2, penguin.y + penguin.h/2
	
	local p = Image{src = "explode-128", opacity = 255,
		anchor_point = {64,64}, scale = {1,1}}
	group:add(p)
	p.x, p.y, p.ox, p.oy = px, py, px, py
	p.vx, p.vy = 0, 0
	p.oo, p.os, p.vo = 255, 1, -255/800
	
	for i=1,rand(15,20) do
		s = Image{src = snow[rand(#snow)]}
		group:add(s)
		s.x, s.y, s.ox, s.oy = px, py, px, py
		s.vx, s.vy = nrand(0.25), nrand(0.25)
		s.z1, s.z2, s.z3 = rand(360), s.w*nrand(0.7), s.h*nrand(0.7)
		s.z_rotation = {s.z1,s.z2,s.z3}
		s.oo = 127 + rand(128)
		s.opacity = s.oo
		s.vo = -255/2000
	end
	
	anim:rewind()
	anim:start()
end