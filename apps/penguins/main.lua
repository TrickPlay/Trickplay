--[[
wed
	level 'suck it up and squeeze through'? (after level 3 maybe)
	inter-level platforms
	snow ramp thing
	finish level 20, make 21 ('blue fish ice bridge')
	insert rolling/bouncing blocks? (3-5 levels)
	
mon-wed
	blue fish adjustments, preferrably w/ burst anim
	2-3 blue fish levels
	snow banks (need assets)
	5-8 snow bank levels
	

Mon
refine collisions
breakable blocks
faster fish adjustments
armor
gravity fish
darkness
snow tunnel
polar bear
eskimo
monster


submersion of
	ball
	ice blocks
	seal
	penguin
splashing
double jump cues?


Need
	audio
	better ice water
	better seal
	breakable block
	"faster" fish
	armor pieces
	"upside down" fish
	darkness
	snow tunnel
]]

math.randomseed(os.time())
rand = math.random
function nrand(n)
    return (2*rand()-1)*n
end

gravity = 0.002
ground = {440,1080}
row = 1

dofile("cloner.lua")
snow    = dofile("snow.lua")
penguin = dofile("penguin.lua")
levels  = dofile("levels.lua")
overlay	= dofile("overlay.lua")
snow(levels.this.snow)
explode = dofile("explode.lua")

collectgarbage("collect")