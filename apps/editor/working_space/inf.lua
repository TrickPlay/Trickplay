local g = ... 

rect0 = Rectangle
	{
		name="rect0",
		border_color={255,255,255,192},
		border_width=0,
		color={255,25,255,255},
		size = {90,64},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {1548,714},
		opacity = 255
	}

rect2 = Rectangle
	{
		name="rect2",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,255,255},
		size = {60,76},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {2572,546},
		opacity = 255
	}

rect1 = Rectangle
	{
		name="rect1",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,25,255},
		size = {124,92},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {328,358},
		opacity = 255
	}

rect3 = Rectangle
	{
		name="rect3",
		border_color={255,255,255,192},
		border_width=0,
		color={25,255,255,255},
		size = {88,208},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {0,0},
		opacity = 255
	}

group4 = Group
	{
		name="group4",
		size={452,450},
		position = {162,200},
		children = {rect1,rect3},
		scale = {1,1,0,0},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		opacity = 255
	}

g:add(rect0,rect2,group4)