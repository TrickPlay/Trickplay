local SLIDESHOW_WIDTH = 1200
local SLIDESHOW_HEIGHT = 800

SlideshowView = Class(View, function(view, model, ...)
    view._base.init(view, model)
    view.ui = Group{name="slideshow ui"}
    screen:add(view.ui)
    local backup = Image {
        name    = "slide",
        src     = "assets/none.png",
        opacity = 0
    }
    --screen:add(backup)
    local overlay_image = Image
    { 
        src     = "assets/overlay.png", 
        opacity = 0 
    }

    local background  = Image {src = "assets/background.jpg"  }
local mosaic_background = Image {src = "assets/tiled-slideshow-bkgd.jpg" , size = {screen.w,screen.h},opacity=255}

    --NAV MENU
    view.nav_group = Group    { position = {1500, 300}, opacity = 0 }
    local nav_back  = Rectangle{ w = 300,  h = 400,  color = "FFFFFF"}
    view.nav_group:add(nav_back)
    view.nav_items =
    {
        Text{text = "Close Menu",              y = 160, font="Sans 36px"},
        Text{text = "Back to Albums",          y = 220, font="Sans 36px"},
        --Text{text = "Hide this Album",         y = 280, font="Sans 36px"},
        Text{text = "Play Slideshow",          y = 280, font="Sans 36px"},
        Text{text = "Change Slide Show Style", y = 340, font="Sans 36px"},
    }
    view.nav_group:add(unpack(view.nav_items))
    view.logo = Image
    {
        name = "slideshow cover",
        src  = "",
        position = {-40,-75},
        size = {300, 225}
    }
    view.queryText = Text 
    { 
        text = "",
        font = "Sans 30px",
        x    = 105, 
        y    = 80
    }
    view.nav_group:add(view.queryText, view.logo)
    view.ui:add(view.nav_group)

    local caption = Text 
    {
        font = "Sans 15px",
        text = "",
        x    = 1530,
        y    = 400
    }
--off screen -300,400
--on screen 10,400
local postit = Group{name="post-it",position = {-250,400}}
local postit_bg = Image
{src = "assets/note-menu.png"}
local postit_text =
{
	Image{src="assets/note-menu-text0.png",y=80,x=35,opacity=255},
	Image{src="assets/note-menu-text1.png",opacity=0},
	Image{src="assets/note-menu-text2.png",opacity=0},
	Image{src="assets/note-menu-text3.png",opacity=0}
}
--style one ,x=55,y=160
--style one ,x=70,y=195
--done ,x=95,y=260
local postit_arrow   = Image{src="assets/note-menu-arrow.png",x=95,y=260}--,x=postit.x,y=postit.y}
local postit_options = Image{src="assets/note-menu-options.png",x=250,y=250}--,x=postit.x,y=postit.y}

postit:add(postit_bg, postit_arrow, postit_options)
postit:add(unpack(postit_text))

