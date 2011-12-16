--[[
wed
	armor levels
	internal release
	weather vane
	moving block levels
	darkness
	
level notes
	12a and 16a and might be too difficult

refactor animation, gravity fall systems?
reduce particle animation
submersion of ball
darkness
monster?

need
	audio
	better ice water
	switches
	darkness
]]

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

dofile("cloner.lua")
levels  = dofile("levels.lua")
levels.this:load()
snow    = dofile("snow.lua")
penguin = dofile("penguin.lua")
overlay	= dofile("overlay.lua")
snow(levels.this.snow,levels.this.bank)
explode = dofile("explode.lua")

collectgarbage("collect")