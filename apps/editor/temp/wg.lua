
local widget = {}

-- Util

 -- Localized string table

local strings = dofile( "localized:strings.lua" ) or {}

-- Set an __index function to warn and return the original string

local function missing_localized_string( t , s )
     print( "\t*** MISSING LOCALIZED STRING '"..s.."'" )
     rawset(t,s,s) -- only warn once per string
     return s
end

setmetatable( strings , { __index = missing_localized_string } )

-- asset() 
local function make_image( k )
    return Image{ src = k }
end

local list = {}
local _mt = {}
_mt.__index = _mt

local function _mt.__call( t , k , f )
    local asset = rawget( list , k )
    if not asset then
        asset = ( f or make_image )( k )
        assert( asset , "Failed to create asset "..k )
        asset:set{ opacity = 0 }
        rawset( list , k , asset )
        screen:add( asset )
    end
    return Clone{ source = asset , opacity = 255 }
end


local function _mt.__newindex( t , k , v )
    assert( false , "You cannot add assets to the asset cache" )
end

local assets = setmetatable( {} , _mt )

-- Lang_Text() ? 

Lang_Text = function(txt_arr, params,align)
	assert(#txt_arr == 4)
	local langs = txt_arr
	print(langs[1],langs[2],langs[3],langs[4])

	l_t = Text{}
	for k,v in pairs(params) do
		print(k,v)
		l_t[k] = v
	end
 
	function l_t.extra.change_lang_to(this_l_t,num)
		if align == "left" then
		this_l_t.text = langs[num]
			
		elseif align == "right" then
		this_l_t.x = this_l_t.x + this_l_t.w/2 
		this_l_t.text = langs[num]
		this_l_t.x = this_l_t.x - this_l_t.w/2 
		this_l_t.anchor_point = {this_l_t.w/2,this_l_t.h/2}
		
		else
			this_l_t.text = langs[num]
			print(this_l_t.x,this_l_t.y)
			this_l_t.anchor_point = {this_l_t.w/2,this_l_t.h/2}
			print("me",this_l_t.w/2,this_l_t.h/2,"  ",this_l_t.x,this_l_t.y)
		end

	end
	l_t.extra.change_lang_to(l_t,1)

	table.insert(text_object_list,l_t)
	return l_t
end


-- Canvas
 
-- make_xbox()

local function make_xbox()
    local BORDER_WIDTH= 3 
    local BORDER_COLOR="FFFFFF5C"

    local XBOX_SIZE = 25
    local PADDING = 10

    local c = Canvas{ size = {XBOX_SIZE + PADDING, XBOX_SIZE + PADDING} }

    c:begin_painting()
    c:new_path()

  -- Draw x button
    local x=0 
    local y=0

    c:move_to ( x, y)
    c:line_to ( x + XBOX_SIZE, y + XBOX_SIZE)
    c:move_to ( x + XBOX_SIZE, y)
    c:line_to ( x, y + XBOX_SIZE)

  -- Draw x button box
    c:move_to ( x, y)
    c:line_to ( x + XBOX_SIZE, y)
    c:move_to ( x + XBOX_SIZE, y)
    c:line_to ( x + XBOX_SIZE, y + XBOX_SIZE)
    c:move_to ( x + XBOX_SIZE, y + XBOX_SIZE)
    c:line_to ( x, y + XBOX_SIZE)
    c:move_to ( x, y + XBOX_SIZE)
    c:line_to ( x, y)

    c:set_line_width (3)
    c:set_source_color( BORDER_COLOR )
    c:stroke (true)
    c:fill (true)

    c:finish_painting()

    return c
end 

-- Make message window background 

local function make_msgWindow_bg()

    local size = {900, 500} 
    local color =  "5a252b"
    local BORDER_WIDTH= 3 
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR="FFFFFF"
    local CORNER_RADIUS=22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2

    local XBOX_SIZE = 25
    local PADDING = 10

    local function draw_path( c )

        c:new_path()

        c:move_to( H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )

        c:line_to( ( c.w )- H_BORDER_WIDTH - CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
        c:curve_to( c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH ,
                    c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH ,
                    c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH + CORNER_RADIUS )

        c:line_to( c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH - CORNER_RADIUS )

        c:curve_to( c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    c.w - H_BORDER_WIDTH - CORNER_RADIUS , c.h - H_BORDER_WIDTH )
        c:line_to( H_BORDER_WIDTH + CORNER_RADIUS , c.h - H_BORDER_WIDTH )

        c:curve_to( H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , c.h - H_BORDER_WIDTH - CORNER_RADIUS )

        c:line_to( H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH + CORNER_RADIUS )

        c:curve_to( H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH,
                    H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
    end

    local c = Canvas{ size = size }

    c:begin_painting()
    draw_path( c )

    -- Fill the whole thing with the color passed in and keep the path

    c:set_source_color(color) -- "050505")
    c:fill(true)

    -- Now, translate to the center and scale to its height. This will
    -- make the radial gradient elliptical.
    c:save()
    c:translate( c.w / 2 , c.h / 2 )
    c:scale( 2 , ( c.h / c.w ) )

    local rr = ( c.w / 2 )
    c:set_source_radial_pattern( 0 , 30 , 0 , 0 , 30 , c.w / 2 )
    c:add_source_pattern_color_stop( 0 , "00000000" )
    c:add_source_pattern_color_stop( 1 , "000000F0" )
    c:fill()
    c:restore()

    -- Draw the glossy glow    
    local R = c.w * 2.2

    c:new_path()
    c.op = "ATOP"
    c:arc( 0 , -( R - 240 ) , R , 0 , 360 )
    c:set_source_linear_pattern( c.w , 0 , 0 , c.h * 0.25 )
    c:add_source_pattern_color_stop( 0 , "FFFFFF20" )
    c:add_source_pattern_color_stop( 1 , "FFFFFF04" )
    c:fill()

    -- Now, draw the path again and stroke it with the border color
    draw_path( c )

    c:set_line_width( BORDER_WIDTH )
    c:set_source_color( BORDER_COLOR )
    c.op = "SOURCE"
    c:stroke( true )

  -- Draw title line
  --if(o_type ~= "msgw" and o_type ~= "Code") then 
    c:new_path()
    c:move_to (0, 74)
    c:line_to (c.w, 74)
    c:set_line_width (3)
    c:set_source_color( BORDER_COLOR )
    c:stroke (true)
    c:fill (true)
  --  end

    c:finish_painting()
    c.position = {0,0}

    return c
end 


local function make_ring(w,h,bc,bw,px,py,br)
        local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color(bc)
        ring:round_rectangle(
            px + bw / 2,
            py + bw / 2,
            w - bw - px * 2 ,
            h - bw - py * 2 ,
            br )
        ring:stroke()
        ring:finish_painting()
        return ring
end 

-- widget.button(t) 

function widget.button(t) 

    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 


    if not p.size then p.size = {180, 60} end   
    if not p.width then p.width = 180 end
    if not p.height then p.height = 60 end 
    if not p.border_color then p.border_color = "FFFFFF" end 
    if not p.focus_color then p.focus_color = "1b911b" end 
    if not p.border_width then p.border_width = 1 end
    if not p.caption then p.caption = "Button" end 
    if not p.font then p.font = "DejaVu Sans 30px" end
    if not p.color then p.color = "FFFFFF" end
    if not p.padding_x then p.padding_x = 7 end
    if not p.padding_y then p.padding_y = 7 end
    if not p.border_radius then p.border_radius = 12 end
    if not p.button_image then p.button_image = assets("assets/smallbutton.png") end
    if not p.focus_image then p.focus_image = assets("assets/smallbuttonfocus.png") end

    local ring = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local focus_ring = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local text = Text{name = "caption", text = p.caption, font = p.font, color = p.color, reactive = true} 
    local button = p.button_image
    local focus = p.focus_image

    group = Group
    {
        size = { p.width , p.height},
        children =
        {
            ring:set{name="ring", position = { 0 , 0 }, opacity = 255 },
            focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0},
            button:set{name="button", position = { 0 , 0 } , size = { p.width , p.height } , opacity = 255 },
            focus:set{name="focus", position = { 0 , 0 } , size = { p.width , p.height } , opacity = 0 },
            text:set{name = "text", position = { (p.width  -text.w)/2, (p.height - text.h)/2} }
        }, 
       position = {100, 100, 0},  
       name = "button", 
       reactive = true,
       extra = {type = "Button"} 
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
	group:grab_key_focus(group)
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
	
    function group:on_button_down(x,y,button,num_clicks)
    end 

    mt = {}
    mt.__newindex = function (t, k, v)

    local function redraw_ring()
       ring = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       focus_ring = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       ring:set{name="ring"}
       focus_ring:set{name="focus_ring"}
       button:set{size={p.width , p.height }}
       focus:set{size={p.width , p.height }}
       text:set{position={(p.width  -text.w)/2, (p.height - text.h)/2} }  
       group:remove(group:find_child("ring"))  
       group:add(ring)
       group:remove(group:find_child("focus_ring"))  
       group:add(focus_ring)
    end  

    if k == "caption" then
       text.text = v
    elseif k == "bsize" then 
       p.width = v[1]
       p.height = v[2]
       redraw_ring()
    elseif (k == "bwidth" or k == "bw" )then 
       p.width = v
       redraw_ring()
    elseif (k == "bheight" or k == "bh") then 
       p.height = v
       redraw_ring()
    end 
    end 

    mt.__index = function (t,k)
    if k == "caption" then return text.text
    elseif k == "bsize" then return p 
    elseif (k == "bwidth" or k == "bw") then return p.width
    elseif (k == "bheight" or k == "bh") then return p.height 
    end 
    end 
  
  setmetatable (group.extra, mt) 
  return group 

end

-- widget.textField(t)

function widget.textField(t)

    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.size then p.size = {200, 80} end   
    if not p.contents then p.contents = "" end
    if not p.width then p.width = 200 end
    if not p.height then p.height = 80 end
    if not p.border_width then p.border_width  = 3 end
    if not p.border_color then p.border_color  = "FFFFFFC0" end 
    if not p.focus_color then p.focus_color  = "1b911b" end 
    if not p.font then p.font = "DejaVu Sans 30px"  end 
    if not p.color then p.color = "FFFFFF" end 
    if not p.box_img then p.box_img = assets("assets/smallbutton.png") end 
    if not p.focus_box_img then p.focus_box_img = assets("assets/smallbuttonfocus.png") end 
    if not p.padding_x then p.padding_x = 7 end
    if not p.padding_y then p.padding_y = 7 end
    if not p.border_radius then p.border_radius = 12 end

    local box = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local focus_box = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local box_img = p.box_image
    local focus_box_img = p.focus_image
    local text = Text{text = contents, editable = true, cursor_visible = false, reactive = true, font = p.font, color = p.color}

    textField = Group
     {
        size = { p.width , p.height},
        children =
        {
            box:set{name="box", position = { 0 , 0 } },
	    focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0},
            --box_img:set{name="button", position = { 0 , 0 } , size = { ring_size.width , ring_size.height } , opacity = 255 },
            --focus_box_img:set{name="focus", position = { 0 , 0 } , size = { ring_size.width , ring_size.height } , opacity = 0 },
            text:set{name = "text", position = {p.padding_x, (p.height - text.h)/2} }
        }, 
       position = {200, 200, 0},  
       name = "textField", 
       reactive = true 
     }

     function textField.extra.on_focus_in()
          text:grab_key_focus()
	  box.opacity = 0 
          focus_box.opacity = 255
	  text.cursor_visible = true
     end

     function textField.extra.on_focus_out()
          box.opacity = 255 
          focus_box.opacity = 0
	  text.cursor_visible = false
     end

     mt = {}
     mt.__newindex = function (t, k, v)

     local function redraw_ring()
       box = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       box:set{name="box"}
       focus_box = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       focus_box:set{name="focus_box", opacity = 0}
       text:set{position={p.padding_x, (p.height - text.h)/2} }  
       textField:remove(textField:find_child("box"))  
       textField:add(box)
       textField:remove(textField:find_child("focus_box"))  
       textField:add(focus_box)
     end  

     if k == "contents" then 
	text.text = v
     elseif k == "bsize" then 
       ring_size.width = v[1]
       ring_size.height = v[2]
       redraw_ring()
     elseif (k == "bwidth" or k == "bw" )then 
       ring_size.width = v
       redraw_ring()
     elseif (k == "bheight" or k == "bh") then 
       ring_size.height = v
       redraw_ring()
     elseif (k == "border_width") then 
       border_width= v
       redraw_ring()
     elseif (k == "border_color" or k == "bc") then 
       border_color= v
       redraw_ring()
     elseif (k == "focus_color" or k == "fc") then 
       focus_color= v
       redraw_ring()
     elseif (k == "font") then 
       text:set{font = v}
     elseif (k == "color") then 
       text:set{color = v}
     end 
     end 

     mt.__index = function (t,k)
     if k == "contents" then 
        return text.text
     elseif k == "bsize" then 
        return ring_size 
     elseif (k == "bwidth" or k == "bw") then 
        return ring_size.width
     elseif (k == "bheight" or k == "bh") then 
        return ring_size.height 
     elseif (k == "border_width") then 
        return border_width
     elseif (k == "border_color") then 
        return border_color
     elseif (k == "focus_color") then 
        return focus_color
     elseif (k == "font") then 
        return font
     elseif (k == "color") then 
        return color
     end 
     end 
  
     setmetatable (textField.extra, mt) 
     return textField
end 

-- Message Window 

function widget.messageWindow(t)
    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.name then p.name = "msgWindow" end   
    if not p.size then p.size = {34, 60} end   
    if not p.position then p.position = {200, 200} end   
    if not p.title then p.title = "Title" end
    if not p.width then p.width = 34 end
    if not p.height then p.height = 60 end
    if not p.border_width then p.border_width  = 3 end
    if not p.border_color then p.border_color  = "FFFFFFC0" end 
    if not p.font then p.font = "DejaVu Sans 30px"  end 
    if not p.color then p.color = "FFFFFF" end 
    if not p.padding_x then p.padding_x = 10 end
    if not p.padding_y then p.padding_y = 10 end
    if not p.border_radius then p.border_radius = 22 end

    local msgw_cur_x = 300  
    local msgw_cur_y = 40

    local  msgw = Group {
          name = "msgWindow",
	  position ={200, 200},
	  anchor_point = {0,0},
          children =
          {
          }
    }

    local function cleanMsgWindow()
          msgw.children = {}
          msgw_cur_x = 300	
          msgw_cur_y = 40
          screen:remove(msgw)
          input_mode = S_SELECT
     end 

     -- from : util.lua 812 lines

     local msgw_bg = make_msgWindow_bg()
     msgw:add(msgw_bg)

     local msgw_title = Text{name= name, text = "TITLE", font= "DejaVu Sans 32px",
     color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y - 5}, editable = false ,
     reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}     
     msgw:add(msgw_title)

     local msgw_xbox = make_xbox()
     msgw_xbox.position  = {msgw_cur_x + 550, msgw_cur_y} 
     msgw:add(msgw_xbox)
  
     return msgw
