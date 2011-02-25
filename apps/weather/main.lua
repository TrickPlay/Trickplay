
screen_w = screen.w
screen_h = screen.h
screen:show()

dofile("App_Loop.lua")
dofile("Utils.lua")

imgs = {
	rain_clouds = {
		Image{src="assets/clouds/clouds-stormy1.png"},
		Image{src="assets/clouds/clouds-stormy2.png"},
	},
	reg_clouds = {
		Image{src="assets/clouds/clouds-fluffy1.png"},
		Image{src="assets/clouds/clouds-fluffy2.png"},
	},
	moon  = Image{src="assets/night/moon.png"},
	stars = Image{src="assets/night/stars.png"},
	rain  = {
		streak = Image{src="assets/rain/rain-streak.png"},
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
	},
	color_button = {
		green       = Image{src="assets/ui/button-less.png"},
		green_glow  = Image{src="assets/ui/button-less-glow.png"},
		blue        = Image{src="assets/ui/button-5day.png"},
		blue_glow   = Image{src="assets/ui/button-5day-glow.png"},
		yellow      = Image{src="assets/ui/button-options.png"},
		yellow_glow = Image{src="assets/ui/button-options-glow.png"},
	},
	logo      = Image{src="assets/ui/logo.png"},
	lightning = Image{src="assets/lightning-bolt.png"},
}


do
	local clone_source_container = Group{name="Clone Source Container"}
	
	apply_func_to_leaves(imgs,clone_source_container.add,clone_source_container)
	
	screen:add(clone_source_container)
	
	clone_source_container:hide()
end

dofile("Internet.lua")
local zip = 94306

lookup(zip)