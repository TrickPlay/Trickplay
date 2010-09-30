local g = ... 

text0 = Text
	{
		name="text0",
		text="sjdfhksfj",
		font="DejaVu Sans 40px",
		color={255,255,255,255},
		size={150,150},
		position = {1598,262},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true
	}

img1 = Image
	{
		name="img1",
		src="assets/logo.png",
		base_size={174,71},
		position = {102,956},
		async=false,
		loaded=true
	}

rect2 = Rectangle
	{
		name="rect2",
		border_color={0,0,0,255},
		border_width=1,color={255,255,255,192},
		size={0,0,0,255},
		border_width=1,
		color={255,255,255,192},
		size = {80,78},
		position = {1304,590}
	}

text3 = Text
	{
		name="text3",
		text="sdfasdfsdfi",
		font="DejaVu Sans 40px",
		color={255,255,255,192},
		size={150,150},
		position = {100,100},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true
	}

img4 = Image
	{
		name="img4",
		src="logo.png",
		base_size={174,71},
		position = {714,562},
		async=false,
		loaded=true
	}

img5 = Image
	{
		name="img5",
		src="logo.png",
		base_size={174,71},
		position = {1352,770},
		async=false,
		loaded=true
	}

g:add(text0,img1,rect2,text3,img4,img5)