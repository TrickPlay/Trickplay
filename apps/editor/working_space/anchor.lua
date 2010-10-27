local g = ... 

object = Rectangle
	{
		name="rect0",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,255,255},
		size = {50,50},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {4,6},
		opacity = 255
	}

center = Rectangle
	{
		name="center",
		border_color={255,255,255,192},
		border_width=0,
		color={25,25,25,255},
		size = {15,15},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {22.25,23},
		opacity = 255
	}

mid_top = Clone
	{
		name="mid_top",
		size={15,15},
		position = {22.25,0},
		source=center,
		scale = {1,1,0,0},
		opacity = 255
	}

mid_bottom = Clone
	{
		name="mid_bottom",
		size={15,15},
		position = {22.25,46},
		source=center,
		scale = {1,1,0,0},
		opacity = 255
	}

right_mid = Clone
	{
		name="right_mid",
		size={15,15},
		position = {44.5,23},
		source=center,
		scale = {1,1,0,0},
		opacity = 255
	}

right_top = Clone
	{
		name="right_top",
		size={15,15},
		position = {44.5,0},
		source=mid_top,
		scale = {1,1,0,0},
		opacity = 255
	}

left_mid = Clone
	{
		name="left_mid",
		size={15,15},
		position = {0,23},
		source=mid_bottom,
		scale = {1,1,0,0},
		opacity = 255
	}

right_bottom = Clone
	{
		name="right_bottom",
		size={15,15},
		position = {44.5,46},
		source=center,
		scale = {1,1,0,0},
		opacity = 255
	}

left_bottom = Clone
	{
		name="left_bottom",
		size={15,15},
		position = {0,46},
		source=mid_top,
		scale = {1,1,0,0},
		opacity = 255
	}

left_top = Clone
	{
		name="left_top",
		size={15,15},
		position = {0,0},
		source=mid_bottom,
		scale = {1,1,0,0},
		opacity = 255
	}

anchor_pnt = Group
	{
		name="group11",
		size={59.5,61},
		position = {696,578},
		children = {object,center,mid_top,mid_bottom,right_mid,right_top,left_mid,right_bottom,left_bottom,left_top},
		scale = {1,1,0,0},
		opacity = 255
	}

g:add(group11)
