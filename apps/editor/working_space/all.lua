local g = ... 

rect0 = Rectangle
	{
		name="rect0",
		border_color={250,250,250,192},
		border_width=0,
		color={250,250,250,250},
		size = {340,230},
		anchor_point = {0,0},
		x_rotation={10,0,0},
		y_rotation={90,0,0},
		z_rotation={0,0,0},
		position = {240,410},
		opacity = 250
	}

rect3 = Rectangle
	{
		name="rect3",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,255,255},
		size = {60,78},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {0,0},
		opacity = 255
	}

rect4 = Rectangle
	{
		name="rect4",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,255,255},
		size = {56,100},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {72,62},
		opacity = 255
	}

group5 = Group
	{
		name="group5",
		size={128,162},
		position = {1358,528},
		children = {rect3,rect4},
		scale = {1,1,0,0},
		anchor_point = {64,81},
		x_rotation={10,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		opacity = 255
	}

img4 = Image
	{
		name="img4",
		src="./working_space/logo.png",
		position = {1041,551},
		size = {201,101},
		clip = {0,0,200,71},
		anchor_point = {100,50},
		x_rotation={11,0,0},
		y_rotation={31,0,0},
		z_rotation={1,0,0},
		opacity = 251
	}

clone2 = Clone
	{
		name="clone2",
		size={342,232},
		position = {1264,752},
		source=rect0,
		scale = {2,2,0,0},
		anchor_point = {348,0},
		x_rotation={12,0,0},
		y_rotation={2,0,0},
		z_rotation={2,0,0},
		opacity = 252
	}

text1 = Text
	{
		name="text1",
		text="sdfhasdfjkl",
		font="DejaVu Sans 40px",
		color={21,21,21,192},
		size={401,101},
		position = {761,469},
		anchor_point = {200,0},
		x_rotation={11,0,0},
		y_rotation={1,0,0},
		z_rotation={1,0,0},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true,
		wrap_mode="WORD",
		opacity = 251
	}

g:add(rect0,group5,img4,clone2,text1)