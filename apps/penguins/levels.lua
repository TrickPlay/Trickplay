local levels = {}

local generate = function(g,top)
	g:add(Image{src = "bg-slice-2", y = 0, size = {1920,542}, tile = {true,false}})
	if top then
		g:add(Image{src = "bg-sun", position = {math.random(300,1600),100}})
	end
	for i=15,20 do
		if rand(2) == 1 then
			a = Image{src = "tree-" .. rand(5)}
			a.position = {rand(20,1900),542}
			a.anchor_point = {a.w/2,a.h}
			a.scale = {i/rand(18,20),i/rand(18,20)}
			a.opacity = 255*i/20
			g:add(a)
		end
	end
	g.ice = Image{src = "ice-slice", position = {0,536}, size = {1920,55}, tile = {true,false}}
	g:add(g.ice)
	if top then
		g:add(Image{src = "igloo-back", position = {235,374,0}})
		g:loader1()
	else
		g:loader2()
	end
	g:add(Image{src = "floor-btm", position = {0,591}},
		  Image{src = "floor-btm", position = {1920,591}, scale = {-1,1}})
end

local free = function(self)
	self:unparent()
	if self.text1 then
		self.text1:unparent()
		self.text1 = nil
		self.text2:unparent()
		self.text2 = nil
	end
	for k,v in ipairs(self.children) do
		if v.free then
			v:free()
		else
			print('object ' .. v.gid .. ' ' .. (v.source.src or 'n/a') .. ' has no :free()')
		end
	end
end

local new = function (def)
	local group = Group()
	local a
	
	group.loader1 = loadfile("levels/"..def[1].."_1.lua")
	if def[1] > 0 then
		group.loader2 = loadfile("levels/"..def[1].."_2.lua")
	end
	
	group.free = free
	group.snow = def[2]
	group.name = def[3]
	group.id = #levels+1
	
	group.load = function()
		if group.loader2 then
			generate(group)
			
			for k,v in pairs(group.children) do
				v.y = v.y + 640
			end
			
			for k,v in pairs(group.children) do
				if v.insert then
					v:insert()
					v.insert = nil
				end
				if v.name then
					v.name = "_" .. v.name
				end
			end
			
			generate(group,true)
			--[[group.text1 = Text{text = def[4], font = "Sigmar 52px",
							x = 30,  y = -140,		color = "036BB4", opacity = 0}
			group.text2 = Text{text = def[6], font = "Sigmar 52px",
							x = 900, y = 640-130,	color = "036BB4", opacity = 0,
							alignment = "RIGHT", w = 990}
			group:add(group.text1,group.text2)]]
		else
			group:loader1()
		end
		
		for k,v in pairs(group.children) do
			if v.insert then
				v:insert()
				v.insert = nil
			end
			a = v.anchor_point
			v.bb = {l = v.x - a[1], r = v.x - a[1] + v.w*v.scale[1],
					t = v.y - a[2], b = v.y - a[2] + v.h*v.scale[2]}
			v.collides = v.reactive
			v.reactive = false
		end
	end
	
	return group
end

local toload = {
	{0,	2,"Splash Screen"},
	{1,	1,"Penguin In Motion"},
	{2,	1,"You're Probably Gonna Die"},
	{3,	2,"Ice Trios"},
	{4,	2,"Double Jump!"},
	{5,	1,"Great Heights"},
	{6,	2,"Cold Water"},
	{7,	3,"Bounce Me Higher"},
	{8,	1,"Pool Party"},
	{9,	3,"A Brief Exercise in Futility"},
	{10,2,"Blocks Stop for No Penguin"},
	{11,2,"The Incorrigible Mr. Seal"}}

for k,v in ipairs(toload) do
	levels[#levels+1] = new(v)
end

levels.this = levels[1]
levels.this:load()

screen:show()
screen:add(levels.this)
dolater(function() 
   snow(levels.this.snow)
   levels.this:find_child("image0"):grab_key_focus()
end)

levels.next = function(arg)
	local oldlevel = levels.this
	levels.this = levels[(levels.this.id) % #levels + (arg or 1)]
	
	levels.this:load()
	overlay.level:animate{opacity = 0, duration = 570, on_completed = function()
		overlay.level.text = (levels.this.id-1) .. ": " .. levels.this.name
		overlay.level:animate{opacity = 255, duration = 560}
	end}
	
	levels.this.y = 1120
	screen:add(levels.this)
	levels.this:lower_to_bottom()
	snow(levels.this.snow)
	
	if levels.this.id ~= 1 then
		screen:add(overlay.clone)
		overlay.clone.y = 1120
	end
	
	levels.this:animate{y = 0, duration = 1120, mode = "EASE_IN_OUT_QUAD"}
	overlay.clone:animate{y = 0, duration = 1120, mode = "EASE_IN_OUT_QUAD"}
	
	oldlevel:animate{y = -1300, duration = 1140, mode = "EASE_IN_OUT_QUAD", on_completed = function()
		oldlevel:free()
		if levels.this.id ~= 1 then
			overlay.clone:unparent()
			--levels.this.text1:animate{y = 20, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
			overlay.position = {0,0}
			row = 1
			penguin.skating:start()
			screen:grab_key_focus()
		else
			levels.this:find_child("image0"):grab_key_focus()
		end
		collectgarbage("collect")
	end}
	overlay:animate{y = -1300, duration = 1140, mode = "EASE_IN_OUT_QUAD"}
end

return levels