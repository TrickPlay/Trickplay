--print = function() end

Slideshow = {}
SLIDESHOW_WIDTH = 1200
SLIDESHOW_HEIGHT = 800
local timer = Timer()
local timer_running = false
local still_loading = false
timer.interval = 4
current_pic = 1
temp_pic = 0
pic_num = 1
local started = true
local search = "space"
caption = Text {font = "Sans 15px", text = "", x = 1530, y = 400}
local overlay_image = Image { src = "assets/overlay.png", opacity = 0 }
background = Image {src = "assets/background.jpg" }
background2 = Image {src = "assets/background2.png" }
local up = Image {src = "assets/slideshow/NavPause.png", y = -80, x = 30 }
local down = Image {src = "assets/slideshow/NavFull.png", y = 80, x = 30 }
local left = Image {src = "assets/slideshow/NavPrev.png", x = -80 }
local right = Image {src = "assets/slideshow/NavNext.png", x = 140 }
local back = Image {src = "assets/slideshow/NavBack.png" }

local images_album = {
	"http://upload.wikimedia.org/wikipedia/commons/1/1b/Nice-night-view-with-blurred-cars_1200x900.jpg",
	"http://upload.wikimedia.org/wikipedia/commons/9/94/Beautiful_Buns_in_beautiful_string-bikinis.jpg",
	"http://www.crazythemes.com/images/Asian-Girl-Model.jpg"
}

controls = Group{x = 100, y = 900, z =1}
controls:add(up,down,left,right,back)

fullscreen = false
local off_screen_list = {}
local  on_screen_list = {}
logo = Image{opacity = 0}

function Slideshow:new(args)
	local num_pics = args.num_pics
	local urls     = {}
	local images   = {}
	local index    = args.index
	local style    = dofile("slideshows/Photo/slideshow.lua")
	search         = adapters[args.index][1].required_inputs.query
	print ("INDEX: "..args.index)
	print ("SEARCHING: "..search)
	local object = { 
		num_pics = num_pics,
		images   = images,
		index    = index
	}
    setmetatable(object, self)
    self.__index = self
    return object
end

function Slideshow:loadUrls(url,img_table, i)
    local request = URLRequest 
    {
        url = url,
        on_complete = function (request, response)

            local data   = json:parse(response.body)
            site         = adapters[self.index][1].site(data, i)
            caption.text = adapters[self.index][1].caption(data)

            self:LoadImage(site,img_table)
        end
    }
    request:send()
end

-- will control when to load a URL
function Slideshow:begin()

--[[	timer=Timer()
	timer.interval=10
	local counter=1
	function timer.on_timer(timer)
		if counter <= #images_album then
			animate_image_in( images_album[counter] )
		end
		counter = counter + 1
	end
	timer:start()]]
    print ("Begin Slide Show")
    self.ui:clear()

    --init values
    started        = true
    current_pic    = 1
    temp_pic       = 0
    timer_running  = true
    timer.interval = 1
    timer:start()

    --view
    local queryText = Text 
    { 
        text = string.gsub(adapters[self.index][1].required_inputs.query,"%%20"," "),
        font = "Sans 30px",
        x    = 105, 
        y    = 300
    }
    logo = Image 
    { 
        src = adapters[self.index].logoUrl,
        x = 20,
        y = 130,
        size = {300,225}
    }
    self.ui:add( overlay_image, background, background2,
                                caption, queryText, logo, controls )
    --grab 5 pictures
    self:preload(1)
    current_pic = current_pic + 5
end

function Slideshow:preload(num_pics)
    for i = current_pic, current_pic + (num_pics-1) do
        if (adapters[model.curr_slideshow.index]) then
        model.curr_slideshow:loadUrls(
            adapters[model.curr_slideshow.index][1].photos(search,i,model.curr_slideshow.index),
            off_screen_list, i  
        )
        end
    end
end