local license_box = Group{name="license box",position={1000,1040}}
license_box:add(Rectangle{color="000000",w=920,h=80,opacity=150})
    view.ui:add( backup, overlay_image, background, postit, caption, mosaic_background,license_box )

    view.timer            = Timer()
    view.timer.interval   = 4000
    view.timer_is_running = false
     

    view.on_screen_list  = {}
    view.off_screen_list = {}
    view.license_on  = {}
	view.license_off = {}

    view.styles = {"REGULAR","LAYERED"}--,"MOSAIC"}--,"FULLSCREEN",}
    local off_screen_prep = 
    {
        ["REGULAR"]    = function(img,group)
			group:add( Rectangle{
						name = "backing",
                        size = {
                            img.w,
                            img.h
                        },
                        color        = { 0,  0, 0, 255 },
                        opacity = 255
                })
			group:add(img)
			group:add( Rectangle{
						name = "overlay",
                        size = {
                            group.size[1] + 12,
                            group.size[2] + 12 -- 12 = border_width * 2
                        },
                        color        = { 0,  0, 0, 0 },
                        border_color = { 220, 220, 220,255 },

						position = {-6,-6},
                        border_width=6,
                        opacity = 255
                })
--			print("off1",group.w,group.h)
			if group.w/group.h > screen.w/screen.h then
				group.scale = {((screen.w-400)*.9)/group.w,((screen.w-400)*.9)/group.w}
			else
				group.scale = {(screen.h*.9)/group.h,(screen.h*.9)/group.h}
			end
--			print("off2",group.w,group.h,group.size[1],group.size[2])
			group.z_rotation   = { math.random(-10,10), 
									group.size[1]/2,
									group.size[2]/2}

			group.anchor_point = {	group.size[1]/2,
									group.size[2]/2}

			group.position = {	(screen.w-400)/2+math.random(-5,5)+400,
								screen.h/2+math.random(-5,5)}


--[[
                local overlay = Clone 
                {
                    name   = "overlay",
                    source = overlay_image, 
                    scale  = 
                    {
                        img.w/(screen.w-100),
                        img.h/(screen.h-100)
                    }, 
                    x = (-img.w)/40,
                    y = (-img.h)/20
                }
                group.anchor_point = {0,0}
                group.scale = 
                {
                    SLIDESHOW_HEIGHT/img.h,
                    SLIDESHOW_HEIGHT/img.h
                }
                local i_width = img.w * SLIDESHOW_HEIGHT/img.h
                local i_height = SLIDESHOW_HEIGHT
                print ("original: "..img.w.." WIDTH:"..i_width)
                if (img.w/img.h > 1.5) then
                    group.scale = 
                    {
                        SLIDESHOW_WIDTH/img.w,
                        SLIDESHOW_WIDTH/img.w
                    }
                    i_height = i_height * SLIDESHOW_WIDTH/i_width
                end
                group.x = math.random(0,1)*1920
                group.y = math.random(0,1)*1080
                group.z_rotation = 
                {
                    math.random(-10,10), 
                    i_width/2, 
                    i_height/2
                }

                group:add(img,overlay)
                local backing = Rectangle
                {
                        size = {
                            img.size[1],
                            img.size[2]
                        },
                        color        = { 0,  0, 0, 255 },
                        opacity = 255
                }
				group:add(backing)
				backing:lower_to_bottom()
--]]
        end,
        ["FULLSCREEN"] = function(img,group)
                group.opacity = 0
                group.z_rotation = {0,img.w/2,img.h/2}
                group.anchor_point = {img.w/2,img.h/2}
                group.z = 0
                group.x = screen.w/2
                group.y = screen.h/2
                if screen.w/img.w > screen.h/img.h then
                    group.scale = {screen.h/img.h,screen.h/img.h}
                else
                    group.scale = {screen.w/img.w,screen.w/img.w}
                end

                group:add(img)
        end,
        ["LAYERED"]    = function(img,group)
                group.anchor_point = {0,0}
                group.position     = {0,0}
                group.z            = 0
                group.scale        = {1,1}
                --group:raise_to_top()

                function counter_rotation(rotation) 
                    if rotation>0 then return 0 -         (rotation)
                    else               return 0 + math.abs(rotation) end
                end
                --if you change these numbers, change their counterparts
                --in on_screen_prep
                if img.size[1]/img.size[2] > screen.w/screen.h then
                    img.size = {screen.w - 200, 
                               (screen.w - 200)/img.w*img.h}
                else
                    img.size = {(screen.h - 100)/img.h*img.w, 
                                 screen.h - 100}
                end

                local number_of_tiles =13
                local tile_width  = img.w/3--+100
                local tile_height = img.h/3--+100
                local turn_margin = 50
                local margin_left = (screen.w - img.w)*0.5
                local margin_top  = (screen.h - img.h)*0.5

                img.opacity  =  0-- 255
--[[
                group.scale = 
                {
                    SLIDESHOW_HEIGHT/img.h,
                    SLIDESHOW_HEIGHT/img.h
                }
--]]
                group:add(img)
                group.position = {margin_left,margin_top}

                --group.anchor_point = {group.w/2,group.h/2}
                --group.position = {screen.w/5,screen.h/4}--screen.w/2,screen.h/2}

                --13 drop_points
                local pre_drop_points = {
                    {(tile_width*0.50) , (tile_height*0.50)},
                    {(tile_width*1.50) , (tile_height*0.50)},
                    {(tile_width*2.50) , (tile_height*0.50)},
                    {(tile_width*0.50) , (tile_height*1.5)},
                    {(tile_width*2.50) , (tile_height*2.5)},
                    {(tile_width*2.50) , (tile_height*1.5)},
                    {(tile_width*0.50) , (tile_height*2.5)},
                    {(tile_width*1.51) , (tile_height*2.5)},
		
                    {(tile_width*1)    ,    (tile_height*1)},
                    {(tile_width*1)    ,    (tile_height*2)},
                    {(tile_width*2)    ,    (tile_height*1)},
                    {(tile_width*2)    ,    (tile_height*2)},
		
                    {(tile_width*1.51) , (tile_height*1.51)},		
                }
                local drop_point = {}
                while #pre_drop_points > 0 do
                    local pos = math.random(1,#pre_drop_points)
                    local ele = table.remove(pre_drop_points, pos)
                    drop_point[#drop_point + 1] = ele
                end
                
                --local image_pieces = {}
                for i = 1,number_of_tiles do
                    local rotation = math.random(-20,20)
                    local image_offset_left = drop_point[i][1]+math.random(-30,30)
                    local image_offset_top  = drop_point[i][2]+math.random(-30,30)
                    local this_group = Group
                    {
                        name = "Clone "..i,
                        clip = 
                        {
                            0,
                            0,
                            tile_width,
                            tile_height
                        },
                        anchor_point = 
                        {
                            tile_width/2,
                            tile_height/2
                        },
                        position = 
                        {
                            image_offset_left, --  tile_width/2,
                            image_offset_top  -- tile_height/2
                        },
                        z_rotation = {rotation,0,0},
                        opacity    = 0,
			
                    }
                    local bounding_box = Rectangle{
                        anchor_point = {
                            (tile_width*0.5),
                            (tile_height*0.5)
                        },
                        position = {
                            (tile_width*0.5),
                            (tile_height*0.5)
                        },
                        size = {
                            tile_width,
                            tile_height
                        },
                        border_color = { 255, 255, 255 },
                        color        = { 255,  0, 0, 0 },
                        border_width=6,
                        opacity = 255
                    }
                    local backing = Rectangle
                    {
                        anchor_point = {
                            (tile_width*0.5),
                            (tile_height*0.5)
                        },
                        position = {
                            (tile_width*0.5),
                            (tile_height*0.5)
                        },
                        size = {
                            tile_width,
                            tile_height
                        },
                        color        = { 0,  0, 0, 255 },
                        opacity = 255
                    }

                    local this_image = Clone{
                        source = img,
                        opacity = 255,
                        size = {
                            tile_width*3,
                            tile_height*3
                        },
                        anchor_point = {
                            image_offset_left,
                            image_offset_top
                        },
			
                        position = {
                            (tile_width  * 0.5),
                            (tile_height * 0.5)
                        },
			
                        z_rotation = {
                            counter_rotation(rotation)
                        },			
                    }
		
                    this_group:add(backing,this_image,bounding_box)
                    if (model.curr_slideshow.ui) then
                        model.curr_slideshow.ui:add(this_group)
                    end
                    --image_pieces[i] = this_group
                    group:add(this_group)
--[[
                    print_r("this_image size:" .. 
                                   this_group.transformed_size[1] .. 
                            "x" .. this_group.transformed_size[2])
--]]
                end
        end,
		["MOSAIC"]    = function(img,group)
				img.scale = {1,1}
				group.scale = {1,1}
				group.size = {0,0}
				group.opacity = 0
				group:clear()
				group.z = 0
				img.z = 0
				if img.children ~= nil  then
                if screen.w/img.w > screen.h/img.h then
                    img.scale = {screen.h/img.h,screen.h/img.h}
                else
                    img.scale = {screen.w/img.w,screen.w/img.w}
                end

				else
					if img.w/img.h > screen.w/screen.h then
						img.size = {screen.w,img.h*(screen.w)/img.w}
					else
						img.size = {(screen.h)/img.h*img.w,screen.h}
					end
				end
				img.opacity = 0
                img.anchor_point = {img.size[1]/2,img.size[2]/2}
                img.position = {screen.w/2,screen.h/2}
				group:add(img)
				local num_rows    = 5
				local num_cols    = 10
---[[ no lines
				local tile_width  = 192--188--185--181
				local tile_height = 216 --214--210--206

				local vert_gutter   = 0--4--8--12
				local horz_gutter   = 0--3--8--12

				local vert_left_gap = 0-- -1 --2-- -1 --1
				local horz_top_gap  = 0-- -1 --1

--]]
--[[ thin lines
				local tile_width  = 188--185--181
				local tile_height = 214--210--206

				local vert_gutter   = 4--8--12
				local horz_gutter   = 3--8--12

				local vert_left_gap =  -1 --2-- -1 --1
				local horz_top_gap  =  -1 --1

--]]
--[[ thicker lines
				local tile_width  = 185--181
				local tile_height = 210--206

				local vert_gutter   = 8--12
				local horz_gutter   = 8--12

				local vert_left_gap =  2 --1
				local horz_top_gap  =  -1 --1

--]]

				for i = 1,num_rows do
					for j = 1, num_cols do
						local xx = (j-1)*(tile_width+vert_gutter)+
							vert_left_gap -- (img.x - img.anchor_point[1])
						local yy = (i-1)*(tile_height+horz_gutter)+
							horz_top_gap -- (img.y - img.anchor_point[2])
						local clone = Clone{
                            name   = "clone "..i..","..j,
                            source = img,
                            opacity = 255,
                            clip = 
                            {
                                xx-(img.x - img.anchor_point[1]),
            	                yy-(img.y - img.anchor_point[2]),
                                tile_width,
                                tile_height
                            },
							position = 
							{
								(img.x - img.anchor_point[1]),
								(img.y - img.anchor_point[2])
							}
                        }
--[[
						local flash = Rectangle
						{
							name  = "flash "..i..","..j,
							color = "FFFFFF0F",
							size  = {	tile_width,
                            		    tile_height},
							position = { 	
								(j-1)*(tile_width+vert_gutter)+ vert_left_gap,
								(i-1)*(tile_height+horz_gutter)+horz_top_gap
							}
						}
--]]
group:add(clone)--,flash)
					end
				end
		end
    }
    local on_screen_prep =
    {
        ["REGULAR"]    = function(img,group)
			off_screen_prep["REGULAR"](img,group)
--[[
			group:add( Rectangle{
						name = "backing",
                        size = {
                            img.w,
                            img.h
                        },
                        color        = { 0,  0, 0, 255 },
                        opacity = 255
                })
			group:add(img)
			group:add( Rectangle{
						name = "overlay",
                        size = {
                            group.size[1] + 12,
                            group.size[2] + 12 -- 12 = border_width * 2
                        },
                        color        = { 255,  0, 0, 0 },
                        border_color = { 255, 255, 255,255 },

						position = {-6,-6},
                        border_width=6,
                        opacity = 255
                })

--			print("off1",group.w,group.h)
			if group.w/group.h > screen.w/screen.h then
				group.scale = {(screen.w*.9)/group.w,(screen.w*.9)/group.w}
			else
				group.scale = {(screen.h*.9)/group.h,(screen.h*.9)/group.h}
			end
--			print("off2",group.w,group.h,group.size[1],group.size[2])
			group.z_rotation   = { math.random(-10,10), 
									group.size[1]/2,
									group.size[2]/2}

			group.anchor_point = {	group.size[1]/2,
									group.size[2]/2}

			group.position = {	screen.w/2+math.random(-5,5),
								screen.h/2+math.random(-5,5)}

--]]
--[[
				local rotation = math.random(-10,10)
				--target position is {screen.w - 100, screen.h - 100}
				--match the dim which has a greater dist to cover
print(img.size[1]*img.scale[1],img.size[2]*img.scale[2])
				if img.w/img.h > screen.w/screen.h then
					img.scale = {(screen.w*.9)/img.w,(screen.w*.9)/img.w}
				else
					img.scale = {(screen.h*.9)/img.h,(screen.h*.9)/img.h}
				end
				img.anchor_point = {img.size[1]*img.scale[1]/2, img.size[2]*img.scale[2]/2}
				img.position = {img.size[1]*img.scale[1]/2, img.size[2]*img.scale[2]/2}
print(img.size[1]*img.scale[1],img.size[2]*img.scale[2])
                local bounding_box = Rectangle{
						name = "overlay",
                        size = {
                            screen.w*.9 + 12,
                            screen.h*.9 + 12 -- 12 = border_width * 2
                        },
						anchor_point = {(screen.w*.9 + 12)/2,(screen.h*.9 + 12)/2},
                        border_color = { 255, 255, 255 },
                        color        = { 255,  0, 0, 0 },
						position = {screen.w/2,screen.h/2},
                        border_width=6,
                        opacity = 255
                }
				group.size = {screen.w*.9,screen.h*.9}
				--group.z_rotation = {rotation,group.w/2,group.h/2}
				group.anchor_point = {group.w/2,group.h/2}
                group.position = {screen.w/2,screen.h/2}
                local backing = Rectangle
                {
						--position = {screen.w/2,screen.h/2},
						anchor_point = {img.size[1]/2,img.size[2]/2},
                        size = {
                            img.size[1],
                            img.size[2]
                        },
                        color        = { 0,  0, 0, 255 },
                        opacity = 255
                }
				group:add(backing,img,bounding_box)
--]]
--[[
                local overlay = Clone 
                {
                    name   = "overlay",
                    source = overlay_image, 
                    scale  = 
                    {
                        img.w/(screen.w-100),
                        img.h/(screen.h-100)
                    }, 
                    x = (-img.w)/40,
                    y = (-img.h)/20
                }
                group.anchor_point = {0,0}
                group.scale = 
                {
                    SLIDESHOW_HEIGHT/img.h,
                    SLIDESHOW_HEIGHT/img.h
                }
                local i_width = img.w * SLIDESHOW_HEIGHT/img.h
                local i_height = SLIDESHOW_HEIGHT
                print ("original: "..img.w.." WIDTH:"..i_width)
                if (img.w/img.h > 1.5) then
                    group.scale = 
                    {
                        SLIDESHOW_WIDTH/img.w,
                        SLIDESHOW_WIDTH/img.w
                    }
                    i_height = i_height * SLIDESHOW_WIDTH/i_width
                end
                group.x = screen.w/4
                group.y = screen.h/6
                group.z_rotation = 
                {
                    math.random(-10,10), 
                    i_width/2, 
                    i_height/2
                }
                group:add(img,overlay)
                local backing = Rectangle
                {
                        size = {
                            img.size[1],
                            img.size[2]
                        },
                        color        = { 0,  0, 0, 255 },
                        opacity = 255
                }
				group:add(backing)
				backing:lower_to_bottom()
--]]
        end,
        ["FULLSCREEN"] = function(img,group)
                group.opacity = 0
                group.z_rotation = {0,img.w/2,img.h/2}
                group.anchor_point = {img.w/2,img.h/2}
                group.z = 0
                group.x = screen.w/2
                group.y = screen.h/2
                if screen.w/img.w > screen.h/img.h then
                    group.scale = {screen.h/img.h,screen.h/img.h}
                else
                    group.scale = {screen.w/img.w,screen.w/img.w}
                end
                group:add(img)
        end,
        ["LAYERED"]    = function(img,group)
               off_screen_prep["LAYERED"](img,group)
               group.opacity = 255
               group.z = 0
               group:lower_to_bottom()
               background:lower_to_bottom()
               for i = 1, 13 do
                   local child = group:find_child("Clone "..i)
                   child.opacity = 255
               end
        end,
		["MOSAIC"]    = function(img,group)
            off_screen_prep["MOSAIC"](img,group)
        end
    }

    view.set_ui =  
    {
        ["REGULAR"]    = function()
            background.opacity  = 255
mosaic_background.opacity = 0
            --view.logo.opacity   = 255

            for i = 1,#view.on_screen_list do
                local pic = view.on_screen_list[i]:find_child("slide")

                if pic ~= nil then
                    pic.opacity = 255
                pic.z_rotation = {0,0,0}
                pic.scale = {1,1}
                pic.position = {0,0}
				pic.z = 0
pic.anchor_point = {0,0}
				pic.size = {pic.base_size[1], pic.base_size[2]}

                    view.on_screen_list[i]:clear()
                view.on_screen_list[i] = Group {z = 500}

                    on_screen_prep["REGULAR"](pic,view.on_screen_list[i])
                    view.on_screen_list[i].opacity = 255
                    view.ui:add(view.on_screen_list[i])

                    view.on_screen_list[i]:lower_to_bottom()
                    background:lower_to_bottom()
                else
                    error("shit")
                end
            end
            for i = 1,#view.off_screen_list do
                local pic = view.off_screen_list[i]:find_child("slide")
                if pic ~= nil then
                    pic.opacity = 255
                pic.z_rotation = {0,0,0}
                pic.scale = {1,1}
                pic.position = {0,0}
				pic.z = 0
pic.anchor_point = {0,0}
				pic.size = {pic.base_size[1], pic.base_size[2]}

                    view.off_screen_list[i]:clear()
				view.off_screen_list[i] = Group {z = 0}

                    off_screen_prep["REGULAR"](pic,view.off_screen_list[i])
                end
            end
        end,

        ["FULLSCREEN"] = function()
            background.opacity  = 0
mosaic_background.opacity = 0
            --view.logo.opacity   = 0

            for i = 1,#view.on_screen_list do
                    local pic = view.on_screen_list[i]:find_child("slide")
                    local backing =view.on_screen_list[i]:find_child("loading")
                    view.on_screen_list[i]:clear()
                if i == 1 then
                    on_screen_prep["FULLSCREEN"](pic,view.on_screen_list[i])
                else

                    if pic ~= nil then
                        off_screen_prep["FULLSCREEN"](pic,view.on_screen_list[i])
                    elseif backing ~= nil then
                        off_screen_prep["FULLSCREEN"](backing,view.on_screen_list[i])
                    else
                       -- error("should not have got here")
                    end
                end
            end
            if view.on_screen_list[1] ~= nil then
                view.on_screen_list[1].opacity = 255
            end
            for i = 1,#view.off_screen_list do
                local pic = view.off_screen_list[i]:find_child("slide")
                local backing =view.off_screen_list[i]:find_child("loading")
                view.off_screen_list[i]:clear()
                if pic ~= nil then
                    off_screen_prep["FULLSCREEN"](pic,view.off_screen_list[i])
                elseif backing ~= nil then
                    view.off_screen_list[i]:clear()
                    off_screen_prep["FULLSCREEN"](backing,view.off_screen_list[i])
                else
                   -- error("should not have got here")

                end
            end

        end,
        ["LAYERED"]    = function()
            background.opacity  = 255
mosaic_background.opacity = 0
            --view.logo.opacity   = 0

            for i = 1,#view.on_screen_list do
                local pic     = view.on_screen_list[i]:find_child("slide")
                local backing = view.on_screen_list[i]:find_child("loading")
                view.on_screen_list[i]:clear()
                if pic ~= nil then
                    on_screen_prep["LAYERED"](pic,view.on_screen_list[i])
                elseif backing ~= nil then
                    on_screen_prep["LAYERED"](backing,view.on_screen_list[i])
                else
                   -- error("should not have got here")
                end
            end
            if view.on_screen_list[1] ~= nil then
                view.on_screen_list[1].opacity = 255
            end
            for i = 1,#view.off_screen_list do
                local pic     = view.off_screen_list[i]:find_child("slide")
                local backing = view.off_screen_list[i]:find_child("loading")
                view.off_screen_list[i]:clear()
                if pic ~= nil then
                    off_screen_prep["LAYERED"](pic,view.off_screen_list[i])
                elseif backing ~= nil then
                    off_screen_prep["LAYERED"](backing,view.off_screen_list[i])
                else
                    error("should not have got here")

                end
            end


        end,
        ["MOSAIC"] = function()
            background.opacity  = 0
			mosaic_background.opacity = 255
			mosaic_background:lower_to_bottom()
			if layered_timeline ~= nil then
				layered_timeline:stop()
                layered_timeline:on_completed()
				layered_timeline = nil
			end
            --view.logo.opacity   = 0

            for i = 1,#view.on_screen_list do
                local pic = view.on_screen_list[i]:find_child("slide")
                local backing =view.on_screen_list[i]:find_child("loading")
                view.on_screen_list[i]:clear()

                view.on_screen_list[i].z_rotation = {0,0,0}
                view.on_screen_list[i].scale = {1,1}
                view.on_screen_list[i].position = {0,0}
                view.on_screen_list[i].z = 0				
				


                if i == 1 and pic ~= nil then
                pic.z_rotation = {0,0,0}
                pic.scale = {1,1}
                pic.position = {0,0}
				pic.z = 0

                    on_screen_prep["MOSAIC"](pic,view.on_screen_list[i])
                else
                    if pic ~= nil then
                pic.z_rotation = {0,0,0}
                pic.scale = {1,1}
                pic.position = {0,0}
				pic.z = 0

                        off_screen_prep["MOSAIC"](pic,view.on_screen_list[i])
                    elseif backing ~= nil then
                        off_screen_prep["MOSAIC"](backing,view.on_screen_list[i])
                    else
                       -- error("should not have got here")
                    end
                end
            end
            if view.on_screen_list[1] ~= nil then
                view.on_screen_list[1].opacity = 255
            end
            for i = 1,#view.off_screen_list do
                local pic = view.off_screen_list[i]:find_child("slide")
                local backing =view.off_screen_list[i]:find_child("loading")
                view.off_screen_list[i]:clear()

                view.off_screen_list[i].z_rotation = {0,0,0}
                view.off_screen_list[i].scale = {1,1}
                view.off_screen_list[i].position = {0,0}
                view.off_screen_list[i].z = 0				

                if pic ~= nil then

                pic.z_rotation = {0,0,0}
                pic.scale = {1,1}
                pic.position = {0,0}
				pic.z = 0

                    off_screen_prep["MOSAIC"](pic,view.off_screen_list[i])
                elseif backing ~= nil then
                    view.off_screen_list[i]:clear()
                    off_screen_prep["MOSAIC"](backing,view.off_screen_list[i])
                else
                   -- error("should not have got here")

                end
            end
        end


    }
    local layered_timeline = nil
    local forward_animation =
    {
        ["REGULAR"]    = function(pic)

            local end_pos = {pic.position[1],
                             pic.position[2]}

            pic.x = math.random(0,1)*1920
            pic.y = math.random(0,1)*1080

            pic.z = 400

            pic:animate 
            {
                duration = 500,
                --mode     = EASE_IN_EXPO,
                x        = end_pos[1],
                y        = end_pos[2],
                z        = 0,
                on_completed = function()
						license_box:raise_to_top()

                    reset_keys()            
                end
            }

        end,
        ["FULLSCREEN"] = function(pic)
            pic.opacity = 0
			  
            pic:animate 
            {
                duration = 300,
                mode     = EASE_IN_EXPO,
                opacity  = 255,
                on_completed = function()
                    reset_keys()
						license_box:raise_to_top()

                end
            }
            if view.on_screen_list[2] ~= nil  then
                view.on_screen_list[2]:animate
                {
                    duration = 200,
                    opacity  = 0,
                    mode     = EASE_IN_EXPO
                }
            end
        end,
        ["LAYERED"]    = function(pic)
                if layered_timeline ~= nil then
					layered_timeline:stop()
                    layered_timeline:on_completed()
					layered_timeline = nil
                end
                layered_timeline = Timeline
                {
                    name      = "Backward Layered Timeline",
                    duration  = 13*300,
                    loop      = false,
                    direction = "FORWARD"
                }
                local drop_points = {}
                pic.z = 0
                function layered_timeline.on_started()
                    pic.opacity = 255
                    pic:raise_to_top()
                    for i = 1, 13 do
                        local child = pic:find_child("Clone "..i)
                        drop_points[i]    = {}
                        drop_points[i][1] = child.x
                        drop_points[i][2] = child.y
                        print(drop_points[i][1], drop_points[i][2])
                        child.position = {pic.w/2,-pic.h/2}
                        child.z        = 500
                        child.opacity  = 255
                    end
                end
                function layered_timeline.on_new_frame(t,msecs)
                    local index    =  math.ceil(msecs/300)
                    local progress = (msecs - 300*(index-1))/300
                    for i = 1,index-1 do
                        local child    = pic:find_child("Clone "..i)
                        child.position = {drop_points[i][1],
                                          drop_points[i][2]}
                        child.scale    = { 1 , 1 }
                        child.z        = 0
                    end
                    local child = pic:find_child("Clone "..index)
					--if child ~= nil then
                    	--print(index)--drop_points[i][1])
                	    child.x = pic.w/2 + progress*(
            	                     drop_points[index][1] - pic.w/2)
        	            child.y = pic.h/2 + progress*(
    	                             drop_points[index][2] - pic.h/2)
	                    child.scale = {2-progress,2-progress}
                    	child.z     = (1-progress)*500             
					--end
