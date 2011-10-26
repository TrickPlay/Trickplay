local wind = 0
local layers = {Image{name = "snow-far", src = "/assets/images/snow-far.png",	  opacity = 0, size = {960+256,540+256}, tile = {true,true}, scale = {2,2}},
				Image{name = "snow-mid", src = "/assets/images/snow-mid.png",	  opacity = 0, size = {960+256,540+256}, tile = {true,true}, scale = {2,2}},
				Image{name = "snow-close", src = "/assets/images/snow-close.png", opacity = 0, size = {960+256,540+256}, tile = {true,true}, scale = {2,2}}}
screen:add(layers[1],layers[2],layers[3])

local anim = Timeline{ duration = 2000, loop = true,
	on_new_frame = function(self,ms,t)
		for i=1,#layers do
			if layers[i].opacity > 0 then
				layers[i].position = {-512*(1-t*i%1),-512*(1-t*i%1)}
			end
		end
	end
}
	
local set = function(w)
	wind = w
	if wind < 1 then
		anim:stop()
	else
		if not anim.is_playing then
			anim:start()
		end
		for i=1,#layers do
			layers[i]:animate{opacity = i > wind and 0 or 255, duration = 1000}
		end
	end
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