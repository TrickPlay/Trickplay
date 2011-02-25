
screen_w = screen.w
screen_h = screen.h
screen:show()

dofile("App_Loop.lua")
dofile("Utils.lua")

imgs = {
	rain_clouds = {
		lg = {
			Image{src="assets/clouds/clouds-stormy1.png"},
			Image{src="assets/clouds/clouds-stormy2.png"},
		},
		sm = {
			Image{src="assets/clouds/clouds-stormy-small1.png"},
			Image{src="assets/clouds/clouds-stormy-small2.png"},
		}
	},
	reg_clouds = {
		lg = {
			Image{src="assets/clouds/clouds-fluffy1.png"},
			Image{src="assets/clouds/clouds-fluffy2.png"},
		},
		sm = {
			Image{src="assets/clouds/clouds-fluffy-small1.png"},
			Image{src="assets/clouds/clouds-fluffy-small2.png"},
		},
	},
	moon  = Image{src="assets/night/moon.png"},
	stars = Image{src="assets/night/stars.png"},
	rain  = {
		streak = {
			Image{src="assets/rain/rain-streak.png"},
			Image{src="assets/rain/rain-streak2.png"},
		},
		clump  = Image{src="assets/rain/rain-clump.png"},
		drops  = {
			Image{src="assets/rain/raindrop1.png"},
			Image{src="assets/rain/raindrop2.png"},
			Image{src="assets/rain/raindrop3.png"},
			Image{src="assets/rain/raindrop4.png"},
			Image{src="assets/rain/raindrop5.png"},
		},
	},
	frost_corner = Image{src="assets/snow/frost.png"},
	snow_corner  = Image{src="assets/snow/snow.png"},
	snow_flake = {
		lg = {
			Image{src="assets/snow/snowflake-lg1.png"},
			Image{src="assets/snow/snowflake-lg2.png"},
			Image{src="assets/snow/snowflake-lg3.png"},
			Image{src="assets/snow/snowflake-lg4.png"},
			Image{src="assets/snow/snowflake-lg5.png"},
		},
		lg_blur = {
			Image{src="assets/snow/snowflake-lg-blur1.png"},
			Image{src="assets/snow/snowflake-lg-blur2.png"},
			Image{src="assets/snow/snowflake-lg-blur3.png"},
			Image{src="assets/snow/snowflake-lg-blur4.png"},
			Image{src="assets/snow/snowflake-lg-blur5.png"},
		},
		sm = {
			Image{src="assets/snow/snowflake-small1.png"},
			Image{src="assets/snow/snowflake-small2.png"},
			Image{src="assets/snow/snowflake-small3.png"},
		}
	},
	sun = {
		base  = Image{src="assets/sun/sun_base.png"},
		flare = {
			Image{src="assets/sun/sun_flare1.png"},
			Image{src="assets/sun/sun_flare2.png"},
			Image{src="assets/sun/sun_flare3.png"},
		}
	},
	arrows = {
		left  = Image{src="assets/ui/arrow_left.png"},
		right = Image{src="assets/ui/arrow_right.png"},
	},
	bar = {
		full = Image{src="assets/ui/bar-full.png"},
		mini = Image{src="assets/ui/bar-mini.png"},
	},
	gradient = {
		full = Image{src="assets/ui/gradient-full.png"},
		mini = Image{src="assets/ui/gradient-mini.png"}
	},
	color_button = {
		green_less  = Image{src="assets/ui/button-less.png"},
		green_more  = Image{src="assets/ui/button-more.png"},
		green_glow  = Image{src="assets/ui/button-less-glow.png"},
		blue        = Image{src="assets/ui/button-5day.png"},
		blue_glow   = Image{src="assets/ui/button-5day-glow.png"},
		yellow      = Image{src="assets/ui/button-options.png"},
		yellow_glow = Image{src="assets/ui/button-options-glow.png"},
	},
	logo      = Image{src="assets/ui/logo.png"},
	lightning = Image{src="assets/lightning-bolt.png"},
	bg        = Image{src="assets/bg.jpg"}
}


do
	local clone_source_container = Group{name="Clone Source Container"}
	
	apply_func_to_leaves(imgs,clone_source_container.add,clone_source_container)
	
	screen:add(clone_source_container)
	
	clone_source_container:hide()
end

dofile("Internet.lua")
dofile("Weather_Bar.lua")
local zip = 94306
screen:add(Clone{source=imgs.bg})
screen:add(Make_Mini_Bar())
--lookup(zip)