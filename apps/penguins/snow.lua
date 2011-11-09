local t = {opacity = 0, size = {960+256,540+256}, tile = {true,true}, scale = {2,2}}
t.src = "assets/snow-far.png"
local layers = {Image(t)}
t.src = "assets/snow-mid.png"
layers[2] = Image(t)
t.src = "assets/snow-close.png"
layers[3] = Image(t)
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

return function(wind)
	if wind < 1 then
		anim:stop()
		for i=1,#layers do
			layers[i].opacity = 0
		end
	else
		if not anim.is_playing then
			anim:start()
		end
		for i=1,#layers do
			layers[i]:animate{opacity = i > wind and 0 or 255, duration = 1000}
		end
	end
	
	layers[3]:raise(overlay)
	layers[2]:raise(overlay)
	
	if wind >= 2 then
		layers[1]:lower(overlay)
	else
		layers[1]:raise(overlay)
	end
end