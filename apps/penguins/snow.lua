local wind = 0
local layers = {Image{name = "snow-far", src = "/assets/images/snow-far.png", opacity = 0,   size = {1920+512,1080+512}},--, tile = {true,true}},
				Image{name = "snow-mid", src = "/assets/images/snow-mid.png", opacity = 0,   size = {1920+512,1080+512}},--, tile = {true,true}},
				Image{name = "snow-close", src = "/assets/images/snow-close.png", opacity = 0, size = {1920+512,1080+512}}}--, tile = {true,true}}}
screen:add(layers[1],layers[2],layers[3])

local anim = Timeline{ duration = 2000, loop = true,
	on_new_frame = function(self,ms,t)
		for i=1,wind do
			layers[i].position = {-512*(1-(t*i)%1),-512*(1-(t*i)%1)}
		end
	end
}
	
local set = function(w)
	wind = w
	if wind == 0 then
		anim:stop()
	elseif wind > 0 then
		if not anim.is_playing then
			anim:start()
		end
		for i=1,wind do
			layers[i].opacity = i <= wind and 255 or 0
		end
	end
	--[[
	for k,v in ipairs(layers) do
		if k <= force and not v.is_animating then
			v.opacity = 255
			v.position = {-512,-512}
			v:animate{position = {0,0}, loop = true, duration = 3000/(force+k)}
		elseif k > force and v.is_animating then
			v.opacity = 0
			v:complete_animation()
		end
	end]]
end

local raise = function()
	layers[3]:raise(overlay)
	layers[2]:raise(overlay)
	
	if wind >= 2 then
		layers[1]:lower(overlay)
	else
		layers[1]:raise(overlay)
	end
end

return {set = set, raise = raise}