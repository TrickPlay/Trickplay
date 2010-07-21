dofile("menu.lua")
dofile("menu_carousel.lua")
--[[
Components = {
   ADDRESS_INPUT = 1,
   KEYBOARD_INPUT = 2,
   PROVIDER_SELECTION = 3,
   MENU = 4,
   CHECKOUT = 5,
}

-- dofile("views/BackgroundView.lua")


-- Model initialization
local model = Model()
LoadMenu()

-- View/Controller initialization
-- --local background_view = BackgroundView:new(model)
-- --background_view:initialize()

local menu_view = MenuView(model)
menu_view:initialize()
local keyboard_input_view = KeyboardInputView(model)
keyboard_input_view:initialize()
-- -- local reroll_menu_view = RerollMenuView:new(model)
-- -- reroll_menu_view:initialize()
-- -- local ingame_menu_view = IngameMenuView:new(model)
-- -- ingame_menu_view:initialize()

function screen:on_key_down(k)
   model:get_active_controller():on_key_down(k)
end

model:start_app(Components.ADDRESS_INPUT)
--]]

app.on_loaded = function()

	local carousel_list = { {
		 		  Image{src="match.png", scale={.7,.7}, y=-50  },
		 		  Image{src="match.png", scale={.7,.7}, y=-50  },
		 		  Image{src="match.png", scale={.7,.7}, y=-50  },
		 		  Image{src="match.png", scale={.7,.7}, y=-50  },
		 		  Image{src="match.png", scale={.7,.7}, y=-50  }
	} }

	local container = Group{opacity=0}
	screen:add(container)

	Carousel = Menu.create(container, carousel_list)

	Carousel:create_key_functions()
	Carousel:carousel_directions()
	Carousel:create_carousel()

	Carousel.container.opacity=255

	Carousel.buttons:grab_key_focus()
	screen:show()

end
