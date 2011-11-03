math.randomseed(os.time())
rand = math.random
function nrand(n)
    return (2*rand()-1)*n
end

gravity = 0.13
ground = {440,1080}
row = 1

dofile("cloner.lua")

snow    = dofile("snow.lua")
penguin = dofile("penguin.lua")
levels  = dofile("levels.lua")
overlay = dofile("overlay.lua")
explode = dofile("explode.lua")

collectgarbage("collect")