end 

-- Sliding button 
--[[name = mode, korean-mode 
    options : {{"Home Mode","Casa el Modo de","Mode d'Accueil","가정용"}, 
              {"Store Demo","Demo Store","Demo Store","데모 모드"}}
 ]]

function widget.buttonCarousel(t)
	-- menu,name,options,pos,buttons,arrows,rotate_func,...
     local p = {}
     if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
     end 

     if not p.name then p.name = "buttonCarousel" end   
     if not p.options then p.options = "" end   
     if not p.buttons then p.buttons = "" end   
     if not p.arrows then p.arrows = "" end   
     if not p.rotate_func then p.rotate_func = "" end   

     if not p.size then p.size = {34, 60} end   
     if not p.position then p.position = {200, 200} end   

     if not p.width then p.width = 34 end
     if not p.height then p.height = 60 end
     if not p.border_width then p.border_width  = 3 end
     if not p.border_color then p.border_color  = "FFFFFFC0" end 
     if not p.font then p.font = "DejaVu Sans 30px"  end 
     if not p.color then p.color = "FFFFFF" end 
     if not p.padding_x then p.padding_x = 10 end
     if not p.padding_y then p.padding_y = 10 end
     if not p.border_radius then p.border_radius = 22 end

-- new prams : 
     if not p.optionNum then p.optionNum = 3 end
