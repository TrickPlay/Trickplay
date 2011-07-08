local assets = {
	--Panda
    torso = Image { src = "assets/panda/body.png"      },
    r_leg = Image { src = "assets/panda/leg-right.png" },
    l_leg = Image { src = "assets/panda/leg-left.png"  },
    r_arm = Image { src = "assets/panda/arm-right.png" },
    l_arm = Image { src = "assets/panda/arm-left.png"  },
    head  = Image { src = "assets/panda/head.png"      },
	--Level Components
	branches = {
		Image { src = "assets/branches-1.png" },
		Image { src = "assets/branches-2.png" },
		Image { src = "assets/branches-3.png" },
	},
	
}

local bg = Image{ src = "assets/background.jpg", tile={true,true} }

bg.y = -bg.h
bg.w = screen_w
bg.h = screen_h + bg.h
screen:add(bg)

local clone_srcs = Group{}

for _,v in pairs(assets) do
	if type(v) == "table" then
		for _,v in pairs(v) do
			clone_srcs:add(v)
		end
	else
		clone_srcs:add(v)
	end
end

screen:add(clone_srcs)
clone_srcs:hide()

return assets, bg