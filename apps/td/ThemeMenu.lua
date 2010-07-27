--themeMenu.lua

local g = Group{}

local themeMenuList = {}
local names = {}

for k,v in pairs(Themes) do
	themeMenuList[ #themeMenuList + 1 ] = {}
	themeMenuList[ #themeMenuList][1] = Rectangle{color = "CC00FF", w=300, h=80, name = k, x = 950}
	names[#names+1] = k
end

themeMenuList[1][1].y = 400

screen:add(g)

ThemeMenu = Menu.create(g, themeMenuList)
ThemeMenu.container.opacity = 0
ThemeMenu:create_key_functions()
ThemeMenu:button_directions()
ThemeMenu:create_buttons(10, "Sans 34px")
ThemeMenu:apply_color_change("FFFFFF", "00CCCC")

ThemeMenu.buttons.extra.r = function()

	MainMenu.container.opacity = 0
	ThemeMenu.container.opacity = 0
	LevelMenu.buttons:grab_key_focus()
	LevelMenu.container.opacity = 255
	LevelMenu.hl.opacity = 255
	LevelMenu:update_cursor_position()

end

ThemeMenu.buttons.extra.space = function()

	ThemeMenu.container.opacity = 0
	MainMenu.buttons:grab_key_focus()

end
