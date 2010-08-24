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
local started = true
local search = "space"
local caption = Text {font = "Sans 15px", text = "", x = 1530, y = 400}
local overlay_image = Image { src = "assets/overlay.png", opacity = 0 }
local background = Image {src = "assets/background.jpg" }
local background2 = Image {src = "assets/background2.png" }

local off_screen_list = {}
local  on_screen_list = {}

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

function Slideshow:loadUrls(url,img_table)
    local request = URLRequest 
    {
        url = url,
        on_complete = function (request, response)

            local data   = json:parse(response.body)
            site         = adapters[self.index][1].site(data)
            caption.text = adapters[self.index][1].caption(data)

            self:LoadImage(site,img_table)
        end
    }
    request:send()
end

-- will control when to load a URL
function Slideshow:begin()

    print ("Begin Slide Show")

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
    local logo = Image 
    { 
        src = adapters[self.index].logoUrl,
        x = 20,
        y = 130,
        z = 1,
        size = {300,225}
    }
    self.ui:add( overlay_image, background, background2,
                                caption, queryText, logo )
    --grab 5 pictures
    self:preload(5)
end

function Slideshow:preload(num_pics)
    for i = current_pic,current_pic + num_pics do
        model.curr_slideshow:loadUrls(
            adapters[model.curr_slideshow.index][1].photos(search,i),
            off_screen_list  
        )
    end
end

function Slideshow:stop()
    timer:stop()
    timer_running = false
    started       = false

    if (self.images[current_pic] ~= nil) then
        self.images[current_pic]:complete_animation()
        self.images = {}
    end
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
                self:preload(1)
            else

        local index = #img_table + 1
        img_table[index] = Group {z = 500}
        local overlay = Clone 
        { 
            source = overlay_image, 
            scale  = 
            {
                image.w/(screen.w-100),
                image.h/(screen.h-100)
            }, 
            x = (-image.w)/40,
            y = (-image.h)/20
        }

        img_table[index].scale = {SLIDESHOW_HEIGHT/image.h, SLIDESHOW_HEIGHT/image.h}

        local i_width = image.w * SLIDESHOW_HEIGHT/image.h
        local i_height = SLIDESHOW_HEIGHT
        print ("original: "..image.w.." WIDTH:"..i_width)
        if (image.w/image.h > 1.5) then
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
        img_table[index]:add(image,overlay)
            end
        end
    }

        --self.ui:add(self.images[temp])
--[[
        img_table[index]:animate 
        {
            duration = 1000,
            mode     = EASE_IN_EXPO,
            x        = screen.w/2 - i_width/2,
            y        = screen.h/2 - i_height/2,
            z        = 0,
            --z_rotation = 740-math.random(20)-10,
            on_completed = function()
                if (img_table[index] ~= nil) then
                    img_table[index]:animate 
                    {
                        duration     = 20000,
                        opacity      = 254,
                        on_completed = function()
                            self.ui:remove(self.images[temp])
                            self.images[temp] = {}
                        end
                    }
                end
                still_loading = false
                --current_pic = current_pic + 1		
            end
        }
--]]
    --else
    --end
	
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
    else
        timer:start()
        timer_running = true
    end
end

function Slideshow:previous_picture()
    --if still_loading then
    --elseif current_pic - 1 > 0 then
    if #on_screen_list > 0 then
        print("prev\tbefore \ton screen",#on_screen_list,"off_screen",#off_screen_list)

        --still_loading = true
        current_pic   = current_pic -1

        --grab an image off of the off screen table
        assert(  on_screen_list ~= nil, "on screen list is nil"   )
        assert( #on_screen_list > 0,    "on screen list is empty" )

        local pic = table.remove(on_screen_list, 1 )
        table.insert(off_screen_list, 1 ,pic)
        print("prev\tafter \ton screen",#on_screen_list,"off_screen",#off_screen_list)

        pic:complete_animation()
 
        --animate it off the screen
        pic:animate 
        {
            duration = 200,
            mode     = EASE_IN_EXPO,
            --z = 500,
            --opacity = 0,
        x = (math.random(2)-1)*1920,
        y = (math.random(2)-1)*1080,
            --garbage collection
            on_completed = function()
                z = 500
                self.ui:remove(pic)
                if #off_screen_list > 6 then
                    self.ui:remove(off_screen_list[#off_screen_list])
                    off_screen_list[#off_screen_list] = nil
                end
            end
        }
        
    else
        -- tell the user NO
    end

end

function Slideshow:next_picture()
    --if still_loading then
    --else
       -- still_loading = true

        print("next\tbefore \ton screen",#on_screen_list,"off_screen",#off_screen_list)
        current_pic = current_pic +1

        --grab an image off of the off screen table
        assert(  off_screen_list ~= nil, "off screen list is nil"   )
        assert( #off_screen_list > 0,    "off screen list is empty" )
        table.insert( on_screen_list,  1, table.remove( off_screen_list,1 ))
        print("next\tafter \ton screen",#on_screen_list,"off_screen",#off_screen_list)
 
        --load up another in the preload list
        if #off_screen_list < 5 then
            self:preload(1)
        end

        --animate it to the screen
        self.ui:add(on_screen_list[1])
        on_screen_list[1]:complete_animation()
        on_screen_list[1].opacity = 255
        on_screen_list[1]:animate 
        {
            duration = 200,
            mode     = EASE_IN_EXPO,
            x        = screen.w/4,--2 - i_width/2,
            y        = screen.h/6,--2 - i_height/2,
            z        = 0,
            --garbage collection
            on_completed = function()
                if #on_screen_list > 5 then
                    self.ui:remove(on_screen_list[#on_screen_list])
                    on_screen_list[#on_screen_list] = nil
                end
            end
        }
        

    --end
end

function Slideshow:toggle_fullscreen()
end
