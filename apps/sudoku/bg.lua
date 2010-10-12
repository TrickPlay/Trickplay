--Config
local refresh = Timer{interval=100}
local base_rect = Rectangle{color="FFFFFF",w=100,h=100,opacity=0}
local num_rects = 50

local cloud = Image{src="assets/cloud9.jpg"}
red_bg  = {40, 10, 10}
blue_bg = {10, 40, 45}
bg = Rectangle{color = {red_bg[1],red_bg[2],red_bg[3]}, w=screen.w,h=screen.h,opacity=220}

--red 40 10 10 
screen:add(cloud,bg,base_rect)


local da_clonesss = {}
function setup_bg()
	for i = 1, num_rects do
		local sc = math.random(70,100)/100
		da_clonesss[i] = Clone
		{
			source=base_rect,
			opacity = 10,
			x = math.random(-50,screen.w/4)*4,
			y = math.random(-50,screen.h/4)*4,
			scale = {sc,sc},
			anchor_point = 
			{
				base_rect.w/2,
				base_rect.h/2
			}
		}
		da_clonesss[i].z_rotation = {math.random(0,359),0,0}
		screen:add(da_clonesss[i])
	end
end

function refresh:on_timer()
	for i = 1, num_rects do
		da_clonesss[i].x = da_clonesss[i].x + 1
		da_clonesss[i].y = da_clonesss[i].y + 1
		da_clonesss[i].z_rotation = {(da_clonesss[i].z_rotation[1]+1)%360,0,0}
		if da_clonesss[i].x > (screen.w+100) then
print("x", da_clonesss[i].x)
			da_clonesss[i].x = -100
		end
		if da_clonesss[i].y > (screen.h+100) then
print("y", da_clonesss[i].y)
			da_clonesss[i].y = -100
		end

	end
end

setup_bg()
refresh:start()
