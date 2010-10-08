update_config()

shape = Group()


-- Determines kappa, necessary for circle with bezier curves
kappa = 4*((math.pow(2,.5)-1)/3)


----circle canvas size
c = Canvas { size = {radius*4, radius*4} }

----square canvas size
s = Canvas { size = {square_width,square_height} }

-- Function that draws the circle in 4 quarters

local function create_circle()

--- sets x and y of circle

center_x = radius*2
center_y = radius*2

-- Start point of circle creation

c:begin_painting()
c:new_path()

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
			 		 
-- Sets color and fill
c:set_source_color( shape_color )
c:fill(fill_bool)
c:stroke(stroke_bool)
-- Finishes painting on Canvas
c:finish_painting()
end


local function create_square()
s:begin_painting()
s:new_path()
s:line_to(square_width,0)
s:line_to(square_width,square_height)
s:line_to(0,square_height)
s:line_to(0,0)
-- Sets color and fill
s:set_source_color( shape_color )
s:fill(fill_bool)
s:stroke(stroke_bool)
-- Finishes painting on Canvas
s:finish_painting()
print("square drawn")
end

local function create_triangle()
end

function circle_generator()
-- Creates the circle
create_circle()
print("Circle Created")
shape:add(c)
end


function square_generator()
-- creates the Square
create_square()
print("Square Created")
shape:add(s)
end

