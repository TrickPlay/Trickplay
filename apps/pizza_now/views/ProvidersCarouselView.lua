ProvidersCarouselView = Class(View, function(view, model, ...)
    view._base.init(view,model, Components.PROVIDER_SELECTION)

    view.menu_items = { Image{src="views/match.png", scale={.7,.7}, y=-50  },
                        Image{src="views/match.png", scale={.7,.7}, y=-50  },
                        Image{src="views/match.png", scale={.7,.7}, y=-50  },
                        Image{src="views/match.png", scale={.7,.7}, y=-50  },
                        Image{src="views/match.png", scale={.7,.7}, y=-50  },
    }

    view.ui = Group{name="providersCarousel_ui", position={1,1}, opacity=255}

    -- 2 pi divided by number of objects is the amount that each
    -- in the carousel rotates by
    local rotation=( 2*math.pi ) / #view.menu_items

    --creates the carousel
    for i=1,#view.menu_items do
        local obj = view.menu_items[i]
        --Store old position
        obj.extra.x = obj.x
        obj.extra.y = obj.y
	
        -- Update values
        obj.anchor_point = {obj.w/2,obj.h/2}
        obj.x = screen.w/2 + 500*math.sin(rotation*i)
        obj.z = 200*math.cos(rotation*i)
        obj.y = screen.h/2 - 50 + 120*math.cos(rotation*i)
        obj.extra.angle = rotation*i
        obj.opacity = 80 + 175*math.cos(rotation*i)
        
        obj.x = obj.x + obj.extra.x
        obj.y = obj.y + obj.extra.y
        view.ui:add(obj)
    end
---------------------------------------------------------
    --view.carousel_ui:add(unpack(menu_items))
    --assert(view.carousel_ui.children[1])
    screen:add(view.ui)

    function view:initialize()
        self:set_controller(ProvidersCarouselController(self))
    end

    function view:update()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.PROVIDER_SELECTION then
            print("Showing CarouselView UI")
--            self.ui.opacity = 255
            --[[
            for i,item in ipairs(car_items) do
                if i == controller:get_selected_index() then
                    item:animate{duration=1000, mode="EASE_OUT_EXPO", opacity=255}
                else
                    item:animate{duration=1000, mode="EASE_OUT_BOUNCE", opacity=0}
                end
            end
            --]]
        else
            print("Hiding CarouselView UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end
    function view:move_left()
		print("\t\tleft")
		--local rotation=( 2*math.pi ) / #car_items
        for i=1,#view.menu_items do
            local obj = view.menu_items[i]
            local new_angle = obj.extra.angle + rotation
            local new_x = screen.w/2 + 500*math.sin(new_angle)
            local new_y = screen.h/2 - 50 + 120*math.cos(new_angle)
            local new_z = 200*math.cos(new_angle)
            local new_o = 80 + 175*math.cos(new_angle)
			
            obj:animate{ duration=500, x=new_x, y=new_y, z=new_z,
                            opacity=new_o}
            obj.extra.angle = new_angle
        end
    end
    function view:move_right()
		print("\t\tright")
		--local rotation=( 2*math.pi ) / #car_items
		for i=1,#view.menu_items do
			local obj = view.menu_items[i]
			local new_angle = obj.extra.angle - rotation
			local new_x = screen.w/2 + 500*math.sin(new_angle)
			local new_y = screen.h/2 - 50 + 120*math.cos(new_angle)
			local new_z = 200*math.cos(new_angle)
			local new_o = 80 + 175*math.cos(new_angle)
			
			obj:animate{ duration=CHANGE_VIEW_TIME, x=new_x, y=new_y, z=new_z, 
                                     opacity=new_o}
			obj.extra.angle = new_angle	
		end
	end
end)
