local i, d, t1, s, m2, mz1
local scale1 = {1,1}
local puff = Image{src = "assets/images/explode-128.png"}
local snow = {Image{src = "assets/images/explode-16.png"},
			  Image{src = "assets/images/explode-24.png"},
			  Image{src = "assets/images/explode-32.png"}}
				
local pieces = Group{name = "pieces"}
pieces:hide()
pieces:add(puff,snow[1],snow[2],snow[3])

local clones = {index = 1}
clones.new = function(num)
	local ret = {}
    local i = 0
	
    while #ret < num and i < #clones do
        i = i + 1
		if not clones[i].parent then
			ret[#ret+1] = clones[i]
		end
	end
    
	while #ret < num do
		clones[#clones+1] = Clone{source = snow[1 + #clones%#snow]}
        clones[#clones].vo = -255/2000
		ret[#ret+1] = clones[#clones]
	end
    
	return ret
end

local puffs = {}
puffs.new = function()
    local p
	for i=1,#puffs do
		if not puffs[i].parent then
			return puffs[i]
		end
	end
	if not p then
        p = Clone{source = puff}
        puffs[#puffs+1] = p
        p.anchor_point = {64,64}
        p.vo = -255/800
    end
    
    p.scale = scale1
	p.vx, p.vy = 0, 0
	return p
end

local show = Group{name = "show"}

local group = Group{name = "explosion"}
group:add(pieces,show)
overlay:add(group)

local anim = Timeline{duration = 2300}

function anim:on_new_frame(ms,t)
    t1 = t*t*100
    s = 1+t*3
    m2 = ms/2^(ms/1000)
    mz1 = ms*ms/8000
	for k,v in ipairs(show.children) do
        v.opacity = math.max(0,v.oo+v.vo*ms)
        if v.opacity == 0 then
            show:remove(v)
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
        m2 = ms/2^(ms/1000)
        
        for k,v in ipairs(show.children) do
            v.ox, v.oy = v.x, v.y
            v.vx, v.vy = v.vx*m2 + t*1200, v.vy*m2 + t*200
            if v.z1 then
                v.z1 = v.z_rotation[1]
            end
            v.os = v.scale[1]
            v.oo = v.opacity
        end
    end
    
    i = penguin.img
    local px, py = i.x + i.w/2, i.y + i.h/2
    
	local puff = puffs.new()
	show:add(puff)
    puff.x, puff.y, puff.ox, puff.oy = px, py, px, py
    puff.opacity, puff.oo = 255, 255
    puff.os = 1
	
	local snow = clones.new(rand(15,25))
	for k,v in ipairs(snow) do
		show:add(v)
		v.x, v.y, v.ox, v.oy = px, py, px, py
		v.vx, v.vy = nrand(0.25), nrand(0.25)
        v.z1, v.z2, v.z3 = rand(360), v.w*nrand(0.7), v.h*nrand(0.7)
        v.z_rotation = {v.z1,v.z2,v.z3}
        v.oo = 127 + rand(128)
        v.opacity = v.oo
	end
	
    if anim.is_playing then
        anim:rewind()
    else
        anim:start()
    end
end