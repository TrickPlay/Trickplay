
screen_w = screen.w
screen_h = screen.h
screen:show()

dofile("App_Loop.lua")
dofile("Utils.lua")

imgs = {
	rain_clouds = {
		lg = {
			--Image{src="assets/clouds/clouds-stormy1.png"},
			Image{src="assets/clouds/clouds-stormy2.png"},
		},--[[
		sm = {
			Image{src="assets/clouds/clouds-stormy-small1.png"},
			Image{src="assets/clouds/clouds-stormy-small2.png"},
		}--]]
	},
	reg_clouds = {
		lg = {
			Image{src="assets/clouds/clouds-fluffy1.png"},
			Image{src="assets/clouds/clouds-fluffy2.png"},
			Image{src="assets/clouds/clouds-fluffy4.png"},
			Image{src="assets/clouds/clouds-fluffy6.png"},
			Image{src="assets/clouds/clouds-fluffy7.png"},
			Image{src="assets/clouds/clouds-fluffy8.png"},
			Image{src="assets/clouds/clouds-fluffy9.png"},
		},
		sm = {
			Image{src="assets/clouds/clouds-fluffy-small1.png"},
			Image{src="assets/clouds/clouds-fluffy-small2.png"},
			Image{src="assets/clouds/clouds-fluffy-small3.png"},
			Image{src="assets/clouds/clouds-fluffy-small4.png"},
			Image{src="assets/clouds/clouds-fluffy-small5.png"},
		},
	},
	fog = Image{src="assets/clouds/fog.png"},
	glow_cloud = Image{src="assets/clouds/clouds-stormy-glow.png"},
	moon  = Image{src="assets/night/moon.png"},
	star  = Image{src="assets/night/star.png"},
	stars = Image{src="assets/night/stars.png"},
	rain  = {
		falling = Image{src="assets/rain/falling.png"},
		--[[
		streak = {
			Image{src="assets/rain/rain-streak.png"},
			Image{src="assets/rain/rain-streak2.png"},
		},--]]
		light  = Image{src="assets/rain/rain-light.png"},
		--[[
		clump  = Image{src="assets/rain/rain-clump.png"},
		drops  = {
			Image{src="assets/rain/raindrop1.png"},
			Image{src="assets/rain/raindrop2.png"},
			Image{src="assets/rain/raindrop3.png"},
			Image{src="assets/rain/raindrop4.png"},
			Image{src="assets/rain/raindrop5.png"},
		},--]]
	},
	--frost_corner = Image{src="assets/snow/frost.png"},
	snow_corner  = Image{src="assets/snow/snow.png"},
	snow_flake = {
		lg = {
			Image{src="assets/snow/snowflake-lg1.png"},
			Image{src="assets/snow/snowflake-lg2.png"},
			Image{src="assets/snow/snowflake-lg3.png"},
			Image{src="assets/snow/snowflake-lg4.png"},
		},--[[
		lg_blur = {
			Image{src="assets/snow/snowflake-lg-blur1.png"},
			Image{src="assets/snow/snowflake-lg-blur2.png"},
			Image{src="assets/snow/snowflake-lg-blur3.png"},
			Image{src="assets/snow/snowflake-lg-blur4.png"},
			Image{src="assets/snow/snowflake-lg-blur5.png"},
		},--]]
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
		side = Image{src="assets/ui/bar/end.png"},
		mid  = Image{src="assets/ui/bar/middle.png"},
		--full = Image{src="assets/ui/bar-full.png"},
		--mini = Image{src="assets/ui/bar-mini.png"},
	},
	gradient = {
		full = Image{src="assets/ui/gradient-full.png"},
		mini = Image{src="assets/ui/gradient-mini.png"}
	},
	color_button = {
		green_less  = Image{src="assets/ui/button-less.png"},
		green_more  = Image{src="assets/ui/button-more.png"},
		blue_5_day  = Image{src="assets/ui/button-5day.png"},
		blue_today  = Image{src="assets/ui/button-today.png"},
		yellow      = Image{src="assets/ui/button-options.png"},
	},
	logo      = Image{src="assets/ui/logo.png"},
	lightning = {
		Image{src="assets/lightning/lightning-bolt.png"},
		Image{src="assets/lightning/lightning-bolt2.png"},
		Image{src="assets/lightning/lightning-bolt3.png"},
	},
	bg ={
		Image{src="assets/bg/bg.png"},
		--[[
		Image{src="assets/bg/bg.jpg"},
		Image{src="assets/bg/1.jpg"},
		Image{src="assets/bg/2.jpg"},
		Image{src="assets/bg/3.jpg"},
		Image{src="assets/bg/4.jpg"},
		Image{src="assets/bg/5.jpg"},
		Image{src="assets/bg/6.jpg"},
		Image{src="assets/bg/7.jpg"},
		Image{src="assets/bg/8.jpg"},
		Image{src="assets/bg/9.jpg"},
		--]]
	},
	wiper     = {
		arm    = Image{src="assets/rain/rain-wiper-arm.png"},
		blade  = Image{src="assets/rain/rain-wiper-blade.png"},
		snow_blade = Image{src="assets/rain/rain-wiper-blade-snow.png"},
		corner = Image{src="assets/rain/rain-corner.png"},
		freezing = Image{src="assets/rain/frost2.png"},
	},
	qmark = Image{src="assets/ui/questionmark.png"},
	load = {
		sun_base    = Image{src="assets/ui/loading/load-sun-center.png"},
		light_flare = Image{src="assets/ui/loading/load-sun-spin.png"},
		dark_flare  = Image{src="assets/ui/loading/load-sun-shadow.png"},
		error       = Image{src="assets/ui/loading/load-error.png"}
	},
	
	icons = {
		chanceflurries = Image{src="assets/icons/icon-chanceflurries.png"},
		chancerain     = Image{src="assets/icons/icon-chancerain.png"},
		chancesleet    = Image{src="assets/icons/icon-chancesleet.png"},
		chancesnow     = Image{src="assets/icons/icon-chancesnow.png"},
		chancetstorms  = Image{src="assets/icons/icon-chancetstorm.png"},
		clear          = nil,
		cloudy         = Image{src="assets/icons/icon-cloudy.png"},
		flurries       = Image{src="assets/icons/icon-flurries.png"},
		fog            = Image{src="assets/icons/icon-fog.png"},
		hazy           = Image{src="assets/icons/icon-hazy.png"},
		mostlycloudy   = Image{src="assets/icons/icon-mostlycloudy.png"},
		mostlysunny    = nil,
		partlycloudy   = Image{src="assets/icons/icon-partlycloudy.png"},
		partlysunny    = nil,
		rain           = Image{src="assets/icons/icon-rain.png"},
		sleet          = Image{src="assets/icons/icon-sleet.png"},
		snow           = Image{src="assets/icons/icon-snow.png"},
		sunny          = Image{src="assets/icons/icon-sunny.png"},
		tstorms        = Image{src="assets/icons/icon-tstorm.png"},
		unknown        = Image{src="assets/icons/icon-unknown.png"},
	}
}


