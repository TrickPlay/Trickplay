local a
local t = {opacity = 0, size = {960+256,540+256}, tile = {true,true}, scale = {2,2}}
t.src = "assets/snow-far.png"
local layers = {Image(t)}
t.src = "assets/snow-mid.png"
layers[2] = Image(t)
t.src = "assets/snow-close.png"
layers[3] = Image(t)
snowbank = Group{y = -1300}
snowbank:add(Image{src = "snow-bank", position = {233,455}},
			 Image{src = "snow-bank", position = {1940,455+640}, scale = {-1.15,1}})
screen:add(layers[1],layers[2],layers[3],snowbank)
snowbank.clone = _Clone{source = snowbank}

local f = function(t)
	a = {}
	for j=1,3 do
		a[j] = {layers[j],"opacity",t[j+1]*255}
	end
	return {source = "*", target = t[1], keys = a}
end

anim = AnimationState{transitions = {f{0,0,0,0},f{1,1,0,0},f{2,1,1,0},f{3,1,1,1}}}

step[snowbank] = function(d,ms)
	t = ms/2000%1
	for i=1,3 do
		a = -512 * (1-t*i%1)
		layers[i].x, layers[i].y = a, a
	end
end

return function(wind)
	anim.state = wind
	snowbank:raise(overlay)
	layers[3]:raise(overlay)
	layers[2]:raise(overlay)
	layers[1][wind >= 2 and "lower" or "raise"](layers[1],overlay)
	audio.loop("wind-" .. (wind == 3 and '2' or '1'),(wind == 3 and 4500 or 2000))
end