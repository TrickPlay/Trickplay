local levels = {}

local generate = function(g,top)
	g:add(Image{src = "bg-slice-" .. (g.bank == 2 and "3" or "2"), y = 0, size = {1920,542}, tile = {true,false}})
	if top and g.bank ~= 2 then
		g:add(Image{src = "bg-sun", position = {math.random(300,1600),100}})
	end
	for i=12,15 do
		if rand(2) == 1 then
			a = Image{src = "tree-" .. rand(5)}
			a.position = {rand(20,1900),542}
			a.anchor_point = {a.w/2,a.h}
			a.scale = {i/rand(13,15)*(rand(2)==1 and 1 or -1),i/rand(13,15)}
			a.opacity = 255*i/15
			g:add(a)
		end
	end
	g.ice = Image{src = "ice-slice", position = {0,536}, size = {1920,55}, tile = {true,false}}
	g:add(g.ice)
	if g.bank == 1 then
		g:add(Image{src = "snow-bank", position = {top and 1904 or 30,410}, scale = {top and -1.12 or 1.12,1}})
	end
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
			--print(v.gid .. ' ' .. (v.source and v.source.src or 'n/a') .. ' has no :free()')
		end
	end
end

local new = function (def)
	local group = Group()
	local a
	
	group.loader1 = loadfile("levels/"..def[1].."_1.lua")
	if def[1] ~= 0 and def[1] ~= 100 then
		group.loader2 = loadfile("levels/"..def[1].."_2.lua")
	end
	
	group.free = free
	group.snow = def[2]
	group.bank = def[3]
	group.name = def[4]
	group.id = #levels+1
	group.bridges = {[ground[1]] = 1}
	group.trans = ground[1]+640
	
	group.load = function()
		if group.loader2 then
			generate(group)
			
			for k,v in pairs(group.children) do
				v.y = v.y + 640
				if v.name then
					v.name = "_" .. v.name
				end
			end
			
			for k,v in pairs(group.children) do
				if v.insert then
					v:insert()
					v.insert = nil
				end
			end
			
			generate(group,true)
		else
			group:loader1()
		end
		
		for k,v in pairs(group.children) do
			if v.insert then
				v:insert(true)
				v.insert = nil
			end
			if v.bbox then
				v.bb = {l = v.x + v.bbox.l, r = v.x + v.bbox.r,
						t = v.y + v.bbox.t, b = v.y + v.bbox.b}
			end
			v.reactive = false
		end
	end
	
	return group
end

local toload = {
	{0,	2,0,"Splash Screen"},
	--
	--[[
	--]]
	{1,	1,0,"Penguin In Motion"},
	{2,	1,0,"You're Probably Gonna Die"},
	{3,	2,0,"Ice Trios"},
	{4,	2,0,"Double Jump!"},
	{5,	1,0,"Great Heights"},
	{6,	2,0,"Cold Water"},
	{7,	3,0,"Bounce Me Higher"},
	{8,	1,0,"Pool Party"},
	{9,	3,0,"A Brief Exercise in Futility"},
	{10,2,0,"Blocks Stop for No Penguin"},
	--
	{11,2,0,"Playtime With Mr. Seal"},
	{12,1,0,"And Now Bounce Me Lower"},
	{13,2,0,"Dangerous Airspace"},
	{14,2,0,"Return of Mr. Seal"},
	{15,2,0,"Squeeze Through"},
	{16,2,0,"Go the Distance"},
	{17,2,0,"Slide Across"},
	{18,2,0,"Double Bridges"},
	{19,3,0,"Bridge Over Cold Water"},
	{20,3,0,"March Of the Ice"},
	--
	{21,2,0,"A Good Swift Kick"},
	{22,1,0,"Stick the Landing"},
	{23,3,0,"Fish Hopper"},
	{24,1,0,"From the Top Now"},
	{25,1,1,"Penguin the Snowplow"},
	{26,1,1,"Too Cold For a Swim"},
	{27,1,1,"Snow Doubles"},
	{28,2,1,"Over the Top"},
	{29,3,1,"Can't See Enough"},
	{30,3,1,"Where's Walrus?"},
	--
	{31,1,0,"That Armor Looks Smashing"},
	{32,1,0,"Drop Like A Rock"},
	{33,1,1,"Smashing In the Snow"},
	{34,1,1,"Switch It Up"},
	{35,2,1,"The Switchboxes"},
	{36,3,0,"Puzzle Me This"},
	{37,3,0,"Double Switch"},
	{38,2,0,"Water World"},
	{39,2,0,"Moving Day"},
	{3,	2,2,"Into the Night"},
	--
	{8,	1,2,"Campfire Pool Party"},
	{10,1,2,"Can't See Them Coming"},
	{11,2,2,"The Nocturnal Wildlife"},
	{18,2,2,"Revisit the Bridges"},
	{19,3,2,"The Ice-Cold Precipice"},
	{22,1,2,"Night Landing"},
	{23,1,2,"Deception Again"},
	{24,3,2,"Same As Before"},
	{32,1,2,"Antartican Knights"},
	{50,3,2,"What Lurks In the Dark"},
}

for k,v in ipairs(toload) do
	levels[#levels+1] = new(v)
end

levels.this = levels[1]

screen:show()
screen:add(levels.this)

levels.cycle = false
levels.next = function(arg)
	levels.cycle = true
	local oldlevel = levels.this
	levels.this = levels[oldlevel.id % #levels + (oldlevel.id > 1 and arg or 1)]
	levels.this:load()
	levels.this.y = oldlevel.id == 1 and 1070 or 1120
	screen:add(levels.this)
	levels.this:lower(oldlevel)
	
	levels.this:animate{y = 0, duration = 1120, mode = "EASE_IN_OUT_QUAD"}
	oldlevel:animate{y = oldlevel.id == 1 and -1080 or -1300, duration = 1120,
					mode = "EASE_IN_OUT_QUAD", on_completed = function()
		oldlevel:free()
		collectgarbage("collect")
		if levels.this.id > 1 then
			row = 1
			penguin.skating:start()
			audio.play("slide")
		end
	end}
	
	overlay.next(oldlevel.id == 1)
	row = 1
end

return levels