--Circle

local c = Group{}
screen:add(c)

local list = {
					{	Rectangle{color="FF00CC", opacity=255, w=200, h=200},	Rectangle{color="FF00CC", opacity=255, w=200, h=200}, Rectangle{color="FF00CC", opacity=255, w=200, h=200} }
				 }


CircleMenu = Menu.create(c, list)
CircleMenu:create_key_functions()
CircleMenu:button_directions()
CircleMenu:create_circle()


--CircleMenu.buttons:grab_key_focus()
--CircleMenu:update_cursor_position()

CircleMenu.container.opacity=255