function Slideshow:stop()
    timer:stop()
    timer_running = false
    started       = false

    if off_screen_list[1] ~= nil then
        off_screen_list[1]:complete_animation()
    end
    if on_screen_list[1] ~= nil then
        on_screen_list[1]:complete_animation()
    end

    on_screen_list  = {}
    off_screen_list = {}
    collectgarbage()
end
-- will send and image across the screen
function Slideshow:LoadImage(site,img_table)
--	print("load")
        --the 2 items in the Group
    local image 
    image = Image 
    { 
        src   = site, 
        async = true, 
        opacity = 0,
        on_loaded = function(img,failed)

            if failed then
                self:preload(1)
            else

                local index = #img_table + 1
                img_table[index] = Group {z = 500}
                local overlay = Clone 
                { 
                    source = overlay_image, 
                    scale  = 
                    {
                        img.w/(screen.w-100),
                        img.h/(screen.h-100)
                    }, 
                    opacity = 0,
                    x = (-img.w)/40,
                    y = (-img.h)/20
                }

                if (not fullscreen) then
		             img_table[index].scale = {SLIDESHOW_HEIGHT/image.h, SLIDESHOW_HEIGHT/image.h}

		             local i_width = img.w * SLIDESHOW_HEIGHT/image.h
		             local i_height = SLIDESHOW_HEIGHT
		             print ("original: "..image.w.." WIDTH:"..i_width)
		             if (img.w/img.h > 1.5) then
		                 img_table[index].scale = 
		                 {
		                     SLIDESHOW_WIDTH/image.w,
		                     SLIDESHOW_WIDTH/image.w
		                 }
		                 i_height = i_height * SLIDESHOW_WIDTH/i_width
		             end
		             img_table[index].x = (math.random(2)-1)*1920
		             img_table[index].y = (math.random(2)-1)*1080
		             img_table[index].z_rotation = {math.floor(math.random(20)-10), i_width/2, i_height/2}
		          else
					  img_table[index].opacity = 0
					  overlay.opacity = 0
					  img_table[index].z_rotation = {0,image.w/2,image.h/2}
					  img_table[index].anchor_point = {image.w/2,image.h/2}
					  img_table[index].z = 0
					  img_table[index].x = screen.w/2
					  img_table[index].y = screen.h/2
 	 	    	 		img_table[index].scale = {1080/image.h,1080/image.h}
		          end
                img_table[index]:add(image,overlay)

            end
            img.on_loaded = nil
        end
    }	
end

function timer.on_timer(timer)
	print("tick "..current_pic)
	--if still_loading then
        if #off_screen_list > 0 then
                timer.interval = 4
		model.curr_slideshow:next_picture()
	end

end

function Slideshow:toggle_timer()
    if timer_running then
        timer:stop()
        timer_running = false
        up.src = "assets/slideshow/NavPlay.png"

    else
        timer:start()
        timer_running = true
        up.src = "assets/slideshow/NavPause.png"
    end
end

