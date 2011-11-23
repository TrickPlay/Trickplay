--[[

seal w/ ball
try to ease up collisions
consider unlinking penguin speed from timeline
breakable blocks
faster fish
heavy armor
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


audio


Need:
	audio
	better ice water
	breakable block
	"faster" fish
	armor
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
dofile("overlay.lua")

collectgarbage("collect")