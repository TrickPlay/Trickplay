
screen:show()

t1=Image{src="road-straight.png",tile={true,true},w=500,h=40000}--Text{text="8",font="Sans 10000px",color="ffffff"}
r1=Rectangle{color="733D1A",w=10000,h=t1.h}
t1.x=r1.w/2
g1=Group{}
g1:add(r1,t1)
g1.scale={4,4}
g1.anchor_point = {r1.w/2,t1.h/2}
g1.x_rotation={90,0,0}
g1.position={screen.w/2,screen.h}

t2=Image{src="road-curve-2.png"}--,tile={true,true},w=500,h=40000}--Text{text="8",font="Sans 10000px",color="ffffff"}
r2=Rectangle{color="B13E0F",w=10000,h=t2.h}
t2.x=r2.w/2
g2=Group{}
g2:add(r2,t2)
g2.scale={12,12}
g2.anchor_point = {r2.w/2,t2.h+t1.h/2}
g2.x_rotation={90,0,0}
g2.position={screen.w/2,screen.h}

screen:add(g1,g2)


local keys = {
	[keys.Up] = function()
		---[[
		g1.anchor_point = {
			g1.anchor_point[1]+60*math.sin(math.pi/180*g1.y_rotation[1]),
			g1.anchor_point[2]-60*math.cos(math.pi/180*g1.y_rotation[1])
		}
		g2.anchor_point = {
			g2.anchor_point[1]+60*math.sin(math.pi/180*g2.y_rotation[1]),
			g2.anchor_point[2]-60*math.cos(math.pi/180*g2.y_rotation[1])
		}
		--]]
		
		--g.x=g.x+20*math.sin(math.pi/180*g.y_rotation[1])
		--g.z=g.z-10*math.cos(math.pi/180*g.y_rotation[1])
	end,
	[keys.Down] = function()
		---[[
		g1.anchor_point = {
			g1.anchor_point[1]-20*math.sin(math.pi/180*g1.y_rotation[1]),
			g1.anchor_point[2]+20*math.cos(math.pi/180*g1.y_rotation[1])
		}
		g2.anchor_point = {
			g2.anchor_point[1]-20*math.sin(math.pi/180*g2.y_rotation[1]),
			g2.anchor_point[2]+20*math.cos(math.pi/180*g2.y_rotation[1])
		}--]]
		--g.x=g.x-20*math.sin(math.pi/180*g.y_rotation[1])
		--g.z=g.z+10*math.cos(math.pi/180*g.y_rotation[1])
	end,
	[keys.Left] = function()
		--g.z_rotation={g.z_rotation[1]-5,0,0}
		g1.y_rotation={g1.y_rotation[1]-5,0,0}
		g2.y_rotation={g2.y_rotation[1]-5,0,0}
		--calc_x_y_rot()
	end,
	[keys.Right] = function()
		--g.z_rotation={g.z_rotation[1]+5,0,0}
		g1.y_rotation={g1.y_rotation[1]+5,0,0}
		g2.y_rotation={g2.y_rotation[1]+5,0,0}
		--calc_x_y_rot()
	end,
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end