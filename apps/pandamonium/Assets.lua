local assets = {
	--Panda Components
    torso      = Image { src = "assets/panda/body.png"      },
    r_leg      = Image { src = "assets/panda/leg-right.png" },
    l_leg      = Image { src = "assets/panda/leg-left.png"  },
    r_arm      = Image { src = "assets/panda/arm-right.png" },
    l_arm      = Image { src = "assets/panda/arm-left.png"  },
    head       = Image { src = "assets/panda/head.png"      },
	--Menu Components
	title      = Image { src = "assets/pandamonium.png" },
	back       = Image { src = "assets/back.png" },
	quit       = Image { src = "assets/quit.png" },
	start      = Image { src = "assets/start.png" },
	play_again = Image { src = "assets/play-again.png" },
	arrow      = Image { src = "assets/menu-arrow.png" },
	--Level Components
	branches = {
		Image { src = "assets/branches-1.png" },
		Image { src = "assets/branches-2.png" },
		Image { src = "assets/branches-3.png" },
	},
	ground     = Image { src = "assets/ground.png" },
	coin_front = Image { src = "assets/coin-1.png" },
	coin_back  = Image { src = "assets/coin-3.png" },
	coin_side  = Image { src = "assets/coin-2.png" },
	firework   = Image { src = "assets/firework.png" },
	firecracker   = Image { src = "assets/firecracker.png" },
	envelope = {
		Image { src = "assets/envelope.png" },
		Image { src = "assets/envelope-2.png" },
	},
	--effects
	smoke = {
		Image { src = "assets/smoke1.png" },
		Image { src = "assets/smoke2.png" },
		Image { src = "assets/smoke3.png" },
	},
	spark = {
		Image { src = "assets/spark1.png" },
		Image { src = "assets/spark2.png" },
		Image { src = "assets/spark3.png" },
	},
	sparkle = {
		Image { src = "assets/sparkle1.png" },
		Image { src = "assets/sparkle2.png" },
		Image { src = "assets/sparkle3.png" },
		Image { src = "assets/sparkle4.png" },
	},
	--HUD Components
	coin_symbol = Image{ src = "assets/score/coin-symbol.png" },
	num = {
		Image{ src = "assets/score/score-1.png"},
		Image{ src = "assets/score/score-2.png"},
		Image{ src = "assets/score/score-3.png"},
		Image{ src = "assets/score/score-4.png"},
		Image{ src = "assets/score/score-5.png"},
		Image{ src = "assets/score/score-6.png"},
		Image{ src = "assets/score/score-7.png"},
		Image{ src = "assets/score/score-8.png"},
		Image{ src = "assets/score/score-9.png"},
		Image{ src = "assets/score/score-0.png"},
	}
}

local bg = Image{ src = "assets/background.jpg", tile={true,true} }

bg.y = -bg.h
bg.w = screen_w
bg.h = screen_h + bg.h
layers.bg:add(bg)

--All images should be only declared here
Image = nil


for _,v in pairs(assets) do
	if type(v) == "table" then
		for _,v in pairs(v) do
			layers.clone_srcs:add(v)
		end
	else
		layers.clone_srcs:add(v)
	end
end

layers.clone_srcs:hide()




return assets, bg