dofile ("Game.lua")
dofile ("Board.lua")
dofile ("Globals.lua")
dofile ("themes/Themes.lua")
dofile ("Creep.lua")
dofile ("Tower.lua")


screen:show()

function app.on_loaded()

	dofile("menu/menu.lua")

	local mainMenuList = {
									{ Rectangle{color="CC00FF", w=400, h=150, name="Single Player", x=500, y=400} },
									{ Rectangle{color="CC00FF", w=400, h=150, name="Cooperative", x=500} },
									{ Rectangle{color="CC00FF", w=400, h=150, name="Competetive", x=500} }
								}
							
	local mainMenuFocus = Rectangle{color="FF00CC", w=420, h=170}
							
	local g = Group{}
	screen:add(g)
							
	MainMenu = Menu.create(g, mainMenuList, mainMenuFocus)
	MainMenu:create_key_functions()
	MainMenu:button_directions()
	MainMenu:create_buttons(10, "Sans 34px")
	MainMenu:apply_color_change("FFFFFF", "000000")
	MainMenu.buttons:grab_key_focus()
	MainMenu:update_cursor_position()
	MainMenu.hl.opacity = 255

	MainMenu.buttons.extra.r = function()
		MainMenu.container.opacity = 0
		game = Game:new{}
		game:startGame()
	end

end
