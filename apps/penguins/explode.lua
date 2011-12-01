local i, d, dt, d2, s, px, py
local snow   = {"explode-16","explode-24","explode-32"}

local group = Group{name = "explosion"}
overlay:add(group)
group:raise(penguin)

local anim = Timeline{duration = 2300}

function anim:on_new_frame(ms,t)
	d = self.delta
	dt = d/self.duration/2
	s = 1+dt*6
	d2 = 4^(d/1000)
	for k,v in ipairs(group.children) do
		v.opacity = math.max(0,v.opacity+v.vo*d)
		if v.opacity == 0 then
			v:free()
		else
			v.vx = v.vx/d2 + dt
			v.vy = v.vy/d2 + dt/4
			v.x = v.x + v.vx*d
			v.y = v.y + v.vy*d
			if v.z2 then
				v.vz = v.vz+dt
				v.z_rotation = {v.z_rotation[1]+v.vz*d,v.z2,v.z3}
			else
				v.scale = {v.scale[1]*s,v.scale[2]*s}
			end
		end
	end
end

return function(bank)
	px, py = penguin.x + penguin.w/2, penguin.y + penguin.h/2
	
	if not bank or bank > 5 then
		group:raise(penguin)
		s = Image{src = "explode-128", opacity = 255,
			anchor_point = {64,64}, scale = {1,1}}
		s.x, s.y = px, py - (bank and 20 or 0)
		s.vx, s.vy = 0, (bank and -0.06 or 0)
		s.vo = -255/800
		group:add(s)
	else
		group:lower(penguin)
	end
	
	py = py - (bank and bank > 5 and 30 or 0)
	for i=1,(bank or rand(15,20)) do
		s = Image{src = snow[rand(#snow-(bank and 1 or 0))]}
		s.x, s.y = px, py
		s.vx, s.vy = nrand(0.25), bank and nrand(0.2)-0.15 or nrand(0.25)
		s.z2 = nrand(0.2)+0.9
		s.scale = {s.z2,s.z2}
		s.z2, s.z3 = s.w*nrand(0.7), s.h*nrand(0.7)
		s.z_rotation = {rand(360),s.z2,s.z3}
		s.vz = 0.1
		s.opacity = 127 + rand(128)
		s.vo = -255/2000
		group:add(s)
	end
	
	anim:rewind()
	anim:start()
end