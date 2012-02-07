local a
local t = {opacity = 0, size = {960+256,540+256}, tile = {true,true}, scale = {2,2}}
t.src = "assets/snow-far.png"
local layers = {_Image(t)}
t.src = "assets/snow-mid.png"
layers[2] = _Image(t)
t.src = "assets/snow-close.png"
layers[3] = _Image(t)
snowgroup = Layer{name = "snow"}
snowgroup:add(layers[1],layers[2],layers[3])

snowbank = Layer{y = -1300, name = "snowbank"}
snowbank:add(Sprite{src = "snow-bank.png", position = {233,455}},
			 Sprite{src = "snow-bank.png", position = {1940,455+640}, scale = {-1.15,1}})
			 
evFrame[snowgroup] = function(self,d,ms)
	t = ms/2000%1
	for i=1,3 do
		a = -512 * (1-t*i%1)
		layers[i].x, layers[i].y = a, a
	end
end

screen:add(snowbank,snowgroup)
snowbank.clone = _Clone{source = snowbank, name = "snowclone"}

local f = function(t)
	a = {}
	for j=1,3 do
		a[j] = {layers[j],"opacity",t[j+1]*255}
	end
	return {source = "*", target = t[1], keys = a}
end

anim = AnimationState{transitions = {f{0,0,0,0},f{1,1,0,0},f{2,1,1,0},f{3,1,1,1}}}

return function(wind)
	anim.state = wind
	snowbank:raise(overlay)
	snowgroup:raise(overlay)
	audio.loop("wind-" .. (wind == 3 and '2' or '1'),(wind == 3 and 4500 or 2000))
end