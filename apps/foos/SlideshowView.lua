SlideshowView = Class(View, function(view, model, ...)
    view._base.init(view, model)
    view.ui = Group{name="slideshow ui"}
    screen:add(view.ui)

    
    local timer = Timer()
    timer.interval = 4
    --current_pic = 1

    function view:initialize()
        self:set_controller(SlideshowController(self))
    end

    
    function view:start_timer()
	print ("begin")
	timer:start()
    end

           
    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()

        if comp == Components.SLIDE_SHOW  then
            print("\n\nShowing SlideshowView UI\n")
            view.ui:raise_to_top()
            view.ui.opacity = 255            
            model.curr_slideshow.ui = view.ui
        else
            print("Hiding SlideshowView UI")
            view.ui:complete_animation()
        end
    end

end)
