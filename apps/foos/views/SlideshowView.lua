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
    screen:add(backup)
    local overlay_image = Image
    { 
        src     = "assets/overlay.png", 
        opacity = 0 
    }

    local background  = Image {src = "assets/background.jpg" }
    local background2 = Image {src = "assets/background2.png" }

    --NAV UI
    local back     = Image{src="assets/slideshow/NavBack.png" }
    local left     = Image{src="assets/slideshow/NavPrev.png", x=-80}
    local right    = Image{src="assets/slideshow/NavNext.png", x=140}
    local down     = Image{src="assets/slideshow/NavFull.png", x= 30,y= 80}
    local up_play  = Image{src="assets/slideshow/NavPlay.png", x= 30,y=-80}
    local up_pause = Image{src="assets/slideshow/NavPause.png",x= 30,y=-80,
                                                              opacity =  0}
    local controls = Group{x = 100, y = 900, z =1}
    controls:add(up_pause,up_play,down,left,right,back)

    local caption = Text 
    {
        font = "Sans 15px",
        text = "",
        x    = 1530,
        y    = 400
    }
    view.logo = nil
    view.queryText = Text 
    { 
        text = "",
        font = "Sans 30px",
        x    = 105, 
        y    = 300
    }


    view.ui:add( overlay_image, background, background2, caption,
                 view.queryText, controls )
    view.timer            = Timer()
    view.timer.interval   = 4
    view.timer_is_running = false
     

    view.on_screen_list  = {}
    view.off_screen_list = {}

    local styles = {"REGULAR","FULLSCREEN","LAYERED"}
    local set_ui =  
    {
        ["REGULAR"]    = function()
            background.opacity = 255
            background2.opacity = 255
            logo.opacity = 255
            controls.opacity = 255

            for i = 1,#view.on_screen_list do
                local pic = view.on_screen_list[i]:find_child("slide")
                pic:unparent()
                assert(pic ~= nil,"couldn't find the picture in the"..
                       " on_screen_list at index",i,"when converting"..
                       " the slideshow to regular mode")
                off_screen_prep["REGULAR"](pic,view.on_screen_list[i])
            end
            for i = 1,#view.off_screen_list do
                local pic = view.off_screen_list[i]:find_child("slide")
                pic:unparent()
                assert(pic ~= nil,"couldn't find the picture in the"..
                       " off_screen_list at index",i,"when converting"..
                       " the slideshow to regular mode")
                off_screen_prep["REGULAR"](pic,view.off_screen_list[i])
            end
        end,

        ["FULLSCREEN"] = function()
            background.opacity = 0
            background2.opacity = 0
            logo.opacity = 0
            controls.opacity = 100

            for i = 1,#view.on_screen_list do
                local pic = view.on_screen_list[i]:find_child("slide")
                pic:unparent()
                assert(pic ~= nil,"couldn't find the picture in the"..
                       " on_screen_list at index",i,"when converting"..
                       " the slideshow to fullscreen mode")
                off_screen_prep["FULLSCREEN"](pic,view.on_screen_list[i])
            end
            for i = 1,#view.off_screen_list do
                local pic = view.off_screen_list[i]:find_child("slide")
                pic:unparent()
                assert(pic ~= nil,"couldn't find the picture in the"..
                       " off_screen_list at index",i,"when converting"..
                       " the slideshow to fullscreen mode")
                off_screen_prep["FULLSCREEN"](pic,view.off_screen_list[i])
            end

        end,
        ["LAYERED"]    = function()
        end
    }

    local forward_animation =
    {
        ["REGULAR"]    = function(pic)
            pic:animate 
            {
                duration = 400,
                mode     = EASE_IN_EXPO,
                x        = screen.w/4,
                y        = screen.h/6,
                z        = 0
            }
        end,
        ["FULLSCREEN"] = function(pic)
            pic.opacity = 0
			  
            pic:animate 
            {
                duration = 700,
                mode     = EASE_IN_EXPO,
                opacity  = 255
            }
            if view.on_screen_list[2] ~= nil  then
                view.on_screen_list[2]:animate
                {
                    duration = 1000,
                    opacity  = 0,
                    mode     = EASE_IN_EXPO,
                }
            end
        end,
        ["LAYERED"]    = function()
        end
    }

    local backward_animation =
    {
        ["REGULAR"]    = function(pic)
            pic:animate 
            {
                duration = 400,
                mode     = EASE_IN_EXPO,
                x        = math.random(0,1)*1920,
                y        = math.random(0,1)*1080,
                z        = 500,
                --garbage collection
                on_completed = function()
                    --z = 500
                    view.ui:remove(pic)
--[[handled in a different function

                    if #off_screen_list > 6 then
                        print("removing from off_screen list")
                        off_screen_list[#off_screen_list] = nil
                    end
--]]
                 end
            }
        end,
        ["FULLSCREEN"] = function()
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
                end
            }
            self.ui:add(view.on_screen_list[1])
            view.on_screen_list[1]:animate 
            {
                duration = 1000,
                opacity = 255,
                mode = EASE_IN_EXPO,
            }
        end,
        ["LAYERED"]    = function()
        end
    }
    local off_screen_prep = 
    {
        ["REGULAR"]    = function(img,group)
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
        end,
        ["FULLSCREEN"] = function(img,group)
                group.opacity = 0
                group.z_rotation = {0,img.w/2,img.h/2}
                group.anchor_point = {img.w/2,img.h/2}
                group.z = 0
                group.x = screen.w/2
                group.y = screen.h/2
                group.scale = {1080/img.h,1080/img.h}
                group:add(img)
        end,
        ["LAYERED"]    = function(img,group)
        end
    }
    local on_screen_prep =
    {
        ["REGULAR"]    = function(img,group)
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
        end,
        ["FULLSCREEN"] = function(img,group)
                group.opacity = 0
                group.z_rotation = {0,img.w/2,img.h/2}
                group.anchor_point = {img.w/2,img.h/2}
                group.z = 0
                group.x = screen.w/2
                group.y = screen.h/2
                group.scale = {1080/img.h,1080/img.h}
                group:add(img)
        end,
        ["LAYERED"]    = function(img,group)
        end
    }

    function view:initialize()
        self:set_controller(SlideshowController(self))
    end

    function view:preload_front()
        view.off_screen_list[#view.off_screen_list+1] = Group {z = 500}
        local group = view.off_screen_list[#view.off_screen_list]

        local style_i = view:get_controller():get_style_index()
--[[
        local clone = Clone
        {
            name   = "slide",
            source = backup,
        }
--]]
        local clone = Group{}
        local timeline  = loading(clone)
        off_screen_prep[styles[style_i] ](clone,group)

        local index = view:get_controller():get_photo_index() +
                                          #view.off_screen_list
        print("preload front",index)
        local request = URLRequest
        {
            url = adapters[#adapters - model.fp_1D_index + 1][1].photos(
                      adapters[#adapters - model.fp_1D_index + 1][1].required_inputs.query,
                      index,
                      model.fp_1D_index
                  ),
            on_complete = function (request, response)

                local data   = json:parse(response.body)
                local site   = adapters[#adapters - model.fp_1D_index + 1][1].site(data,
                                                                   index)
                caption.text = adapters[#adapters - model.fp_1D_index + 1][1].caption(data)

                local photo_i = view:get_controller():get_photo_index()

                --recalculate the relative index
                --in case the user moved while it was loading
                local rel_i = index - 
                             view:get_controller():get_photo_index()
                
                local image = Image{
                    name      = "slide",
                    src       = site, 
                    async     = true, 
                    on_loaded = function(img,failed)
                        --if it failed to load from the internet, then
                        --throw up the placeholder
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
                            on_screen_prep[styles[style_i]](placeholder,group)
                        else
                            --view.on_screen_list[rel_i] = Group {z = 500}
                            timeline:stop()
                            group:clear()
                            on_screen_prep[styles[style_i] ](img,group)
                        end
                        img.on_loaded = nil
                    end
                } 

            end
        }
        request:send()
    end
    function view:preload_back()
        view.on_screen_list[#view.on_screen_list+1] = Group {z = 0}
        local group = view.on_screen_list[#view.on_screen_list]
        view.ui:add(group)
        group:lower_to_bottom()
        background2:lower_to_bottom()
        background:lower_to_bottom()

        local style_i = view:get_controller():get_style_index()
--[[
        local clone = Clone
        {
            name   = "slide",
            source = backup,
        }
--]]
        local clone = Group{}
        local timeline = loading(clone)
        on_screen_prep[styles[style_i] ](clone,group)
        local index = view:get_controller():get_photo_index() -
                                          #view.on_screen_list +1
        print("preload back",index)
        local request = URLRequest
        {
            url = adapters[#adapters - model.fp_1D_index + 1][1].photos(
                  adapters[#adapters - model.fp_1D_index + 1][1].required_inputs.query,
                           index,
                           model.fp_1D_index
                  ),
            on_complete = function (request, response)

                local data   = json:parse(response.body)
                local site   = adapters[#adapters - model.fp_1D_index + 1][1].site(data,
                                                                   index)
                caption.text = adapters[#adapters - model.fp_1D_index + 1][1].caption(data)


                local photo_i = view:get_controller():get_photo_index()
                local style_i = view:get_controller():get_style_index()

                --recalculate the relative index
                --in case the user moved while it was loading
                local rel_i = -1*( index + 1 - photo_i )
                
                --self:LoadImage(site,view.on_screen_list,updated_index)
                local image = Image{
                    name      = "slide",
                    src       = site, 
                    async     = true, 
                    on_loaded = function(img,failed)
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
                            on_screen_prep[styles[style_i]](placeholder,group)
                        else
                            --view.on_screen_list[rel_i] = Group {z = 500}
                            timeline:stop()
                            group:clear()
                            on_screen_prep[styles[style_i]](img,group)
                            --if its the desk/slideshow, then need to
                            --put it at the bottom of the stack
                        end
                        img.on_loaded = nil
                    end
                } 
            end
        }
        request:send()
    end

    function view:toggle_timer()    
        if view.timer_is_running then
            view.timer:stop()
            view.timer_is_running = false
            up_play.opacity  = 255
            up_pause.opacity = 0
        else
            view.timer:start()
            view.timer_is_running = true
            up_play.opacity  = 0
            up_pause.opacity = 255
        end

    end  
    function view.timer.on_timer(timer)
	print("tick "..current_pic)
	--if still_loading then
        if #view.off_screen_list > 0 then
                timer.interval = 4
		view:next_picture()
	end
    end

    view.prev_i = 0

    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local photo_i    = controller:get_photo_index()
        local style_i    = controller:get_style_index()
        if comp == Components.SLIDE_SHOW  then
            print("\n\nShowing SlideshowView UI\tquery index:",
                  model.fp_1D_index,"photo index:",photo_i,"on screen:",
                  #view.on_screen_list,"off_screen:",#view.off_screen_list,
                  "\n")
            view.ui:raise_to_top()
            view.ui.opacity = 255

            --if moving backwards
            if photo_i - view.prev_i < 0 then
                if #view.on_screen_list > 1 then
                    print("moving backward")
                    --grab the pic underneath the current one
                    local pic = table.remove(view.on_screen_list, 1 )
                    table.insert(view.off_screen_list, 1 ,pic)
                    pic:complete_animation()
                
                    backward_animation[styles[style_i]](pic)
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

                   --add it to the screen and end its previous animation
                   self.ui:add(pic)
                   pic:complete_animation()
                   pic.opacity = 255

                   forward_animation[styles[style_i]](pic)
                else
                    print("off screen is 0")
                end
            else
                print("diff is 0?\tphoto_i:",photo_i,"prev_i",view.prev_i)
            end
            view.prev_i = photo_i
        else
            print("Hiding SlideshowView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)


