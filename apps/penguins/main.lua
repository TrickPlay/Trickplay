--[[
wed 7th
	weather vane
	moving block levels
	
mon 12th
	moving block levels
	ice water
	submersion
	refactor

tues 13th
	refactor
	moving bridge levels
	monster/darkness?
	
wed 14th
	monster/darkness levels
	audio
	
mon 19th
	audio
	
tues Dec 20th
	audio
	
	refactor
	
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

dofile("assets.lua")
audio	= dofile("audio.lua")
levels  = dofile("levels.lua")
levels.this:load()
snow    = dofile("snow.lua") -- refactor
penguin = dofile("penguin.lua")
overlay	= dofile("overlay.lua")
snow(levels.this.snow,levels.this.bank)
dofile("effects.lua")

collectgarbage("collect")