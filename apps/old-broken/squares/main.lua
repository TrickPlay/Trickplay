
rectangle_size=100
rectangle_count=50
rectangle_speed=10

screen:add(Rectangle{color="000000",size=screen.size})
screen:show()

math.randomseed(os.time())

function reverse(d)
	local result=0
	while result==0 do
		result=math.random(rectangle_speed)
	end
	if d>0 then
		result=-result
	end
	return result
end

groups={}

for i=1,rectangle_count do
	local g=Group{position={math.random(screen.w-rectangle_size),math.random(screen.h-rectangle_size)}}
	local r=Rectangle{size={rectangle_size,rectangle_size},color={math.random(255),math.random(255),math.random(255),0.7*255}}
	local t=Text{font="DejaVuSans 30px",text=tostring(i),color="000000",position={rectangle_size/2,rectangle_size/2}}
	t.anchor_point={t.w/2,t.h/2}
	g:add(r,t)
	screen:add(g)
	g.extra.dx=reverse(math.random(-rectangle_speed,rectangle_speed))
	g.extra.dy=reverse(math.random(-rectangle_speed,rectangle_speed))
	table.insert(groups,g)
end

function idle.on_idle()

	function clamp(d,min,max)
		if d < min then
			return true,min
		elseif d > max then
			return true,max
		else
			return false,d
		end
	end

	local over	
	
	for _,g in ipairs(groups) do
	
		local e=g.extra
		
		over,g.x=clamp(g.x+e.dx,0,screen.w-rectangle_size)
		
		if over then
			e.dx=reverse(e.dx)
		end
	
		over,g.y=clamp(g.y+e.dy,0,screen.h-rectangle_size)

		if over then
			e.dy=reverse(e.dy)
		end
		
	end

end



