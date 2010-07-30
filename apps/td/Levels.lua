-- levels

local list =	{
					{ Rectangle{color = "CC00FF", w=300, h=200, name = "1"}, Rectangle{color = "CC00FF", w=300, h=200, name = "2"}, Rectangle{color = "CC00FF", w=300, h=200, name = "3"} },
					{ Rectangle{color = "CC00FF", w=300, h=200, name = "4"}, Rectangle{color = "CC00FF", w=300, h=200, name = "5"}, Rectangle{color = "CC00FF", w=300, h=200, name = "6"} },
					{ Rectangle{color = "CC00FF", w=300, h=200, name = "7"}, Rectangle{color = "CC00FF", w=300, h=200, name = "8"}, Rectangle{color = "CC00FF", w=300, h=200, name = "9"} },
					{ Group{name = "null"}, Rectangle{color = "CC00FF", w=300, h=200, name = "10"}, Group{name = "null"} }
				}

local g = Group{}

screen:add(g)


local levelFocus = Rectangle{color="FF00CC", w=320, h=220}

LevelMenu = Menu.create(g, list, levelFocus)
LevelMenu.container.opacity = 0
LevelMenu:create_key_functions()
LevelMenu:button_directions()
LevelMenu:create_buttons(10, "Sans 34px")
LevelMenu:apply_color_change("FFFFFF", "000000")

LevelMenu.container.x = 400
LevelMenu.container.y = 150

LevelMenu.buttons.extra.space = function()

	LevelMenu.container.opacity = 0
	MainMenu.container.opacity = 255
	MainMenu.buttons:grab_key_focus()

end

LevelMenu.buttons.extra.r = function()

	--dofile("Globals.lua")

	round = tonumber( list[LevelMenu.y][LevelMenu.x].name )
	
	LevelMenu.theme.wave = dofile("themes/"..LevelMenu.theme.themeName.."/round"..round..".lua")

	game = Game:new{ theme = LevelMenu.theme , gold = LevelMenu.theme.wave.money}
	game:startGame()
	
	screen:add(countdowntimer, phasetext, playertext, goldtext)
	screen:add(bulletImage, healthbar, shootAnimation, healthbarblack, bloodGroup, obstaclesGroup)
	
	

end
