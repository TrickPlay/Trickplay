


screen_w = screen.w
screen_h = screen.h
screen:show()
--screen:add(Rectangle{name="A Grey Background for the APP",w=screen_w,h=screen_h,color={60,60,60}})
dofile("App_Loop.lua")
dofile("Utils.lua")

function post_main()
	
	fade_in_full_gradient = nil
	fade_in_mini_gradient = nil
	
	faux_len = 15
	
	left_faux_bar = Group{
		y=873,
		children = {
			Clone{
				source = imgs.bar.mid,
				width  = faux_len*2,
				tile   = {true,false},
				x      = -faux_len
			},
			Clone{
				source = imgs.bar.side,
				x      = faux_len
			},
		}
	}
	right_faux_bar = Group{
		y=873,
		children = {
			Clone{
				source = imgs.bar.mid,
				width  = faux_len*2,
				tile   = {true,false},
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
	
	left_faux_bar.x=-left_faux_bar.w
	
	right_faux_bar.x=left_faux_bar.w



	m_grad = Clone{
		name     = "Mini Gradient",
		source   = imgs.gradient.mini,
	}
	m_grad.y        = screen_h-m_grad.h
	f_grad = Clone{
		name     = "Full Gradient",
		source   = imgs.gradient.full,
		opacity  = 0
	}
	f_grad.y        = screen_h-f_grad.h
	
	screen:add(m_grad,f_grad,logo)
	
	
	
	
	
	
	--load saved settings, or default to Palo Alto,CA
	locations = settings.locations or {"94019","94022",}
	dumptable(locations)
	bar_i = 1
	view_5_day=false
	curr_condition=Group{name="Bottom Corner Weather conditions"}
	
	all_anims = {}
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
		
		if location == "00000" then
			table.insert(bars,Make_Bar(location,i,true))
			bars[#bars].curr_condition="Sunny"
		else
			table.insert(bars,Make_Bar(location,i))
		end
		
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
end
dolater(post_main)