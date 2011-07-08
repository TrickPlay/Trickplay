
screen:show()

screen_w = screen.w
screen_h = screen.h

physics.pixels_per_meter = 200

-- Gravity

physics.gravity = { 0 , 15 }

assets, bg         = dofile("Assets.lua")

panda              = dofile("Panda.lua")

Splash             = dofile("Splash_Menu.lua")

branch_constructor = dofile("Branches.lua")

World              = dofile("GameWorld.lua")

physics.on_step    = dofile("GameLoop.lua")

Splash:fade_in()