function Slideshow:previous_picture()
    if #on_screen_list > 0 then
        print("prev\tbefore \ton screen",#on_screen_list,"off_screen",#off_screen_list)

        current_pic   = current_pic -1

        --grab an image off of the off screen table
        assert(  on_screen_list ~= nil, "on screen list is nil"   )
        assert( #on_screen_list > 0,    "on screen list is empty" )

        local pic = table.remove(on_screen_list, 1 )
        table.insert(off_screen_list, 1 ,pic)
        print("prev\tafter \ton screen",#on_screen_list,"off_screen",#off_screen_list)

        pic:complete_animation()
 
        --animate it off the screen
        if (not fullscreen) then
		     pic:animate 
		     {
		         duration = 200,
		         mode     = EASE_IN_EXPO,
		         x        = (math.random(2)-1)*1920,
		         y        = (math.random(2)-1)*1080,
		         --garbage collection
		         on_completed = function()
		             z = 500
		             self.ui:remove(pic)
	---[[
		             if #off_screen_list > 6 then
		                 print("removing from off_screen list")
		                 off_screen_list[#off_screen_list] = nil
		             end
	--]]
		         end
		     }
		  else
				-- code to go back in full screen
        end
    else
        -- tell the user NO
    end

end

function Slideshow:next_picture()


    print("Slideshow:next_picture()")
    if #off_screen_list > 0 then

        print("\tnext\tbefore \ton screen",#on_screen_list,"off_screen",#off_screen_list)
        current_pic = current_pic +1

        --grab an image off of the off screen table
        assert(  off_screen_list ~= nil, "off screen list is nil"   )
        assert( #off_screen_list > 0,    "off screen list is empty" )
        local pic = table.remove( off_screen_list,1 )
        table.insert( on_screen_list,  1, pic )
        print("\tnext\tafter \ton screen",#on_screen_list,"off_screen",#off_screen_list)
 
        --load up another in the preload list
        if #off_screen_list < 5 then
            self:preload(1)
            print("\tpreloaded")
        else
            print("\tnot preloading")
        end
        --animate it to the screen
        self.ui:add(pic)
        print("\tadded")
        pic:complete_animation()
        print("\tcomp_anim")
        pic.opacity = 255
        print("\tanimate")
        if (site ~=nil and site ~= "") then
	  		  animate_image_in(site)
		  end
        if (not fullscreen) then
		     pic:animate 
		     {
		         duration = 200,
		         mode     = EASE_IN_EXPO,
		         x        = screen.w/4,--2 - i_width/2,
		         y        = screen.h/6,--2 - i_height/2,
		         z        = 0,
		         opacity = 0,
		         --garbage collection
		         on_completed = function()
		             print("on_completed")
		             if #on_screen_list > 5 then
		                 self.ui:remove(on_screen_list[#on_screen_list])
		                 on_screen_list[#on_screen_list] = nil
		             end
		         end
		     }
		  else
			  pic.opacity = 0
			  
			  pic:animate {
			  		duration = 1000,
			  		mode = EASE_IN_EXPO,
			  		opacity = 255,
			  		on_completed = function()
		             print("on_completed")
		             if #on_screen_list > 1 then
		                 self.ui:remove(on_screen_list[#on_screen_list])
		                 on_screen_list[#on_screen_list] = nil
		             end
		         end
			  }
			  on_screen_list[#on_screen_list]:animate {
			  	duration = 1000,
			  	opacity = 0,
		  		mode = EASE_IN_EXPO,
			  }
		  end
    else
        --tell the user no
    end
end

function Slideshow:toggle_fullscreen()
	fullscreen = not fullscreen
	self.ui:remove(on_screen_list[#on_screen_list])
	self:stop()
	self:begin()


	if (fullscreen) then
		background.opacity = 0
		background2.opacity = 0
		logo.opacity = 0
		controls.opacity = 100
	else
		background.opacity = 255
		background2.opacity = 255
		logo.opacity = 255
		controls.opacity = 255
	end
	--this will reset it we should do something better
end

function print_r( message )
	print("\n\nD:\t".. message.. "\n")
end

function showCenter (element)
	local h_line = Rectangle{
		color = "#FFFFFF",
		size = {2,20},
		anchor_point = {1,10},
		position = element.position
	}
	local v_line = Rectangle{
		color = "#FFFFFF",
		size = {20,2},
		anchor_point = {10,1},
		position = element.position
	}
	element.parent:add(h_line,v_line)	
end
function counter_rotation(rotation) 
	if rotation>0 then
		return 0 - (rotation)
	else
		return 0 + math.abs(rotation)
	end
end

local testbox = Rectangle{
	color="#FF0000",
	size={200,100},
	position={50,50},
	opacity=255,
	anchor_point={100,50},
	z_rotation={30}
}



function animate_image_in(source)
	orginal_image = Image{
		src = source,
		async = true,
		opacity = 0,	
	}
if model.curr_slideshow ~= nil then
    model.curr_slideshow.ui:add(orginal_image)
end
screen:show()
orginal_image.on_loaded = function()
	print_r("org_img size:" .. orginal_image.transformed_size[1] .. "x" .. orginal_image.transformed_size[2])		
	local number_of_tiles =13
	local tile_width  = orginal_image.w/3
	local tile_height = orginal_image.h/3
	local turn_margin = 50
	local margin_left = (screen.w - orginal_image.w)*0.5
	local margin_top = (screen.h - orginal_image.h)*0.5
	
	print_r("margin_left: ".. margin_left ..",margin_top: ".. margin_top )
	
	orginal_image.position = {
		margin_left,margin_top
	}



	print_r("Creating the clones")

	local drop_point = {
		{(tile_width*0.60) , (tile_height*0.61)},
		{(tile_width*1.50) , (tile_height*0.61)},
		{(tile_width*2.50) , (tile_height*0.61)},
		{(tile_width*0.60) , (tile_height*1.51)},
		{(tile_width*2.52) , (tile_height*2.52)},
		{(tile_width*2.52) , (tile_height*1.51)},
		{(tile_width*0.60) , (tile_height*2.52)},
		{(tile_width*1.51) , (tile_height*2.52)},
		
		{(tile_width*1) , (tile_height*1)},
		{(tile_width*1) , (tile_height*2)},
		{(tile_width*2) , (tile_height*1)},
		{(tile_width*2) , (tile_height*2)},
		
		{(tile_width*1.51) , (tile_height*1.51)},
		
	}
	local image_pieces = {}
	for i = 1,number_of_tiles do
		local rotation = math.random(-20,20)
		local image_offset_left = drop_point[i][1]+math.random(-30,30)
		local image_offset_top  = drop_point[i][2]+math.random(-30,30)
		local this_group = Group{
		--[[ ]]

			--[[]]
			clip = {
				0,
				0,
				tile_width,
				tile_height
			},
			anchor_point = {
				(tile_width*0.5),
				(tile_height*0.5)
			},
			position = {
				margin_left + image_offset_left,
				margin_top + image_offset_top
			},
			z_rotation = {
				rotation
			},
			opacity = 0,
			
		}
		this_group:set{


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
			border_color= { 255, 255 , 255 },
			color = { 255, 0 , 0, 0 },
			border_width=6,
			opacity = 255
		}

		local this_image = Clone{
			source = orginal_image,
			opacity = 255,
			size = {
				tile_width*4,
				tile_height*4
			},
			anchor_point = {
				image_offset_left,
				image_offset_top
			},
			
			position = {
				(tile_width*0.5),
				(tile_height*0.5)
			},
			
			z_rotation = {
				counter_rotation(rotation)
			},			
		}
		
	this_group:add(this_image,bounding_box)
	if (model.curr_slideshow.ui) then
		model.curr_slideshow.ui:add(this_group)
	end
	table.insert(image_pieces,i,this_group)
	--showCenter(this_group)
	--showCenter(this_image)
	print_r("this_image size:" .. this_group.transformed_size[1] .. "x" .. this_group.transformed_size[2])
	end
	
	timer=Timer()
	timer.interval=0.5
	local counter=1
	function timer.on_timer(timer)
		if counter <= #image_pieces then
			local oldposition 	= image_pieces[counter].position
			local random_rotation = math.random(-30,30)
			image_pieces[counter]:set{
				position = {
					screen.w/2,
					screen.h/2
				},
				--z_rotation = {random_rotation},
				scale = {2,2},
			}
			image_pieces[counter]:animate{
				duration=500,
				position = oldposition,
				opacity = 255,
				z = 0,
				scale = {1,1},
				--z_rotation = {counter_rotation(random_rotation)},
			}
		elseif counter > #image_pieces then
		
		end
		counter = counter + 1
	end
	timer:start()
end
end


