dofile("backimage.lua")
dofile("timer.lua")

math.randomseed(os.time())

SCALE_RANDOM = {	[1] = 25,
					[2] = 50,
					[3] = 75,
					[4] = 30,
					[5] = 80,
					[6] = 100,
					}
					

random_scale = SCALE_RANDOM[math.random(1,6)]


local function make_circle()
dofile("circle.lua")



screen:add(circle)
circle.opacity = 0
end


local function make_circle_clones()

random_scale = SCALE_RANDOM[math.random(1,6)]

circ = Clone
           {                    
                 source = circle,                 
            }
screen:add(circ)


circ.opacity = math.random(30,40)
circ.position = { math.random(200,1720),  math.random(150, 930) }
circ.scale={.2,.2}
circ.anchor_point={120,120}
circ:animate({ duration = 20000, scale = {random_scale,random_scale}, opacity = 0, mode = "EASE_IN_CIRC"})

end


function random_circles()
		make_circle()
	for i = 1,math.random(2,3) do
		print("Cloning..")
		make_circle_clones()
		print("Cloned!")
	end
end


random_circles()
timer:start()
screen:show()