local g = ... 

img0 = Image
	{
		name="img0",
		src="logo.png",
		position = {1474,214},
		clip = {0,0,174,71},
		opacity = 255
	}

rect1 = Rectangle
	{
		name="rect1",
		border_color={0,0,0,255},
		border_width=1,
		color={255,255,255,192},
		size = {1564,24},
		position = {156,308},
		opacity = 100
	}

text2 = Text
	{
		name="text2",
		text="Title",
		font="DejaVu Sans 40px",
		color={255,255,255,192},
		size={150,150},
		position = {150,236},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true,
		opacity = 90
	}

text3 = Text
	{
		name="text3",
		text="aaabbbcccddd",
		font="DejaVu Sans 40px",
		color={0,100,0,255},
		size={150,150},
		position = {764,362},
		editable=true,
		reactive=true,
		wants_enter=true,
		wrap=true,
		opacity = 255
	}

rect4 = Rectangle
	{
		name="rect4",
		border_color={0,17,114,57},
		border_width=1,
		color={0,17,114,88},
		size = {834,444},
		position = {796,540},
		opacity = 111
	}

img5 = Image
	{
		name="img5",
		src="assets/generic-app-icon.jpg",
		position = {160,354},
		clip = {0,0,480,270},
		opacity = 100
	}

g:add(img0,rect1,text2,text3,rect4,img5)