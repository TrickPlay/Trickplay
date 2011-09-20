CHANGE_TIME_VIEW = 100
 -- constructor, called with Model(...)
Model = Class(function(model, ...)
    -- (private) class fields
    model.registry = {}
    model.controllers = {}
    model.active_component = nil
    model.loading_dot      = Image{src="assets/LoadingCircle.png",size = {30,30},opacity = 0}
    screen:add(model.loading_dot)
    model.pic_text = {0,0}

    --model.num_sources = NUM_SLIDESHOW_IMAGES
    model.front_page_index = 1--math.ceil(math.ceil(model.num_sources /NUM_ROWS)/2)
    model.swapping_cover = false
    model.swap_pic = nil

    --FRONT_PAGE
    model.albums = {}
    model.placeholders = {}
    model.album_group = Group{name="Album Group"}
    model.fp_backing = Rectangle{
                color    = "000000",
                width    = PIC_W - 4,
                height   = PIC_H - 4,
                position = { 2 , 2 },
                opacity  = 0
    }
    screen:add(model.fp_backing)
    model.fp_slots = {}

    model.fp_index = {1,1}
    model.fp_1D_index = 1
--[[
 model.prac_pic.scale = {
                                    PIC_W / model.prac_pic.base_size[1],
                                    PIC_H / model.prac_pic.base_size[2]
                                }

	model.default = {}
	for i=1,8 do 
		 model.default[i] = Image{
		             src = "assets/backs/color_0"..i..".jpg",
		             opacity = 0
		 }
	    model.def_bs = {model.default[i].base_size[1],model.default[i].base_size[2]}

		 screen:add(model.default[i])

	end
--]]

    --SLIDE_SHOW
    model.curr_slideshow = {}

	model.source_list= {}
    --Source Manager
--[[
    for i=1, #adapterTypes do
            print(adapterTypesTable[i])
            print(adapterTypesTable[i][1].required_inputs.format)
	    model.source_list[i] = {adapterTypesTable[i].name,   
                adapterTypesTable[i][1].required_inputs.format}
	 end
--]]
--[[    model.source_list = {  {adapters[1].name,   adapters[1][1].required_inputs.format}, {"Picasa",     "LOGIN"},
                           {"Facebook", "LOGIN"}, {adapters[2].name,   adapters[2][1].required_inputs.format},
                           {"Flickr",   "QUERY"}, {"PhotoBuket", "QUERY"}
                        }
]]
    -- class methods
    function model:attach(observer, controller_id)
        self.registry[observer] = true
        if controller_id then
            self.controllers[controller_id] = observer
        end
    end

    function model:detach(observer)
        self.registry[observer] = nil
    end

    function model:notify()
        for observer, bool in pairs(self.registry) do
            observer:update()
        end
    end

    function model:get_controller(comp)
        if self.controllers[comp] then
            return self.controllers[comp]
        else
            error("component doesn't exist.")
        end
    end

    function model:get_active_controller()
       assert(self.controllers[self.active_component])
       return self.controllers[self.active_component]
    end

    function model:get_active_component()
        return self.active_component
    end

    function model:start_app(comp)
        self.active_component = comp
        screen:show()
        self:notify()
        -- local firstAnimation = Group{position = {1920, 750}}
        -- local text = Text{
        --     position = {0,0},
        --     font = CUSTOMIZE_TAB_FONT,
        --     color = Colors.WHITE,
        --     text = "Enter Your Delivery Address NOW!"
        -- }
        -- local image = Image{
        --     position = {10, 70},
        --     src = "assets/DownScrollArrow.png",
        --     scale = {4,4}
        -- }
        -- firstAnimation:add(text, image)
        -- screen:add(firstAnimation)
        -- firstAnimation:animate{duration = 1000, x = 420,
        --     on_completed = function()
        --         local timer = Timer()
        --         timer.interval = 2000
        --         function timer:on_timer()
        --             timer.on_timer = nil
        --             timer = nil
        --             firstAnimation:animate{duration = 300, x = -900}
        --         end
        --         timer:start()
        --     end
        -- }
    end
    
    function model:set_active_component(comp)
       collectgarbage("collect")
       if type(comp) ~= "number" then
          error("Component " .. tostring(comp) .. " is not a number", 2)
       elseif comp < Components.COMPONENTS_FIRST or 
              Components.COMPONENTS_LAST < comp then
          error("Component " .. comp .. " does not exist", 2)
       end
       self.previous_component = self.active_component
       self.active_component = comp
       print("set active component to",comp)
    end

    function model:set_keys()
        function screen:on_key_down(k)
            assert(model:get_active_controller())
        end
    end

end)




Observer = Class(function(observer, ...)
    -- class fields

    -- class methods
    function observer:update()
        error("Update not defined for observer") 
    end

end)

View = Class(Observer, function(view, model, ...)
    -- COMMON VIEW LOGIC

    -- (private) class fields
    view.model = model
    view.controller = nil
    model:attach(view)

    -- class methods
    function view:initialize()
        error("Initializing empty controller", 2)
        self.controller = Controller(self)
    end

    function view:get_model()
        return view.model
    end

    function view:set_controller(cont)
        self.controller = cont
        self.set_controller = nil
    end

    function view:get_controller()
        return self.controller
    end

    function view:update()
        error("not implemented")
    end
    -- END COMMON VIEW LOGIC

end)

Controller = Class(Observer, function(controller, view, controller_id)
    assert(controller_id)

    -- class fields
    controller.model = view:get_model()
    controller.view = view
    controller.model:attach(controller, controller_id)

    function controller:update()
    end

    function controller:get_model()
        return self.model
    end

    function controller:get_view()
        return self.view
    end

    function controller:run_callback()
        error("run_callback() not defined for controller")
    end

    function controller:on_focus()
        error("self:on_focus() not defined for controller", 2)
    end
    
    function controller:out_focus()
        error("self:out_focus() not defined for controller")
    end

end)
