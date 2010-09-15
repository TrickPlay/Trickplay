-- Sets Canvas size
c = Canvas { size = {220,220}}

-- Determines kappa, necessary for circle with bezier curves
kappa = 4*((math.pow(2,.5)-1)/3)

-- Function that draws the circle in 4 quarters
local function create_circle()

-- Start point of circle generation

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


local function circle_generator()

-- Sets radius of circle
radius = math.random(10, 20)

-- Sets x and y of the center of circle
center_x = 110
center_y = 110

-- Begins painting on Canvas
c:begin_painting()
c:new_path()

-- Creates the circle
create_circle()
print("Circle Created")

-- Sets color and fill
c:set_source_color( "f7f7f7" )
c:fill(true)

-- Finishes painting on Canvas
c:finish_painting()

end


print("Generating Circle...")
circle_generator()
print("Done!")
c:clear_surface()
print("Surface Cleared")


-- Adds the Canvas to the screen
circle = Group()
circle:add(c)