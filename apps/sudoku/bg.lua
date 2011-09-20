--Config
local refresh = Timer{interval=100}
local r_sz = 100
local base_rect = Rectangle{color="FFFFFF",w=r_sz,h=r_sz,opacity=0}
local num_rects = 50

local cloud = Image{src="assets/cloud9.jpg",scale = {4,4}}
red_bg  = {40, 10, 10}
blue_bg = {10, 40, 45}
bg = Rectangle{color = {red_bg[1],red_bg[2],red_bg[3]}, w=screen.w,h=screen.h,opacity=220}

--red 40 10 10 
screen:add(cloud,bg,base_rect)


local da_clonesss = {}
local lookup_table = {}
function setup_bg()
	for i = 1, num_rects do
		local sc = math.random(70,100)/100
		lookup_table[i] = {
		              x = math.random(-50,screen_w/4)*4,
		              y = math.random(-50,screen_h/4)*4,
		              z = math.random(0,359)
		}

		da_clonesss[i] = Clone
		{
			source       = base_rect,
			opacity      = 10,
			x            = lookup_table[i].x,
			y            = lookup_table[i].y,
			scale        = { sc, sc },
			anchor_point = { r_sz/2, r_sz/2 },
			z_rotation   = { lookup_table[i].z, 0, 0 } 
		}
		screen:add(da_clonesss[i])
	end
end

function refresh:on_timer()
	for i = 1, num_rects do
		lookup_table[i].x = 	lookup_table[i].x + 1	
		lookup_table[i].y =     lookup_table[i].y + 1 
		lookup_table[i].z =   ( lookup_table[i].z + 1 ) % 360

		da_clonesss[i].x          =  lookup_table[i].x
		da_clonesss[i].y          =  lookup_table[i].y
		da_clonesss[i].z_rotation = {lookup_table[i].z,0,0}

		if lookup_table[i].x > (screen_w+100) then
			lookup_table[i].x = -100
			da_clonesss[i].x  = -100
		end
		if lookup_table[i].y > (screen_h+100) then
			lookup_table[i].y = -100
			da_clonesss[i].y  = -100
		end
	end
end

--setup_bg()
--refresh:start()
