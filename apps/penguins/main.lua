--[[
tues
	polish boost anim
	
wed
	2-3 blue fish levels
	internal release?
	
level notes
	12a and 16a and might be too difficult

	
breakable blocks
armor
gravity fish
darkness
polar bear
eskimo
monster


submersion of
	ball
	ice blocks
	seal
	penguin
splashing


need
	audio
	better ice water
	splash pieces
	armor pieces
	ice pieces
	switches
	"upside down" fish
	darkness
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
snow(levels.this.snow,levels.this.bank)
explode = dofile("explode.lua")

collectgarbage("collect")