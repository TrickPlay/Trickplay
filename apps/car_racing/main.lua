
screen:show()

t=Image{src="road-straight.png",tile={false,true},h=40000}--Text{text="8",font="Sans 10000px",color="ffffff"}
r=Rectangle{color="733D1A",w=10000,h=t.h}
t.x=r.w/2
g=Group{}
g:add(r,t)
g.scale={4,4}
g.anchor_point = {r.w/2,t.h/2}
g.x_rotation={90,0,0}
g.position={screen.w/2,screen.h}
screen:add(g)

function calc_x_y_rot()
	g.x_rotation={90-5*math.cos(math.pi/180*g.y_rotation[1]),0,0}
	--g.y_rotation={5*math.sin(math.pi/180*g.z_rotation[1]),0,0}
	print(g.x_rotation[1],g.y_rotation[1],g.z_rotation[1])
end
local keys = {
	[keys.Up] = function()
		---[[
		g.anchor_point = {
			g.anchor_point[1]+20*math.sin(math.pi/180*g.y_rotation[1]),
			g.anchor_point[2]-20*math.cos(math.pi/180*g.y_rotation[1])
		}--]]
		--g.x=g.x+20*math.sin(math.pi/180*g.y_rotation[1])
		--g.z=g.z-10*math.cos(math.pi/180*g.y_rotation[1])
	end,
	[keys.Down] = function()
		---[[
		g.anchor_point = {
			g.anchor_point[1]-20*math.sin(math.pi/180*g.y_rotation[1]),
			g.anchor_point[2]+20*math.cos(math.pi/180*g.y_rotation[1])
		}--]]
		--g.x=g.x-20*math.sin(math.pi/180*g.y_rotation[1])
		--g.z=g.z+10*math.cos(math.pi/180*g.y_rotation[1])
	end,
	[keys.Left] = function()
		--g.z_rotation={g.z_rotation[1]-5,0,0}
		g.y_rotation={g.y_rotation[1]-5,0,0}
		--calc_x_y_rot()
	end,
	[keys.Right] = function()
		--g.z_rotation={g.z_rotation[1]+5,0,0}
		g.y_rotation={g.y_rotation[1]+5,0,0}
		--calc_x_y_rot()
	end,
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end