
-- Test Set up --


test_question = "Does the fractal slowly grow until it matches?"

function generate_test_image ()

	 local g = Group ()

	local rec = Rectangle{position = {0,0}, color = "000000", size = {screen.w, screen.h}}
	g:add (rec)

	local image = Image{ src = "/packages/"..test_folder.."/assets/ball.png" }
	g:add( image )
	image:hide()

	-- main  --
	local depths = {}
	local num = 1000
	local x0 = 0
	local y0 = -2
	local z0 = -1
	local h = 0.01
	local a = 10.0
	local b = 28.0
	local c = 8.0/ 3.0
	local n = 0
	local newFrameCount = 0
	local totalFrameCount = 0
	local myTimeline = Timeline()
	myTimeline.duration = 100000
	myTimeline.on_new_frame = function (timeline, elapsed, progress)
	    newFrameCount = newFrameCount + 1
	    if n < num then
		    n = n + 1
		    local x1=x0 + h * a * (y0-x0)
		    local y1=y0+h*(x0*(b-z0)-y0)
		    local z1=z0+h*(x0*y0-c*z0)

		    x0=x1
		    y0=y1
		    z0=z1
		    local scale = 5 + math.floor( z0*20 )
		    if (depths[scale] == nil) then depths[scale] = 1  end
		    if (depths[scale] < 30) then
			 ball = Clone{ source = image }
			 ball.position = { x0*10+screen.w/2, y0*10+screen.h*3/5 }
			 depth = scale*30+depths[scale]
			 depths[scale] = depths[scale] + 1
			 ball.scale= {scale * 0.001, scale * 0.001 }
			g:add(ball)
		    end
	    else 
		myTimeline:stop()
	    end
	end
	myTimeline:start()
	return g
end











