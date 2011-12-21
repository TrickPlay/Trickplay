--[[

Penguin Zip-Zip

--]]

sin = math.sin
cos = math.cos
asin = math.asin
atan2 = math.atan2
pi = math.pi
max = math.max
min = math.min
sqrt = math.sqrt
log10 = math.log10
floor = math.floor

math.randomseed(os.time())
rand = math.random
function nrand(n)
    return (2*rand()-1)*n
end
function drand(n)
    return (rand()+rand()-1)*n
end

gravity = 0.002
ground = {440,1080}
row = 1
usebg = true

step = {}
local d, tms = 0, 0
local anim = Timeline{duration = 9001, loop = true,
	on_new_frame = function(self,ms,t)
		d = self.delta
		tms = tms+d
		for k,v in pairs(step) do
			v(d,tms)
		end
	end}
anim:start()

dofile("assets.lua")
audio	= dofile("audio.lua")
levels  = dofile("levels.lua")
levels.this:load()
snow    = dofile("snow.lua")
penguin = dofile("penguin.lua")
overlay	= dofile("overlay.lua")
snow(levels.this.snow,levels.this.bank)
dofile("effects.lua")

collectgarbage("collect")