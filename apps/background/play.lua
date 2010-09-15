c = Canvas { size = {1920,1080}}

kappa = 4*((math.pow(2,.5)-1)/3)

local function create_circle()



c:move_to( center_x, center_y-radius )

c:curve_to(  center_x+kappa*radius , center_y-radius ,
			center_x+radius , center_y-kappa*radius ,
			center_x+radius , center_y
			 )

c:curve_to(  center_x+radius , center_y+kappa*radius ,
			center_x+kappa*radius , center_y+radius ,
			center_x , center_y+radius
			)
			 
c:curve_to(  center_x-kappa*radius , center_y+radius ,
			center_x-radius , center_y+radius*kappa ,
			center_x-radius , center_y
			 )

c:curve_to(  center_x-radius , center_y-radius*kappa,
			center_x-radius*kappa , center_y-radius ,
			center_x , center_y-radius
			 )
end

--circles = {}
--circles[1] = {}
--circles[1][1] = 10
--circles[1][2] = 20
--circles[1][3] = 30
--
--num_circ = 1
--valid = 0
--
--local function checkforcollision(circ)
--print("Hello cicasdfeaw")
--print(num_circ)
--print(circles[num_circ][1])
--for j=1, num_circ do
--  dist = math.sqrt((circles[j][1] - circ.x)^2 + (circles[j][2] - circ.y)^2)
--  print(circles[j][2])
--  if dist < circles[j][2] + circ.r  then
--    valid = 1
--    return
--  end
--end
--valid = 0
--end
--
--
local function circle_generator()
radius = 30
center_x = math.random(20, 1920)
center_y = math.random(20, 1060)
--
--circle = {x = center_x, y = center_y, r = radius}
--checkforcollision(circle)
--if valid == 1 then
--print("asdfasdf")
--  return
--end
--num_circ = num_circ + 1
--circles[num_circ] = {}
--circles[num_circ][1] = center_x
--circles[num_circ][2] = center_y
--circles[num_circ][3] = r


print("Radius:",radius, "center x:", center_x, "center y:", center_y)

c:begin_painting()

c:new_path()

create_circle()
print("Circle Created")

-- sets color of filled circle

--c:set_source_color( "f7f7f7" )
--c:fill(true)



-- Sets width of line and color of stroked circle.

c:set_line_width( 10 )
c:set_source_color( "f7f7f7" )
c:stroke( true )



c:finish_painting()


end

local function random_circles()
	for i = 1,2 do
		circle_generator(i)
	end
	c:clear_surface()
	print("Surface Cleared")
end


function screen:on_key_down(key)

	if(key == keys.Up or key == keys.Down) then
		print("Generating Circles...")
		random_circles()
		print("Done!")
	end
	
	
end


screen:add(c)
screen:show()