--[[
                    if msecs > 500 then
                        reset_keys()
                    end       
--]]
                end
                function layered_timeline.on_completed()
                    for i = 1, 13 do
                        local child    = pic:find_child("Clone "..i)
                        child.position = {drop_points[i][1],
                                          drop_points[i][2]}
                        child.scale    = {1,1}
                        child.z        = 0
                    end

                    reset_keys()
						license_box:raise_to_top()

                end
                layered_timeline:start()
        end,
        ["MOSAIC"] = function(pic)
            pic.opacity = 255
--[[
			for i = 1,5 do
				for j = 1,10 do
					local 
				end
			end 
--]]
local mosaic_timeline = Timeline
{
	duration = 200*(5+10),
	loop     = false,
	forward  = "FORWARD"
}
local old = view.on_screen_list[2]
function mosaic_timeline.on_started()

			for i = 1,5 do
				for j = 1,10 do
					local child = pic:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {-180,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 0
--[[
					child = pic:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {-180,child.w/2,0}
					child.opacity = 0
--]]
				end
			end 
		if old ~= nil then
			for i = 1,5 do
				for j = 1,10 do
					local child = old:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {0,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 255

--[[
					child = pic:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {-180,child.w/2,0}
					child.opacity = 15
--]]
				end
			end 
		end

end
function mosaic_timeline.on_new_frame(t,msecs)
				local stage_i = math.ceil(msecs / 200) --stages 1-15
				
				local p = (msecs - (stage_i-1)*200) / 200  --progress w/in a stage
print(stage_i,p)
				for i = 1,5 do
					for j = 1,10 do
						if (i+j-1)  == stage_i then
							local child = pic:find_child("clone "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {-180 + 90*(p),child.clip[1]+child.clip[3]/2,0}
							if (-180 + 90*(p)) > -135 and (-180 + 90*(p)) < -45 then
								child.opacity = 255 * ((-180 + 90*(p)) - 45)/90
							elseif (-180 + 90*(p)) > -45 then
								child.opacity = 255
							end
--[[
							child = pic:find_child("flash "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {-180 + 90*(p),child.w/2,0}
							if (-180 + 90*(p)) > -135 and (-180 + 90*(p)) < -45 then
								child.opacity = 15 * ((-180 + 90*(p)) - 45)/90
							elseif (-180 + 90*(p)) > -45 then
								child.opacity = 15
							end
--]]
							if old ~= nil then
								child = old:find_child("clone "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90*(p),child.clip[1]+child.clip[3]/2,0}
								if (90 * (p)) < 135 and (90 * (p)) > 45 then
									child.opacity = 255 * (1-((90 * (p)) - 45)/90)
								elseif (90 * (p)) > 135 then
									child.opacity = 0
								end
--[[
								child = old:find_child("flash "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90*(p),child.w/2,0}
								if (90 * (p)) < 135 and (90 * (p)) > 45 then
									child.opacity = 15 * (1-((90 * (p)) - 45)/90)
								elseif (90 * (p)) > 135 then
									child.opacity = 0
								end
--]]
							end
						elseif (i+j-1)  == stage_i - 1 then
							local child = pic:find_child("clone "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {-90*(1-p),child.clip[1]+child.clip[3]/2,0}
							if (-90 * (1-p)) > -135 and (-90 * (1-p)) < -45 then
								child.opacity = 255 * ((-90 * (1-p)) - 45)/90
							elseif (-90 * (1-p)) > -45 then
								child.opacity = 255
							end
--[[
							child = pic:find_child("flash "..i..","..j)
							child.y_rotation = {-90*(1-p),child.w/2,0}

							assert(child,"... what?")
							if (-90 * (1-p)) > -135 and (-90 * (1-p)) < -45 then
								child.opacity = 15 * ((-90 * (1-p)) - 45)/90
							elseif (-90 * (1-p)) > -45 then
								child.opacity = 15
							end
--]]
							if old ~= nil then
								child = old:find_child("clone "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90+90*(p),child.clip[1]+child.clip[3]/2,0}
								if (90 +90* (p)) < 135 and (90 +90* (p)) > 45 then
									child.opacity = 255 * (1-((90+90 * (p)) - 45)/90)
								elseif (90+90 * (p)) > 135 then
									child.opacity = 0
								end
--[[
								child = old:find_child("flash "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90+90*(p),child.w/2,0}
								if (90 +90* (p)) < 135 and (90 +90* (p)) > 45 then
									child.opacity = 15 * (1-((90+90 * (p)) - 45)/90)
								elseif (90+90 * (p)) > 135 then
									child.opacity = 0
								end
--]]
							end

						elseif (i+j-1) < stage_i - 1 then
							local child = pic:find_child("clone "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {0,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
							child.opacity = 255
--[[
							child = pic:find_child("flash "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {0,child.w/2,0}
							child.opacity = 15
--]]
							if old ~= nil then

								local child = old:find_child("clone "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {180,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
								child.opacity = 0
--[[
								child = old:find_child("flash "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {180,child.w/2,0}
								child.opacity = 0
--]]
							end
						end
					end
				end

end
function mosaic_timeline.on_completed()
			for i = 1,5 do
				for j = 1,10 do
					local child = pic:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {0,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 255
--[[
	 				child = pic:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {0,child.w/2,0}
					child.opacity = 15
child:raise_to_top()
--]]
						license_box:raise_to_top()

				end
			end 
reset_keys()

		if old ~= nil then
			for i = 1,5 do
				for j = 1,10 do
					local child = old:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {180,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 0
--[[
					child = old:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {180,child.w/2,0}
					child.opacity = 0
--]]
				end
			end 
old.opacity = 0

		end
end

mosaic_timeline:start()
--[[
            pic:animate 
            {
                duration = 300,
                mode     = EASE_IN_EXPO,
                opacity  = 255,
                on_completed = function()
                    reset_keys()
                end
            }
            if view.on_screen_list[2] ~= nil  then
                view.on_screen_list[2]:animate
                {
                    duration = 200,
                    opacity  = 0,
                    mode     = EASE_IN_EXPO
                }
            end
--]]
        end


    }

    local backward_animation =
    {
        ["REGULAR"]    = function(pic)
            local end_pos = {pic.position[1],
                             pic.position[2]}
            pic:animate 
            {
                duration = 500,
                --mode     = EASE_IN_EXPO,
                x        = math.random(0,1)*1920,
                y        = math.random(0,1)*1080,
                z        = 500,
                --garbage collection
                on_completed = function()
                    pic.x = end_pos[1]
                    pic.y = end_pos[2]
                    view.ui:remove(pic)
                    reset_keys()            

--[[handled in a different function

                    if #off_screen_list > 6 then
                        print("removing from off_screen list")
                        off_screen_list[#off_screen_list] = nil
                    end
--]]
						license_box:raise_to_top()

                 end
            }
        end,
        ["FULLSCREEN"] = function(pic)
            pic:animate 
            {
                duration = 200,
                mode     = EASE_IN_EXPO,
                opacity  = 0,
                --garbage collection
                on_completed = function()
                    z = 500
                    view.ui:remove(pic)
--[[ handled in a different function

                    if #off_screen_list > 6 then
                        print("removing from off_screen list")
                        off_screen_list[#off_screen_list] = nil
                    end
--]]
						license_box:raise_to_top()

                end
            }
            view.ui:add(view.on_screen_list[1])
            view.on_screen_list[1]:animate 
            {
                duration = 300,
                opacity = 255,
                mode = EASE_IN_EXPO,
                on_completed = function()
                    reset_keys()            
                end
            }
        end,
        ["LAYERED"]    = function(pic)
                if layered_timeline ~= nil then
					layered_timeline:stop()
                    layered_timeline:on_completed()
					layered_timeline = nil
                end
                layered_timeline = Timeline
                {
                    name      = "Forward Layered Timeline",
                    duration  = 13*300,
                    loop      = false,
                    direction = "FORWARD"
                }

                local drop_points = {}
                pic.z = 0

                function layered_timeline.on_started()
                    for i = 1, 13 do
                        local child = pic:find_child("Clone "..i)
                        drop_points[i]    = {}
                        drop_points[i][1] = child.x
                        drop_points[i][2] = child.y
                        print(drop_points[i][1], drop_points[i][2])
--[[
                        child.position = {pic.w/2,-pic.h/2}
                        child.z        = 500
                        child.opacity  = 255
--]]
                    end
                end
                function layered_timeline.on_new_frame(t,msecs)
                    local index    =  math.ceil(msecs/300)
                    local progress = (msecs - 300*(index-1))/300
                    for i = 1,index-1 do
                        local child    = pic:find_child("Clone "..i)
                        child.position = {pic.w/2,-pic.h/2}
                        child.scale    = { 2 , 2 }
                        child.z        = 500
                    end
                    local child = pic:find_child("Clone "..index)
                    --print(index)--drop_points[i][1])
                    child.x = drop_points[index][1] + progress*(pic.w/2 - 
                                 drop_points[index][1])
                    child.y = drop_points[index][2] + progress*(pic.h/2 - 
                                 drop_points[index][2])
                    child.scale = {1+progress,1+progress}
                    child.z     = progress*500            
					if msecs > 500 then
                    	reset_keys()
					end        
                end
                function layered_timeline.on_completed()
                    pic.opacity = 0
                    for i = 1, 13 do
print(i)
                        local child    = pic:find_child("Clone "..i)
                        child.position = {drop_points[i][1],
                                          drop_points[i][2]}
                        child.scale    = { 2 , 2 }
                        child.z        = 500
                    end
						license_box:raise_to_top()

                end
                layered_timeline:start()
        end,
        ["MOSAIC"] = function(pic)
            pic.opacity = 255
--[[
			for i = 1,5 do
				for j = 1,10 do
					local 
				end
			end 
--]]
local mosaic_timeline = Timeline
{
	duration = 200*(5+10),
	loop     = false,
	forward  = "FORWARD"
}
local old = pic
            view.ui:add(view.on_screen_list[1])

pic = view.on_screen_list[1]
pic.opacity = 255
function mosaic_timeline.on_started()

			for i = 1,5 do
				for j = 1,10 do
					local child = pic:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {-180,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 0
--[[
					child = pic:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {-180,child.w/2,0}
					child.opacity = 0
--]]
				end
			end 
		if old ~= nil then
			for i = 1,5 do
				for j = 1,10 do
					local child = old:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {0,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 255

--[[
					child = pic:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {-180,child.w/2,0}
					child.opacity = 15
--]]
				end
			end 
		end

end
function mosaic_timeline.on_new_frame(t,msecs)
				local stage_i = math.ceil(msecs / 200) --stages 1-15
				
				local p = (msecs - (stage_i-1)*200) / 200  --progress w/in a stage
print(stage_i,p)
				for i = 1,5 do
					for j = 1,10 do
						if (i+j-1)  == stage_i then
							local child = pic:find_child("clone "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {-180 + 90*(p),child.clip[1]+child.clip[3]/2,0}
							if (-180 + 90*(p)) > -135 and (-180 + 90*(p)) < -45 then
								child.opacity = 255 * ((-180 + 90*(p)) - 45)/90
							elseif (-180 + 90*(p)) > -45 then
								child.opacity = 255
							end
--[[
							child = pic:find_child("flash "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {-180 + 90*(p),child.w/2,0}
							if (-180 + 90*(p)) > -135 and (-180 + 90*(p)) < -45 then
								child.opacity = 15 * ((-180 + 90*(p)) - 45)/90
							elseif (-180 + 90*(p)) > -45 then
								child.opacity = 15
							end
--]]
							if old ~= nil then
								child = old:find_child("clone "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90*(p),child.clip[1]+child.clip[3]/2,0}
								if (90 * (p)) < 135 and (90 * (p)) > 45 then
									child.opacity = 255 * (1-((90 * (p)) - 45)/90)
								elseif (90 * (p)) > 135 then
									child.opacity = 0
								end
--[[
								child = old:find_child("flash "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90*(p),child.w/2,0}
								if (90 * (p)) < 135 and (90 * (p)) > 45 then
									child.opacity = 15 * (1-((90 * (p)) - 45)/90)
								elseif (90 * (p)) > 135 then
									child.opacity = 0
								end
--]]
							end
						elseif (i+j-1)  == stage_i - 1 then
							local child = pic:find_child("clone "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {-90*(1-p),child.clip[1]+child.clip[3]/2,0}
							if (-90 * (1-p)) > -135 and (-90 * (1-p)) < -45 then
								child.opacity = 255 * ((-90 * (1-p)) - 45)/90
							elseif (-90 * (1-p)) > -45 then
								child.opacity = 255
							end
--[[
							child = pic:find_child("flash "..i..","..j)
							child.y_rotation = {-90*(1-p),child.w/2,0}

							assert(child,"... what?")
							if (-90 * (1-p)) > -135 and (-90 * (1-p)) < -45 then
								child.opacity = 15 * ((-90 * (1-p)) - 45)/90
							elseif (-90 * (1-p)) > -45 then
								child.opacity = 15
							end
--]]
							if old ~= nil then
								child = old:find_child("clone "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90+90*(p),child.clip[1]+child.clip[3]/2,0}
								if (90 +90* (p)) < 135 and (90 +90* (p)) > 45 then
									child.opacity = 255 * (1-((90+90 * (p)) - 45)/90)
								elseif (90+90 * (p)) > 135 then
									child.opacity = 0
								end
--[[
								child = old:find_child("flash "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {90+90*(p),child.w/2,0}
								if (90 +90* (p)) < 135 and (90 +90* (p)) > 45 then
									child.opacity = 15 * (1-((90+90 * (p)) - 45)/90)
								elseif (90+90 * (p)) > 135 then
									child.opacity = 0
								end
--]]
							end

						elseif (i+j-1) < stage_i - 1 then
							local child = pic:find_child("clone "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {0,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
							child.opacity = 255
--[[
							child = pic:find_child("flash "..i..","..j)
							assert(child,"... what?")
							child.y_rotation = {0,child.w/2,0}
							child.opacity = 15
--]]
							if old ~= nil then

								local child = old:find_child("clone "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {180,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
								child.opacity = 0
--[[
								child = old:find_child("flash "..i..","..j)
								assert(child,"... what?")
								child.y_rotation = {180,child.w/2,0}
								child.opacity = 0
--]]
							end
						end
					end
				end

end
function mosaic_timeline.on_completed()
			for i = 1,5 do
				for j = 1,10 do
					local child = pic:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {0,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 255
--[[
	 				child = pic:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {0,child.w/2,0}
					child.opacity = 15
child:raise_to_top()
--]]
				end
			end 
reset_keys()

		if old ~= nil then
			for i = 1,5 do
				for j = 1,10 do
					local child = old:find_child("clone "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {180,--[[child.x+]]child.clip[1]+child.clip[3]/2,0}
					child.opacity = 0
--[[
					child = old:find_child("flash "..i..","..j)
					assert(child,"... what?")
					child.y_rotation = {180,child.w/2,0}
					child.opacity = 0
--]]
				end
			end 
old.opacity = 0

		end
						license_box:raise_to_top()

end

mosaic_timeline:start()
--[[
            pic:animate 
            {
                duration = 300,
                mode     = EASE_IN_EXPO,
                opacity  = 255,
                on_completed = function()
                    reset_keys()
                end
            }
            if view.on_screen_list[2] ~= nil  then
                view.on_screen_list[2]:animate
                {
                    duration = 200,
                    opacity  = 0,
                    mode     = EASE_IN_EXPO
                }
            end
--]]
        end

    }

    function view:initialize()
        self:set_controller(SlideshowController(self))
    end

    function view:preload_front()
        view.off_screen_list[#view.off_screen_list+1] = Group {z = 500}
        view.license_off[#view.license_off+1] = Text
		{
			text = "",
			font = "Sans 18px",
			color = "FFFFFF",
		}

        local group = view.off_screen_list[#view.off_screen_list]
		local license = view.license_off[#view.license_off]

        local style_i = view:get_controller():get_style_index()
--[[
        local clone = Clone
        {
            name   = "slide",
            source = backup,
        }
--]]
        local clone = Group{name="loading"}
        local timeline  = loading(clone)
        off_screen_prep[view.styles[style_i] ](clone,group)

        local index = view:get_controller():get_photo_index() - 1 +
                                          #view.off_screen_list
--[[
        print("preload front",index,adapters[#adapters -
                model.fp_1D_index + 1][1].required_inputs.query)
--]]
        --local callback = function(url)
        local attempt = 1
        local function load_pic(timeline,group,attempt)
            attempt = attempt + 1
	        local photo_i    = view:get_controller():get_photo_index()

			local pic     
			pic, license.text = sources[model.fp_1D_index]:get_photos_at(
								index,false)
			if pic == nil or attempt == 5 or index < photo_i - 5 then
				
				return
			end
            if pic == "" then
                if group ~= nil then
                    local timeout = Timer{ interval = 4000 }

                    function timeout:on_timer()
			    --	print("trying again",index, pic)

                        timeout:stop()
                        load_pic(timeline,group,attempt)
                    end

                    timeout:start()
                end
                return
            end
            local image = Image{
                name      = "slide",
                src       = pic,
                async     = true, 
                on_loaded = function(img,failed)
                    img.on_loaded = nil

                    --if it failed to load from the internet, then
                    --throw up the placeholder
                    local style_i2 = view:get_controller():get_style_index()
                    if failed then
                        print("picture loading failed")
                        --loaded the placeholder for failed pics
                        local placeholder = Group{}
                        placeholder:add(Rectangle
                        {
                            name   = "backing",
                            color  = "000000",
                            width  = PIC_W,
                            height = PIC_H 
                        })

                        placeholder:add(Clone
                        {
                            name   = "slide",
                            source = backup,
                            x      = 100,
                            y      = 100
                        })
                        on_screen_prep[view.styles[style_i2] ](placeholder,group)
                    else
                        --view.on_screen_list[rel_i] = Group {z = 500}
                        timeline:stop()
                        group:clear()
                        on_screen_prep[view.styles[style_i2] ](img,group)
                    end
                    if group == view.on_screen_list[1] then
                        group.opacity = 255
                    end
                end
            }
        end
        load_pic(timeline,group,attempt)
        --end
        --sources[model.fp_1D_index]:get_interesting_photos(index,false,callback)
--[[
        local request = URLRequest
        {
            url = adapters[#adapters - model.fp_1D_index + 1][1].photos(
                      adapters[#adapters - model.fp_1D_index + 
                                   1][1].required_inputs.query,
                      index,
                      model.fp_1D_index
                  ),
            on_complete = function (request, response)

                local data   = json:parse(response.body)
                local site   = adapters[#adapters - model.fp_1D_index + 
                                                  1][1].site(data, index)
                caption.text = adapters[#adapters - model.fp_1D_index + 
                                                      1][1].caption(data)
                print("getting image",site)
                if site ~= "" then    
                    local image = Image{
                        name      = "slide",
                        src       = site, 
                        async     = true, 
                        on_loaded = function(img,failed)
                            img.on_loaded = nil

                            --if it failed to load from the internet, then
                            --throw up the placeholder
                            local style_i2 = view:get_controller():get_style_index()
                            if failed then
                                print("picture loading failed")
                                --loaded the placeholder for failed pics
                                local placeholder = Group{}
                                placeholder:add(Rectangle
                                {
                                    name   = "backing",
                                    color  = "000000",
                                    width  = PIC_W,
                                    height = PIC_H 
                                })

                                placeholder:add(Clone
                                {
                                    name   = "slide",
                                    source = backup,
                                    x      = 100,
                                    y      = 100
                                })
                                on_screen_prep[view.styles[style_i2] ](placeholder,group)
                            else
                                --view.on_screen_list[rel_i] = Group {z = 500}
                                timeline:stop()
                                group:clear()
                                on_screen_prep[view.styles[style_i2] ](img,group)

                            end
                            if group == view.on_screen_list[1] then
                                group.opacity = 255
                            end
                        end
                    } 
                else
                    print("url loading failed")
                    local style_i2 = view:get_controller():get_style_index()
                    --loaded the placeholder for failed pics
                    local placeholder = Group{}
                    placeholder:add(Rectangle
                    {
                        name   = "backing",
                        color  = "000000",
                        width  = PIC_W,
                        height = PIC_H 
                    })

                    placeholder:add(Clone
                    {
                        name   = "slide",
                        source = backup,
                        x      = 100,
                        y      = 100
                    })
                    on_screen_prep[view.styles[style_i2] ](placeholder,group)
                    if group == view.on_screen_list[1] then
                        group.opacity = 255
                    end
                end
            end
        }
        request:send()
--]]
    end
    function view:preload_back()
        view.on_screen_list[#view.on_screen_list+1] = Group {z = 0}
        view.license_on[#view.license_on+1] = Text
		{
			text = "",
			font = "Sans 18px",
			color = "FFFFFF",
		}

        local group = view.on_screen_list[#view.on_screen_list]
		local license = view.license_on[#view.license_on]
        view.ui:add(group)
        group:lower_to_bottom()
        background:lower_to_bottom()

        local style_i = view:get_controller():get_style_index()
--[[
        local clone = Clone
        {
            name   = "slide",
            source = backup,
        }
--]]
        local clone = Group{name="loading"}
        local timeline = loading(clone)
        on_screen_prep[view.styles[style_i] ](clone,group)
        local index = view:get_controller():get_photo_index()  -
                                                  #view.on_screen_list + 2
        print("preload back",index)
        local function load_pic(timeline,group)

        --local callback = function(url)
			local pic     
			pic, license.text = sources[model.fp_1D_index]:get_photos_at(
								index,false)
            if pic == "" then
                local timeout = Timer{ interval = 4000 }

                function timeout:on_timer()
                    timeout:stop()
                    load_pic(timeline,group)
                end

                timeout:start()
                return
            end

            local image = Image{
                name      = "slide",
				src       = pic,
                async     = true, 
                on_loaded = function(img,failed)
                    img.on_loaded = nil

                    if failed then
                        --loaded the placeholder for failed pics
                        local placeholder = Group{}
                        placeholder:add(Rectangle
                        {
                            name   = "backing",
                            color  = "000000",
                            width  = PIC_W,
                            height = PIC_H 
                        })

                        placeholder:add(Clone
                        {
                            name   = "slide",
                            source = backup,
                            x      = 50,
                            y      = 50
                        })
                        on_screen_prep[view.styles[style_i] ](placeholder,group)
                    else
                        --view.on_screen_list[rel_i] = Group {z = 500}
                        timeline:stop()
                        group:clear()
                        on_screen_prep[view.styles[style_i] ](img,group)
                        --if its the desk/slideshow, then need to
                        --put it at the bottom of the stack
                    end
                    if group == view.on_screen_list[1] then
                        group.opacity = 255
                    end
                end
            }
        end
        load_pic(timeline,group)


        --sources[model.fp_1D_index]:get_interesting_photos(index,false,callback)

--[[
        local request = URLRequest
        {
            url = adapters[#adapters - model.fp_1D_index + 1][1].photos(
                  adapters[#adapters - model.fp_1D_index + 1][1].required_inputs.query,
                           index,
                           model.fp_1D_index
                  ),
            on_complete = function (request, response)

                local data   = json:parse(response.body)
                local site   = adapters[#adapters - model.fp_1D_index + 1][1].site(data,index)
                caption.text = adapters[#adapters - model.fp_1D_index + 1][1].caption(data)


                local photo_i = view:get_controller():get_photo_index()
                local style_i = view:get_controller():get_style_index()

                --recalculate the relative index
                --in case the user moved while it was loading
                local rel_i = -1*( index + 1 - photo_i )
                
                --self:LoadImage(site,view.on_screen_list,updated_index)
                print("getting image",site)
                if site ~= "" then
                    local image = Image{
                        name      = "slide",
                        src       = site, 
                        async     = true, 
                        on_loaded = function(img,failed)
                            img.on_loaded = nil

                            if failed then
                                --loaded the placeholder for failed pics
                                local placeholder = Group{}
                                placeholder:add(Rectangle
                                {
                                    name   = "backing",
                                    color  = "000000",
                                    width  = PIC_W,
                                    height = PIC_H 
                                })

                                placeholder:add(Clone
                                {
                                    name   = "slide",
                                    source = backup,
                                    x      = 50,
                                    y      = 50
                                })
                                on_screen_prep[view.styles[style_i] ](placeholder,group)
                            else
                                --view.on_screen_list[rel_i] = Group {z = 500}
                                timeline:stop()
                                group:clear()
                                on_screen_prep[view.styles[style_i] ](img,group)
                                --if its the desk/slideshow, then need to
                                --put it at the bottom of the stack
                            end
                            if group == view.on_screen_list[1] then
                                group.opacity = 255
                            end
                        end
                    } 
                else
                    print("url loading failed")
                    local style_i2 = view:get_controller():get_style_index()
                    --loaded the placeholder for failed pics
                    local placeholder = Group{}
                    placeholder:add(Rectangle
                    {
                        name   = "backing",
                        color  = "000000",
                        width  = PIC_W,
                        height = PIC_H 
                    })

                    placeholder:add(Clone
                    {
                        name   = "slide",
                        source = backup,
                        x      = 100,
                        y      = 100
                    })
                    on_screen_prep[view.styles[style_i2] ](placeholder,group)
                    if group == view.on_screen_list[1] then
                        group.opacity = 255
                    end
                end
            end
        }
        request:send()
--]]
    end
    function view:toggle_timer()    
        if view.timer_is_running then
            view.timer:stop()
            view.timer_is_running = false
        else
            view.timer:start()
            view.timer_is_running = true
        end
        reset_keys()            
    end  
    function view.timer.on_timer(timer)
        local photo_i = view:get_controller():get_photo_index()+1
	print("tick "..photo_i)
        view:get_controller():on_key_down(keys.Right)
    end

    function view:nav_on_focus()
--[[
        view.nav_group:raise_to_top()
        view.nav_group:animate
        { 
            duration = 200,
            opacity  = 255,
            on_completed = function()
                reset_keys()
            end
        }
--]]
		local t = Timeline
		{
			duration = 200,
			loop = false,
			direction = "FORWARD"
		}
		local old_x  = -250
		local targ_x = 10
		function t.on_new_frame(t,msecs)
			postit.x = old_x + msecs/t.duration * (targ_x - old_x)
		end
		function t.on_completed()
			postit.x = targ_x
			reset_keys()
		end
		t:start()
    end
    function view:nav_out_focus()
        view.nav_group:animate
        { 
            duration = 200,
            opacity  = 0,
            on_completed = function()
                reset_keys()
            end
        }
    end
    view.prev_i = -1

    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local photo_i    = controller:get_photo_index()
        local style_i    = controller:get_style_index()
        local menu_i     = controller:get_menu_index()
        if comp == Components.SLIDE_SHOW  then
            print("\n\nShowing SlideshowView UI")
            view.ui:raise_to_top()
            view.ui.opacity = 255
            for i = 1 , #view.nav_items do
                if menu_i == i then
                    view.nav_items[i].color = "FF0000"
                else
                    view.nav_items[i].color = "000000"                    
                end
            end
            --if moving backwards
            if photo_i - view.prev_i < 0 then
                if #view.on_screen_list > 1 then
                    print("moving backward")
                    --grab the pic underneath the current one
                    local pic = table.remove(view.on_screen_list, 1 )
                    table.insert(view.off_screen_list, 1 ,pic)
                    local license = table.remove(view.license_on, 1 )
                    table.insert(view.license_off, 1 ,license)
					if license ~= nil then
						license:unparent()
					end
					if view.license_on[1] ~= nil then
						license_box:add(view.license_on[1])
						license_box:raise_to_top()
					end

                    if #view.off_screen_list > 5 then
                        print("removing from off_screen list")
                        if view.off_screen_list[#view.off_screen_list] ~= 
                           nil and
                           view.off_screen_list[#view.off_screen_list
                           ].parent ~= nil then
                            view.off_screen_list[#view.off_screen_list]:unparent()
                        end
                        view.off_screen_list[#view.off_screen_list]=nil
                    end

                    pic:complete_animation()
                
                    backward_animation[view.styles[style_i]](pic)
                else
                    print("on screen is 0")
                end
            --if moving forwards
            elseif photo_i - view.prev_i > 0 then
                if #view.off_screen_list > 0 then
                   print("moving forward")
                   --grab the picture

                   local pic = table.remove( view.off_screen_list,1 )
                   table.insert( view.on_screen_list,  1, pic )
                   local license = table.remove( view.license_off,1 )
                   table.insert( view.license_on,  1, license )
					if view.license_on[2] ~= nil then
						view.license_on[2]:unparent()
					end
					if license ~= nil then
						license_box:add(license)
						license_box:raise_to_top()

					end
                   if #view.on_screen_list > 5 then
                       print("removing from on_screen list")
            
                       if view.on_screen_list[#view.on_screen_list] ~= nil and
                          view.on_screen_list[#view.on_screen_list].parent ~= nil
                                                                            then
                           view.on_screen_list[#view.on_screen_list]:unparent()
                       end

                       view.on_screen_list[#view.on_screen_list]=nil
                   end
					if #view.license_on >5 then
						view.license_on[#view.license_on] = nil
					end

                   --add it to the screen and end its previous animation
                   self.ui:add(pic)
                   pic:complete_animation()
                   pic.opacity = 255

                   forward_animation[view.styles[style_i]](pic)

                else
                    print("off screen is 0")
                end
            else
                print("diff is 0?\tphoto_i:",photo_i,"prev_i",view.prev_i)
                reset_keys()
            end
            view.prev_i = photo_i
            print("\n\nresultant state is\t\tquery index:",
                  model.fp_1D_index,"photo index:",photo_i,"on screen:",
                  #view.on_screen_list,"off_screen:",#view.off_screen_list,
                  "\n")
        else
            print("Hiding SlideshowView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)