do
	local clone_source_container = Group{name="Clone Source Container"}
	
	apply_func_to_leaves(imgs,clone_source_container.add,clone_source_container)
	
	screen:add(clone_source_container)
	
	clone_source_container:hide()
end

imgs.icons.partlysunny = imgs.icons.mostlycloudy
imgs.icons.mostlysunny = imgs.icons.partlycloudy
imgs.icons.clear       = imgs.icons.sunny

local bg = Group{}
do
	local bgs = {}
	local clone = nil
	local curr_i = math.random(1,#imgs.bg)
	
	for i,pic in ipairs(imgs.bg) do
		clone = Clone{source=pic,opacity=0}
		bgs[i] = clone
		bg:add(clone)
	end
	
	bgs[curr_i].opacity=255
	
	local t = Timer{
		interval=10000,
		on_timer = function()
			bgs[curr_i].opacity=0
			curr_i = curr_i%#bgs+1
			bgs[curr_i].opacity=255
		end,
	}
	t:start{}
end
screen:add(bg)
fade_in_full_gradient = nil
fade_in_mini_gradient = nil

faux_len = 15

left_faux_bar = Group{
	y=873,
	children = {
		Clone{
			source = imgs.bar.mid,
			scale  = {faux_len*2,1},
			x      = -faux_len
		},
		Clone{
			source = imgs.bar.side,
			x      = faux_len
		},
		--[[
		Clone{
			source = imgs.color_button.green_less,
			x      = faux_len-34,
			y      = 33
		},
		Clone{
			source = imgs.color_button.blue_5_day,
			x      = faux_len -34,
			y      = 33+40,
			
		},
		Clone{
			source = imgs.color_button.yellow,
			x      = faux_len-34,
			y      = 33+40*2
		}
		--]]
	}
}
right_faux_bar = Group{
	y=873,
	children = {
		Clone{
			source = imgs.bar.mid,
			scale  = {faux_len*2,1},
			x=screen_w-faux_len,
		},
		Clone{
			source = imgs.bar.side,
			x      = screen_w-faux_len,
			y_rotation = {180,0,0},
		}
	}
}

logo = Clone{source=imgs.logo,x=1670,y=1042}

left_faux_bar.x=-faux_len-imgs.bar.side.w

right_faux_bar.x=faux_len+imgs.bar.side.w



m_grad = Clone{
		name     = "Mini Gradient",
		source   = imgs.gradient.mini,
		y        = screen_h-imgs.gradient.mini.h,
		--opacity  = 0
	}
	f_grad = Clone{
		name     = "Full Gradient",
		source   = imgs.gradient.full,
		y        = screen_h-imgs.gradient.full.h,
		opacity  = 0
	}
	
	
	screen:add(m_grad,f_grad,logo)
	
	
	
	


--load saved settings, or default to Palo Alto,CA
locations = --[[settings.locations or]] {94019,94022,}
bar_i = 1
curr_condition=Group{}

bars={}
screen:add(curr_condition,left_faux_bar,right_faux_bar)
dofile("Internet.lua")
dofile("Weather_Bar.lua")
dofile("Weather_Animations.lua")




--save the queried locations
function app:on_closing()
	
	settings.locations = locations
	
end


day_time=true
mini=true

--make the weather bars for each location
for i,location in pairs(locations) do
	
	table.insert(bars,Make_Bar(location,i))
	
end


--moon:setup()
--animate_list[moon.func_tbls.rise]  = moon
--animate_list[sun.func_tbls.shine] = sun
--animate_list[rain_light]=rain_light

--sun:setup()
--animate_list[sun.func_tbls.rise]  = sun
--animate_list[cloud_spawner.func_tbls.spawn_loop]  = cloud_spawner

--rain:setup()
--animate_list[rain.func_tbls.tstorm_loop]  = rain

screen:add(unpack(bars))
--screen:add(arrow_l,arrow_r)

bars[1].opacity=255
bars[1]:show()
dolater(bars[1].grab_key_focus,bars[1])
