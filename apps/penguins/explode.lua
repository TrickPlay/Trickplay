local i, d, dt, d2, s, px, py, b
local snow		= {"explode-16","explode-24","explode-32"}
local chunks	= {"icechunk-1","icechunk-2","icechunk-3","icechunk-4"}
local splashes	= {"splash-1","splash-2"}

group = overlay.explode
group:raise(penguin)
group.level = levels.this.id

local anim = Timeline{duration = 2300}

function anim:on_new_frame(ms,t)
	d = self.delta
	dt = d/self.duration/2
	s = 1+dt*6
	d2 = 4^(d/1000)
	b = levels.this.bank > 0
	for k,v in ipairs(group.children) do
		v.opacity = math.max(0,v.opacity+v.vo*d)
		if v.opacity == 0 or (b and v.vy > 0 and v.y > ground[row]+50) then
			v:free()
		elseif v.vz or v.vo == -0.25 then
			if v.vo == -0.125 then
				v.vx = v.vx/d2 + dt
				v.vy = v.vy/d2 + dt/4
				v.vz = v.vz+dt
			else
				v.vy = v.vy + gravity*d/2
			end
			v.x = v.x + v.vx*d
			v.y = v.y + v.vy*d
			if v.vo ~= -0.25 then
				v.z_rotation = {v.z_rotation[1]+v.vz*d,0,0}
			else
				v.scale = {v.scale[1]*s,v.scale[2]*s}
			end
		elseif v.vx then
			v.scale = {v.scale[1]*s,v.scale[2]*s}
		else
			v.y = v.y + v.vy*d
			v.t = v.t + d
			v.scale = {v.scale[1]+d/800,1.5-(2*v.t/800-1)^2}
		end
	end
end

return function(bank,block,splash)
	if block then
		if block.level ~= group.level then return end
		px, py = block.x + block.w/2, block.y + block.h/2
		for i=1,rand(5,8) do
			s = Image{src = chunks[rand(4)], opacity = 255, x = px+nrand(50),
					  y = py+(levels.this.bank > 0 and nrand(30)-30 or nrand(50)),
					  scale = {rand(2)*2-3,rand(2)*2-3}, z_rotation = {rand(4)*90,0,0}}
			s.anchor_point = {s.w/2,s.h/2}
			s.vx, s.vy, s.vz, s.vo = (s.x-px)/160, (s.y-py)/160-0.25, nrand(0.5), -0.2
			group:add(s)
		end
		group:lower(penguin)
	elseif splash then
		px, py = penguin.x + penguin.w/2, penguin.y + penguin.h/2
		s = Image{src = "splash-3", x = px, y = ground[row]+110,
				  anchor_point = {64,120}, scale = {0.5,0.2}, opacity = 255}
		s.vy, s.vo, s.t = bank and 0 or 0.02, -0.32, 0
		group:add(s)
		group:lower(penguin)
	else
		px, py = penguin.x + penguin.w/2, penguin.y + penguin.h/2
		if not splash and (not bank or bank > 5) then
			group:raise(penguin)
			s = Image{src = "explode-128", x = px, y = py - (bank and 20 or 0),
				opacity = 255, anchor_point = {64,64}, scale = {1,1}}
			s.vx, s.vy, s.vo = 0, (bank and -0.06 or 0), -0.32
			group:add(s)
		else
			group:lower(penguin)
		end
	end
	
	if bank and bank > 5 then
		py = py - 30
	end
	
	if not block then
		for i=1,(bank or rand(15,20)) do
			s = splash and splashes[rand(2)] or snow[rand(#snow-(bank and 1 or 0))]
			s = Image{src = s, x = px, y = py, opacity = 127 + rand(128), z_rotation = {rand(360),0,0}}
			s.vx = nrand(0.25)
			if splash then
				s.anchor_point = {s.w/2, s.h/2}
				s.vo = -0.25
				s.vy = nrand(0.15) - (bank and 0.05 or 0) - 0.25 - 4*(0.25-math.abs(s.vx))^2
				d = nrand(0.2)+0.7
			else
				s.anchor_point = {s.w*(0.5+nrand(0.7)), s.h*(0.5+nrand(0.7))}
				s.vz, s.vo = 0.1, -0.125
				s.vy = nrand(0.25) - (bank and 0.15 or 0)
				d = nrand(0.2)+0.9
			end
			s.scale = {d,d}
			group:add(s)
		end
	end
	
	anim:rewind()
	anim:start()
end