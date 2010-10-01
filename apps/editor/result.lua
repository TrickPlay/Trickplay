local g = ... 

text0 = Text
	{
		name="text0",
		text="sjdfhksfj",
		font="DejaVu Sans 50px",
		color={0,41,0,255},
		size={150,150},
		position = {788,872},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true,
		opacity = 255
	}

img1 = Image
	{
		name="img1",
		src="assets/logo.png",
		base_size={174,71},
		position = {102,956},
		async=false,
		loaded=true,
		opacity = 255
	}

rect999 = Rectangle
	{
		name="rect999",
		border_color={255,255,255,255},
		border_width=1,
		color={0,53,194,73},
		size = {200,200},
		position = {1098,300},
		opacity = 255
	}

text3 = Text
	{
		name="text3",
		text="sdfasdfsdfi",
		font="DejaVu Sans 40px",
		color={240,240,240,255},
		size={150,150},
		position = {100,100},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true,
		opacity = 255
	}

img999 = Image
	{
		name="img999",
		src="logo.png",
		base_size={174,71},
		position = {708,562},
		async=false,
		loaded=true,
		opacity = 255
	}

img5 = Image
	{
		name="img5",
		src="logo.png",
		base_size={174,71},
		position = {1352,770},
		async=false,
		loaded=true,
		opacity = 255
	}

g:add(text0,img1,rect999,text3,img999,img5)