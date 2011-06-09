--screen:show()
screen_w = screen.w
screen_h = screen.h
function main()
	
	local curr_page = "front_page"
	
	function change_page_to(next_page)
		
		assert(_G[next_page] ~= nil,"Next page \""..next_page.."\" does not exist")
		
		animate_list[_G[curr_page].func_tbls.fade_out_to[next_page]]  = _G[curr_page]
		animate_list[_G[next_page].func_tbls.fade_in_from[curr_page]] = _G[next_page]
		
		curr_page = next_page
		
	end
	
	function get_curr_page()
		
		return curr_page
		
	end
	
	dofile("App_Loop.lua")
	dofile("Utils.lua")
	front_page = dofile("FrontPage.lua") -- global: front_page
	--dofile("CollectionPage.lua")
	dofile("CategoryPage.lua")
	dofile("ProductPage.lua")
	
	local cursor = Assets:Clone{src=imgs.cursor}
	
	screen:add(
		front_page,
		category_page.group,
		product_page.group,
		cursor
	)
	
	function key_handler(self,key)
		if _G[curr_page].keys[key] == nil then
			print("\""..curr_page.."\" does not support that key.")
		else
			_G[curr_page].keys[key](_G[curr_page])
		end
	end
	
	
	mouse_manager = {
		busy = false,
		on_enters = {}
	}
	
	function restore_keys()
		
		screen.on_key_down = key_handler
		
		mouse_manager.busy = false
		
		for on_e,p in ipairs(mouse_manager.on_enters) do
			
			on_e(p)
			
		end
	end
	
	function lose_keys()
		
		screen.on_key_down = nil
		
		mouse_manager.busy = true
		
	end
	
	if controllers.start_pointer then controllers:start_pointer() end
	
	screen.reactive = true
	
	local hold = false
	
	local prev_on_motion = {x=nil,y=nil,t=nil}
	
	local vxs = {}
	local avx = 0
	
	local time = Stopwatch()
	time:start()
	local t = nil
	
	function screen:on_motion(x,y)
		
		
		
		cursor.x = x
		cursor.y = y
		
		if hold then
			if _G[curr_page].on_motion then
				_G[curr_page]:on_motion(x,y)
			end
			
			t = time.elapsed
			
			if prev_on_motion.t ~= nil then
				
				table.insert(vxs,(x - prev_on_motion.x)/((t-prev_on_motion.t)/1000))
				
				if #vxs > 5 then table.remove(vxs,1) end
				
			end
			
			prev_on_motion.x = x
			prev_on_motion.y = y
			prev_on_motion.t = t
		end
	end
	
	
	
	function screen:on_button_down(x,y)
		
		hold = true
		
		vxs = {}
		
		if _G[curr_page].hold then _G[curr_page]:hold(x,y) end
		
	end
	
	function screen:on_button_up(x,y)
		
		hold = false
		
		avx = 0
		
		for _,v in ipairs(vxs) do avx = avx+v; print(avx) end
		
		if #vxs ~= 0 then avx = avx/#vxs end
		
		if _G[curr_page].release then _G[curr_page]:release(x,avx) end
		
	end
	
	function screen:on_leave(x,y)
		
		if hold then screen:on_button_up(x,y) end
		
	end
	restore_keys()

end

Assets = dofile( "Assets.lua" )

do

    local r = Rectangle
    {
        color = "000000b0",
        size = { 0 , 20 },
        x = 10,
        y = screen.h - 26
    }
    local b = Image{ src = "splash.jpg" }
    b.scale = { screen.w / b.w , screen.h / b.h }
    screen:add( b , r )
    screen:show()
    
    local function progress( percent , src , failed )
        r.w = ( screen.w - 20 ) * percent
    end
    
    local function finished()
        screen:remove( r , b )
        r = nil
        b = nil
        main()
    end
    
    Assets:queue_app_contents()
    
    Assets:load( progress , finished )
end