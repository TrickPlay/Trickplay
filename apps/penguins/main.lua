--[[

Penguin Zip-Zip


tell pablo about segfault
--]]

orient = dofile('orient/orient.lua')()

--screen.perspective = {1,1,0.1,100}

sin = math.sin
cos = math.cos
asin = math.asin
atan = math.atan
atan2 = math.atan2
pi = math.pi
max = math.max
min = math.min
sqrt = math.sqrt
log10 = math.log10 or function(n) return math.log(n,10) end
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

dofile("assets.lua")
audio	= dofile("audio.lua")
levels  = dofile("levels.lua")
levels.this:load()
snow    = dofile("snow.lua")
penguin = dofile("penguin.lua")
overlay	= dofile("overlay.lua")
snow(levels.this.snow)
dofile("effects.lua")

collectgarbage("collect")
