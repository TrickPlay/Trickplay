local i, j, d, dt, d2, s, px, py, b, c
local snow		= {"explode-16.png","explode-24.png","explode-32.png"}
local chunks	= {"icechunk-1.png","icechunk-2.png","icechunk-3.png","icechunk-4.png"}
local splashes	= {"splash-1.png","splash-2.png"}
local isbank	= 0

local group = overlay.effects
group:raise(penguin)
group.level = levels.this.id
fx = {}

evFrame[fx] = function(self,d,ms)
--[[
	dt = d/2300/2
	s = 1+dt*6
	d2 = 4^(d/1000)
	b = levels.this.bank > 0
	for k,v in ipairs(group.children) do
        if(#(v.extra) == 0) then
            v:free()
        else
    		v.opacity = math.max(0,v.opacity+v.vo*d)
    		if v.opacity == 0 or ((b and v.vy > 0 or v.vo == 0) and v.y > ground[row]+50) then
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
]]--
end

local init = function(obj)
--[[
	obj = obj or penguin
	isbank = levels.this.bank > 0 and 1 or 0
	px, py = obj.x + obj.w/2, obj.y + obj.h/2
	group:lower(penguin)
	c = floor(group.count/4)
]]--
end

fx.splash = function()
--[[
	init()
	j = Sprite{src = "splash-3.png", x = px, y = ground[row]+120,
			  anchor_point = {64,120}, scale = {0.5,0.2}, opacity = 255}
	j.vy, j.vo, j.t = 0.02*(1-isbank), -0.32, 0
	group:add(j)
	for i=1+c,rand(12,15) do
		j = Sprite{src = splashes[rand(2)], x = px, y = py-30*isbank, opacity = rand(160,255),
				  anchor_point = {32,32}, z_rotation = {rand(360),0,0}}
		j.vx, j.vo = nrand(0.25), -0.25
		j.vy = nrand(0.15) - 0.05*isbank - 0.25 - 4*(0.25-math.abs(j.vx))^2
		d = nrand(0.2)+0.7
		j.scale = {d,d}
		group:add(j)
	end
]]--
end

fx.smash = function(block)
--[[	if block.level ~= group.level then return end
	init(block)
	for i=1+floor(c/3),rand(5,8) do
		j = Sprite{src = chunks[rand(4)], opacity = 255, x = px+nrand(50),
				  y = py+(isbank == 1 and nrand(30)-30 or nrand(50)),
				  scale = {rand(2)*2-3,rand(2)*2-3}, z_rotation = {rand(4)*90,0,0}}
		j.anchor_point = {j.w/2,j.h/2}
		j.vx, j.vy, j.vz, j.vo = (j.x-px)/160, (j.y-py)/160-0.25, nrand(0.5), -0.2
		group:add(j)
	end
]]
end

fx.flakes = function(num)
--[[
	init()
	num = num and num-c or 1
	if num == 1 and rand(6) < c then return end
	for i=1,num do
		j = Sprite{src = snow[rand(#snow-isbank)], x = px, y = py,
			z_rotation = {rand(360),0,0}, opacity = rand(128,255)}
		j.anchor_point = {j.w*(0.5+nrand(0.7)), j.h*(0.5+nrand(0.7))}
		j.vx, j.vy, j.vz, j.vo = nrand(0.25), nrand(0.25) - 0.15*isbank, 0.1, -0.125
		d = nrand(0.2)+0.9
		j.scale = {d,d}
		--Class:dump(j)
		group:add(j)
	end
]]--
end

fx.explode = function(num)
--[[
	fx.flakes(num or rand(12,15))
	group:raise(penguin)
	j = Sprite{src = "explode-128.png", x = px, y = py-20*isbank,
		opacity = 255, anchor_point = {64,64}, scale = {1,1}}
	j.vx, j.vy, j.vo = 0, -0.06*isbank, -0.32
	--Class:dump(j)
	group:add(j)
]]--
end
