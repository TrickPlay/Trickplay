screen_w = screen.w
screen_h = screen.h

function main()
    
    --Images
    imgs = {
	box_foc_corner = "assets/focus-corner.png",
	box_foc_side = "assets/focus-edge.png",
	cursor = "assets/cursor.png",
	fp = {
	    foc_end = "assets/btn-end.png",
	    foc_mid = "assets/btn-mid.png",
	    arrow   = "assets/arrow.png"
	}
    }
    
    local cursor = Assets:Clone{src=imgs.cursor}
    
    
    ----------------------------------------------------------------------------
    -- App State - a.k.a. the current active page
    ----------------------------------------------------------------------------
    
    local curr_page = "front_page"
    
    function change_page_to(next_page)
	    
	    assert(_G[next_page] ~= nil,"Next page \""..next_page.."\" does not exist")
	    
	    print(curr_page,"  to  ",next_page)
	    
	    animate_list[_G[curr_page].func_tbls.fade_out_to[next_page]]  = _G[curr_page]
	    animate_list[_G[next_page].func_tbls.fade_in_from[curr_page]] = _G[next_page]
	    
	    for _,v in ipairs(_G[curr_page].reactive_list) do
		
		v.reactive = false
		
	    end
	    
	    curr_page = next_page
	    
	    for _,v in ipairs(_G[curr_page].reactive_list) do
		
		v.reactive = true
		
	    end
	    
    end
    
    function get_curr_page()
	
	return curr_page
	
    end
    
    
    ----------------------------------------------------------------------------
    -- add all of the screens
    ----------------------------------------------------------------------------
    
    animate_list  = dofile("App_Loop.lua")
    
    front_page    = dofile("FrontPage.lua")
    category_page = dofile("CategoryPage.lua")
    product_page  = dofile("ProductPage.lua")
    
    --make the first page reactive
    for _,v in ipairs(_G[curr_page].reactive_list) do
	
	v.reactive = true
	
    end
    
    
    ----------------------------------------------------------------------------
    -- Key Events
    ----------------------------------------------------------------------------
    
    using_keys = true
    
    function key_handler(self,key)
	    if not using_keys then
	        using_keys = true
		cursor:hide()
		if _G[curr_page].to_keys then
		    
		    _G[curr_page].to_keys()
		    
		end
	    end
	    if _G[curr_page].keys[key] == nil then
		    print("\""..curr_page.."\" does not support that key.")
	    else
		    _G[curr_page].keys[key](_G[curr_page])
	    end
    end
    
    --functions for removing and restoring key handling (during animations)
    function restore_keys() screen.on_key_down = key_handler end
    
    function lose_keys()    screen.on_key_down = nil         end
    
    restore_keys()
    
    
    ----------------------------------------------------------------------------
    -- Mouse Events
    ----------------------------------------------------------------------------
    
    if controllers.start_pointer then controllers:start_pointer() end
    
    screen.reactive = true
    
    function screen:on_motion(x,y)
	
	if using_keys then
	    
	    using_keys = false
	    
	    cursor:show()
	    
	    if _G[curr_page].to_mouse then
		
		_G[curr_page].to_mouse()
		
	    end
	    
	end
	
	cursor.x = x
	
	cursor.y = y
	
    end
    
    function screen:on_button_down()
	
	if using_keys then
	    
	    using_keys = false
	    
	    cursor:show()
	    
	    if _G[curr_page].to_mouse then
	        
	        _G[curr_page].to_mouse()
		
	    end
	    
	end
	
    end
    
    cursor:hide()
    
    
    
    --add it all to screen
    screen:add(
	front_page,
	category_page,
	product_page,
	cursor
    )
    
end


--------------------------------------------------------------------------------
-- Pablo's Zoom Screen Loading Bar Trick
--------------------------------------------------------------------------------

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