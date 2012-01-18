--dofile("Slideshow2.lua")
--print = function() end

Slideshow = {}
SLIDESHOW_WIDTH = 1200
SLIDESHOW_HEIGHT = 800
local timer = Timer()
local timer_running = false
local still_loading = false
timer.interval = 4000
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

    print ("Begin Slide Show")
    self.ui:clear()

    --init values
    started        = true
    current_pic    = 1
    temp_pic       = 0
    timer_running  = true
    timer.interval = 1000
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
    self:preload(5,off_screen_list)
    current_pic = current_pic + 5
end

function Slideshow:preload(num_pics,img_table)
    local start_ind = current_pic
    if img_table == on_screen_list then
        start_ind = start_ind - (#off_screen_list + #on_screen_list+1)
    end
    if start_ind >= 1 then
        for i = start_ind, start_ind + (num_pics-1) do
            print("\n\npreload with",i,"\n")
            model.curr_slideshow:loadUrls(
                adapters[model.curr_slideshow.index][1].photos(search,i,model.curr_slideshow.index),
                img_table, i  
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


        --the 2 items in the Group
    local image 
    image = Image 
    { 
        src   = site, 
        async = true, 
        on_loaded = function(img,failed)

            if failed then
                if img_table == on_screen_table then
                    current_pic = current_pic -1
                else
                    current_pic = current_pic +1
                end
                self:preload(1,img_table)
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
                if img_table[1].parent ~= nil then
                    if (not fullscreen) then
                        self.ui:add(img_table[index])
                        img_table[index]:lower_to_bottom()
                        img_table[index].x        = screen.w/4
                        img_table[index].y        = screen.h/6
                        img_table[index].z        = 0
                        background:lower_to_bottom()
                    else
					  img_table[index].x = screen.w/2
					  img_table[index].y = screen.h/2

                    end
                end

            end
            img.on_loaded = nil
        end
    }	
end

function timer.on_timer(timer)
	print("tick "..current_pic)
	--if still_loading then
        if #off_screen_list > 0 then
                timer.interval = 4000
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
    if #on_screen_list > 1 then
        print("prev\tbefore \ton screen",#on_screen_list,"off_screen",#off_screen_list)

        current_pic   = current_pic -1

        --grab an image off of the off screen table
        assert(  on_screen_list ~= nil, "on screen list is nil"   )
        assert( #on_screen_list > 0,    "on screen list is empty" )

        local pic = table.remove(on_screen_list, 1 )
        table.insert(off_screen_list, 1 ,pic)
        print("prev\tafter \ton screen",#on_screen_list,"off_screen",#off_screen_list)
        --load up another in the preload list
        if #on_screen_list < 6 and current_pic > #on_screen_list  then
            self:preload(1,on_screen_list)
            print("\tpreloaded")
        else
            print("\tnot preloading")
        end

        pic:complete_animation()
 
        --animate it off the screen
        if (not fullscreen) then
            pic:animate 
		     {
		         duration = 400,
		         mode     = EASE_IN_EXPO,
		         x        = (math.random(2)-1)*1920,
		         y        = (math.random(2)-1)*1080,
		         --garbage collection
		         on_completed = function()
		             z = 500
		             self.ui:remove(pic)
		             if #off_screen_list > 6 then
		                 print("removing from off_screen list")
		                 off_screen_list[#off_screen_list] = nil
		             end
		         end
		     }
        else
            pic:animate 
		     {
		         duration = 200,
		         mode     = EASE_IN_EXPO,
		         opacity  = 0,
		         --garbage collection
		         on_completed = function()
		             z = 500
		             self.ui:remove(pic)
		             if #off_screen_list > 6 then
		                 print("removing from off_screen list")
		                 off_screen_list[#off_screen_list] = nil
		             end
		         end
		     }
             self.ui:add(on_screen_list[1])
             on_screen_list[1]:animate {
			  	duration = 1000,
			  	opacity = 255,
		  		mode = EASE_IN_EXPO,
			  }


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
            self:preload(1,off_screen_list)
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
        if (not fullscreen) then
		     pic:animate 
		     {
		         duration = 400,
		         mode     = EASE_IN_EXPO,
		         x        = screen.w/4,--2 - i_width/2,
		         y        = screen.h/6,--2 - i_height/2,
		         z        = 0,
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
			  		duration = 700,
			  		mode = EASE_IN_EXPO,
			  		opacity = 255,
			  		on_completed = function()
		             print("on_completed")
		             if #on_screen_list > 5 then
		                 self.ui:remove(on_screen_list[#on_screen_list])
		                 on_screen_list[#on_screen_list] = nil
		             end
		         end
			  }
                          if on_screen_list[2] ~= nil  then
			      on_screen_list[2]:animate {
			  	  duration = 1000,
			  	  opacity = 0,
		  		  mode = EASE_IN_EXPO,
                              }
                          end
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