-- new prams : 

     local button_un    = Image{src = "assets/button.png",           opacity = 0}
     local button_sel   = Image{src = "assets/buttonfocus.png",      opacity = 0}
     --local s_button_un  = Image{src = "assets/smallbutton.png",      opacity = 0}
     local s_button_sel = Image{src = "assets/smallbuttonfocus.png", opacity = 0}
     local right_un     = Image{src = "assets/right.png",            opacity = 0}
     local right_sel    = Image{src = "assets/rightfocus.png",       opacity = 0}
     local left_un      = Image{src = "assets/left.png",             opacity = 0}
     local left_sel     = Image{src = "assets/leftfocus.png",        opacity = 0}
:
     --oobe : local name = {[strings["ButtonName"]] = {["english"]="Mode: ",["spanish"]="Modo: ",["french"]="Fonction: ",["korean"]="모드: "}}
     -- oobe : local options = {[strings ["Option1"]] = {["english"]="Home Mode",["spanish"]="Casa el Modo de",["french"]="Mode d'Accueil",["korean"]="가정용"},[strings["Option2"]]= {["english"]="Store Demo",["spanish"]="Demo Store",["french"]="Demo Store",["korean"]="데모 모드"}}

     local name = strings["ButtonName"] 
     local options = {strings["Option1"], strings["Option2"], strings["Option3"]}

     -- local buttons = { s_button_un,s_button_sel }
     local arrows    = { right_un, right_sel, left_un, left_sel }


     local pos = {screen.w/2+button_sel.w/2+10,414+buttons[1].h/2},
     local index = 1

     local unfocus = assets("assets/smallbutton.png"):set(anchor_point = {self.w/2,self.h/2},
                            position = {pos[1], pos[2]}, opacity = 0)

     local focus = assets("assets/smallbuttonfocus.png"):set(anchor_point = {self.w/2,self.h/2},
		           position = {pos[1], pos[2]}, opacity = 0)

     local right_un  = assets("assets/right.png"):set( anchor_point = {self.w/2,self.h/2},
		       position = {focus.x + focus.w/2+self.w/2+15,focus.y}, opacity = 0)

     local right_sel = assets("assets/rightfocus.png"):set(anchor_point = {self.w/2,self.h/2},
		       position = {focus.x + focus.w/2+self.w/2+15, focus.y},  opacity = 0)

     local left_un   = assets("assets/left.png"):set("assets/left.png"):set(anchor_point = {self.w/2,self.h/2},
		       position = {focus.x - focus.w/2-self.w/2 -15, focus.y},  opacity = 0)

     local left_sel  = assets("assets/leftfocus.png"):set( anchor_point = {self.w/2,self.h/2},
		       position = {focus.x - focus.w/2-self.w/2-15, focus.y, opacity = 0})

     local name = Text{text=name, font = "LG Display10_CJK 36px", color = "FFFFFF"} 
     name.anchor_point = {self.w/2,self.h/2}
     name.position = {focus.x - focus.w/2 - self.w/2 - 55,focus.y}
     txt_group = Group{}

     items = {}

     for i = 1, #options do
	items[i] = Group()
	local txt = Lang_Text(options[i],
	{
		--text  = options[i],
		font  = "LG Display10_CJK 32px",
		color = "FFFFFF",
		--opacity = 0
	})
	txt.anchor_point = 
	{
		txt.w/2,
		txt.h/2+2
	}
	local t_shadow = Lang_Text(options[i],
	{
		--text  = options[i],
		font  = "LG Display10_CJK 32px",
		color = "000000",
		--opacity = 0
	})
	t_shadow.anchor_point = 
	{
		t_shadow.w/2+1,
		t_shadow.h/2+3
	}
	items[i]:add(t_shadow,txt)
		txt_group:add(items[i])
      end
 
      menu = Group
      {
		children = {unfocus, focus, right_un, right_sel, left_un, left_sel, txt_group, name, txt_group}
      }
     

	--first item selected
       items[1].opacity = 255
       items[1].x       = pos[1] --+ focus.w/2
       items[1].y       = pos[2]-- + focus.h/2

	--hover events
	function menu.extra.on_focus()
		unfocus.opacity = 0
		focus.opacity   = 255
	end
	function menu.extra.out_focus()
		unfocus.opacity = 255
		focus.opacity   = 0
	end
	local t = nil

	--key press events
	function menu.extra.press_left()
		local prev_i = index
		local next_i = (index-1-1)%(#items)+1

                print(prev_i,next_i, #items,"hi")
		index = next_i
		local prev_old_x = pos[1]--+focus.w/2
		local prev_old_y = pos[2]--+focus.h/2
		local next_old_x = pos[1]+focus.w--+3*focus.w/2
		local next_old_y = pos[2]--+focus.h/2

		local prev_new_x = pos[1]-focus.w--/2
		local prev_new_y = pos[2]--+focus.h/2
		local next_new_x = pos[1]--+focus.w/2
		local next_new_y = pos[2]--+focus.h/2
		if t ~= nil then
			t:stop()
			t:on_completed()
		end
		t = Timeline
		{
			duration = 300,
			direction = "FORWARD",
			loop = false
		}

		function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
				left_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				left_sel.opacity = 255
			else 
				left_sel.opacity = 255*(1- (msecs-200)/100)
			end
			items[prev_i].x = prev_old_x + p*(prev_new_x - prev_old_x)
			items[prev_i].y = prev_old_y + p*(prev_new_y - prev_old_y)

			items[next_i].x = next_old_x + p*(next_new_x - next_old_x)
			items[next_i].y = next_old_y + p*(next_new_y - next_old_y)
		end
		function t.on_completed()
			items[prev_i].x = prev_new_x
			items[prev_i].y = prev_new_y

			items[next_i].x = next_new_x
			items[next_i].y = next_new_y
			t = nil
		end
			if rotate_func then
				rotate_func(next_i,prev_i)
			end

		t:start()
	end

	local function menu.extra.press_right()
		local prev_i = index
		local next_i = (index+1-1)%(#items) + 1
                print(prev_i,next_i)
		index = next_i
		local prev_old_x = pos[1]
		local prev_old_y = pos[2]
		local next_old_x = pos[1]-focus.w
		local next_old_y = pos[2]

		local prev_new_x = pos[1]+focus.w
		local prev_new_y = pos[2]
		local next_new_x = pos[1]
		local next_new_y = pos[2]
		if t ~= nil then
			t:stop()
			t:on_completed()
		end

		t = Timeline
		{
			duration = 300,
			direction = "FORWARD",
			loop = false
		}

		function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
G				right_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				right_sel.opacity = 255
			else 
				right_sel.opacity = 255*(1- (msecs-200)/100)
			end

			items[prev_i].x = prev_old_x + p*(prev_new_x - prev_old_x)
			items[prev_i].y = prev_old_y + p*(prev_new_y - prev_old_y)

			items[next_i].x = next_old_x + p*(next_new_x - next_old_x)
			items[next_i].y = next_old_y + p*(next_new_y - next_old_y)
		end
		function t.on_completed()
			items[prev_i].x = prev_new_x
			items[prev_i].y = prev_new_y

			items[next_i].x = next_new_x
			items[next_i].y = next_new_y
			t = nil
		end
			if rotate_func then
				rotate_func(next_i,prev_i)
			end

		t:start()

	end
 	local function extra.press_up()
	end
	local function extra.press_down()
	end
	local function extra.press_enter()
	end

	out_focus()
        
        return menu 
end

--[[
]]
-- Focusable Image 


--[[


FocusableImage = Class(function(focusimg, pos, txt, image_clone, focus_clone,enter_func, ...)
    assert(pos)
    assert(pos[1])
	assert(pos[2])
    assert(image_clone)
    assert(focus_clone)
    focusimg.image = Clone
	{ 
		name = "buttonsss",
		source = image_clone,
		anchor_point = {image_clone.w/2,image_clone.h/2},
		position = {pos[1], pos[2]}
	}

    focusimg.focus = Clone
	{
		source = focus_clone,
		anchor_point = {focus_clone.w/2,focus_clone.h/2},
		opacity = 0,
		position = {pos[1], pos[2]}
	}

    focusimg.group = Group()
    focusimg.group:add(focusimg.image, focusimg.focus)
    if txt ~= nil then
		local t_shadow = Lang_Text(txt,
		{
			name     = "text_s",
	--		text     = txt,
			font     = "LG Display10_CJK 32px",
			color    = "000000"
		})
		t_shadow.anchor_point = {t_shadow.w/2,t_shadow.h/2}
		t_shadow.position     = 
		{
			pos[1]-1,
			pos[2]-1
		}

		local t = Lang_Text(txt,
		{
			name     = "text",
	--		text     = txt,
			font     = "LG Display10_CJK 32px",
			color    = "FFFFFF"
		})
		t.anchor_point = {t.w/2,t.h/2}
		t.position     = 
		{
			pos[1],
			pos[2]
		}
        focusimg.group:add(t_shadow,t)
    end
    function focusimg:on_focus()
		focusimg.focus.opacity = 255
		focusimg.image.opacity = 0
    end

    function focusimg:out_focus()
		focusimg.focus.opacity = 0
		focusimg.image.opacity = 255
    end


	function focusimg:press_left()
	end
	function focusimg:press_right()
	end
	function focusimg:press_up()
	end
	function focusimg:press_down()
	end
	function focusimg:press_enter()
	end

	focusimg:out_focus()
end)


-- Scroll Bar 

function make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     
     local x_scroll_box, y_scroll_box 
     local x_scroll_bar, y_scroll_bar 

     if(x_scroll_to == 0)then 
	 x_scroll_to = screen.w
     end
     if(y_scroll_to == 0)then 
	 y_scroll_to = screen.h
     end

     g.extra.canvas_h = y_scroll_to - y_scroll_from -- y 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_w = x_scroll_to - x_scroll_from -- x 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_f = y_scroll_from
     g.extra.canvas_xf = x_scroll_from
     g.extra.canvas_t = y_scroll_to
     g.extra.canvas_xt = x_scroll_to

     screen_rect =  Rectangle{
                name="screen_rect",
                border_color= {2, 25, 25, 140},
                border_width=2,
                color= {255,255,255,0},
                size = {screen.w+1,screen.h+1},
                position = {0,0,0}, 
     }
     screen_rect.reactive = false
     g:add(screen_rect)


     
    if (g.extra.canvas_w > screen.w) then 
	local SCROLL_X_POS = 10
	local BOX_BAR_SPACE = 6
	
        x_scroll_box = factory.make_x_scroll_box()
        x_scroll_bar = factory.make_x_scroll_bar(g.extra.canvas_w)

	x_scroll_box.position = {SCROLL_X_POS, screen.h - 60}
	x_scroll_bar.position = {SCROLL_X_POS + BOX_BAR_SPACE, screen.h - 56}

	
        x_scroll_bar.extra.org_x = 16
	x_scroll_bar.extra.h_x = 16
	x_scroll_bar.extra.l_x = x_scroll_box.x + x_scroll_box.w - x_scroll_bar.w - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(x_scroll_box) 
	screen:add(x_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dx = ((g.extra.canvas_w - screen.w)/(x_scroll_bar.extra.l_x - x_scroll_bar.extra.h_x))

		
	local x0 = - g.extra.canvas_xf/g.extra.scroll_dx + 10 
	local x1920 = (-g.extra.canvas_xf+1080)/g.extra.scroll_dx + 10

	x_0_mark= Rectangle {
		name="x_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x0, screen.h - 55, 0},
		opacity = 255
        }

	x_1920_mark= Rectangle {
		name="x_1920_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x1920, screen.h - 55, 0},
		opacity = 255
        }
  
	screen:add(x_0_mark)
	screen:add(x_1920_mark) 

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_x = m.x
	end 
         
        function x_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {x_scroll_bar, x-x_scroll_bar.x, y-x_scroll_bar.y }

		if table.getn(selected_objs) ~= 0 then
		     for q, w in pairs (selected_objs) do
			 local t_border = screen:find_child(w)
			 local i, j = string.find(t_border.name,"border")
		         local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		         if(t_obj ~= nil) then 
			      screen:remove(screen:find_child(t_obj.name.."a_m"))
			 end
		     end
		end

        	return true
    	end 

    	function x_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_x <= x-dx and x-dx <= actor.extra.l_x) then -- 스크롤 되는 범위안에 있으면	
	           		dif = x - dx - x_scroll_bar.extra.org_x -- 스크롤이 이동한 거리 
	           		x_scroll_bar.x = x - dx 
	      		elseif (actor.extra.h_x > x-dx ) then
				dif = actor.extra.h_x - x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.h_x
	      		elseif (actor.extra.l_x < x-dx ) then
				dif = actor.extra.l_x- x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.l_x
			end 
			dif = dif * g.extra.scroll_dx -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.extra.org_x-dif-x_scroll_from, j.y, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.x = t_obj.x 
				 end
			     end
			end

			g.extra.scroll_x = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 


     if(g.extra.canvas_h > screen.h) then 


	local SCROLL_Y_POS = 90
	local BOX_BAR_SPACE = 6

	y_scroll_box = factory.make_y_scroll_box()
        y_scroll_bar = factory.make_y_scroll_bar(g.extra.canvas_h) 

	y_scroll_box.position = {screen.w - 60, SCROLL_Y_POS}
	y_scroll_bar.position = {screen.w - 56, SCROLL_Y_POS + BOX_BAR_SPACE}

        y_scroll_bar.extra.org_y = 96
	y_scroll_bar.extra.h_y = 96
	y_scroll_bar.extra.l_y = y_scroll_box.y + y_scroll_box.h - y_scroll_bar.h - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(y_scroll_box) 
	screen:add(y_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dy = ((g.extra.canvas_h - screen.h)/(y_scroll_bar.extra.l_y - y_scroll_bar.extra.h_y))
  
	
	local y0 = - g.extra.canvas_f/g.extra.scroll_dy + 10 
	local y1080 = (-g.extra.canvas_f+1080)/g.extra.scroll_dy + 10

	y_0_mark= Rectangle {
		name="y_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y0, 0},
		opacity = 255
        }

	y_1080_mark= Rectangle {
		name="y_1080_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y1080, 0},
		opacity = 255
       }
  
	screen:add (y_0_mark)
	screen:add (y_1080_mark)

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_y = m.y
	end 
         
        function y_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {y_scroll_bar, x-y_scroll_bar.x, y-y_scroll_bar.y }
		if table.getn(selected_objs) ~= 0 then
			for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
				      screen:remove(screen:find_child(t_obj.name.."a_m"))
				 end
			end
		end

        	return true
    	end 

    	function y_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_y <= y-dy and y-dy <= actor.extra.l_y) then -- 스크롤 되는 범위안에 있으면	
	           		dif = y - dy - y_scroll_bar.extra.org_y -- 스크롤이 이동한 거리 
	           		y_scroll_bar.y = y - dy 
	      		elseif (actor.extra.h_y > y-dy ) then
				dif = actor.extra.h_y - y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.h_y
	      		elseif (actor.extra.l_y < y-dy ) then
				dif = actor.extra.l_y- y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.l_y
			end 
			dif = dif * g.extra.scroll_dy -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.x, j.extra.org_y-dif-y_scroll_from, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.y = t_obj.y 
				 end
			     end
			end

			g.extra.scroll_y = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 
end



-- Menu Bar 

-- main.lua 60 lines 

     ui = {
        fs_focus            = nil,
        bar                 = Group {},
        bar_background      = assets( "assets/menu-background.png" ),
        button_focus        = assets( "assets/button-focus.png" ),
        logo                = assets( "assets/logo.png" ),

        sections =
        {
        }
     }

    ----------------------------------------------------------------------------
    -- The group that holds the bar background and the buttons
    ----------------------------------------------------------------------------
    
    ui.bar:set
    {
        size = ui.bar_background.size,
        
        position = { 0 , 0 },
        
        children =
        {
            ui.bar_background:set
            {
                position = { 0 , 0 },
		size = {ui.bar_background.w, ui.bar_background.h - 15}
            },
            
            ui.button_focus:set
            {
                position = { FIRST_BUTTON_X , FIRST_BUTTON_Y },        
		size  = {ui.button_focus.w, ui.button_focus.h - 15}
            }
        }
    }

    screen:add( ui.bar )    

       
    local i = 0
    local left = FIRST_BUTTON_X
    
    for _ , section in ipairs( ui.sections ) do
    
        section.ui = ui
        section.button.h = section.button.h - 15

        -- Create the dropdown background
        section.dropdown_bg = ui.factory.make_dropdown( { section.button.w + DROPDOWN_WIDTH_OFFSET , section.height } , section.color )
    
        -- Position the button and text for this section
        section.button.position =
        {
            left,
            FIRST_BUTTON_Y
        }
        
        left = left + BUTTON_X_OFFSET + section.button.w 
    
        section.text.position =
        {
            section.button.x + BUTTON_TEXT_X_OFFSET ,
            section.button.y + BUTTON_TEXT_Y_OFFSET - 5 
        }
        
        -- Create the dropdown group
        
        section.dropdown = Group
        {
            size = section.dropdown_bg.size,
            anchor_point = { section.dropdown_bg.w / 2 , 0 },
            position = 
            {
                section.button.x + section.button.w / 2,
                ui.bar.h + DROPDOWN_POINT_Y_OFFSET
            },
            children =
            {
                section.dropdown_bg
            }
        }
        
        -- Add the text and button
        
        ui.bar:add( section.button , section.text )
        
        -- Make sure its Z is correct with respect to the focus image
        
        section.button:lower( ui.button_focus )
        section.text:raise( ui.button_focus )
        
        -- Add the section dropdown to the screen
        
        screen:add( section.dropdown )
        i = i + 1

    end

]]

-- DropDown Menu
     -- how many items 

-- DropDown Button
     -- how many items 

-- short cut menu (right button click) 
    -- how many items

-- Check Box 
    -- text / image for choice
    -- draw two nemo 
    -- when the user select the check box, check ploy
   
 
-- Radio Button 

-- FileChooser 

-- 

return widget
