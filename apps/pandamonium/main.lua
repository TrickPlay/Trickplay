
screen:show()

screen_w = screen.w
screen_h = screen.h

physics.pixels_per_meter = 200

-- Gravity

physics.gravity = { 0 , 15 }



assets, bg         = dofile("Assets.lua")
panda              = dofile("Panda.lua")
branch_constructor = dofile("Branches.lua")
make_wall          = dofile("GameWorld.lua")
physics.on_step    = dofile("GameLoop.lua")

--make sure that the keys don't go nil 
assert(type(panda.on_key_down) == "function")

function screen:on_key_down()
    physics:start()
    screen.on_key_down = panda.on_key_down
end
