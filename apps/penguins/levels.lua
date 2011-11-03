local levels = {}
local bg_trees = {
	"assets/images/tree-1.png",
	"assets/images/tree-2.png",
	"assets/images/tree-3.png",
	"assets/images/tree-4.png",
	"assets/images/tree-5.png"}

local generate = function(g,top)
	g:add(Image{src = "assets/images/bg-slice-2.png", y = 0, size = {1920,542}, tile = {true,false}})
	if top then
	  g:add(Image{src = "assets/images/sun.png", position = {math.random(300,1600),100}})
	end
	for i=15,20 do
		if rand(2) == 1 then
			a = Image{src = bg_trees[rand(5)]}
			a.position = {rand(20,1900),542}
			a.anchor_point = {a.w/2,a.h}
			a.scale = {i/rand(18,20),i/rand(18,20)}
			a.opacity = 255*i/20
			g:add(a)
		end
	end
	g.ice = Image{src = "assets/images/ice-slice.png", position = {0,536}, size = {1920,55}, tile = {true,false}}
	g:add(g.ice)
	if top then
		g:add(Image{src = "assets/images/igloo-back.png", position = {235,374,0}})
		g:loader1()
	else
		g:loader2()
	end
	g:add(Image{src = "assets/images/floor-btm.png", position = {0,591}},
		  Image{src = "assets/images/floor-btm.png", position = {1920,591}, scale = {-1,1}})
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
	
	group.loader1 = loadfile("levels/"..def[3]..".lua")
	if def[5] then
		group.loader2 = loadfile("levels/"..def[5]..".lua")
	end
	
	group.free = free
	group.name = def[1]
	group.snow = def[2]
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
				if (v.name) then
					v.name = "_" .. v.name
				end
			end
			
			generate(group,true)
			group.text1 = Text{text = def[4], font = "Sigmar 52px",
							x = 30,  y = -140,		color = "036BB4", opacity = 0}
			group.text2 = Text{text = def[6], font = "Sigmar 52px",
							x = 900, y = 640-130,	color = "036BB4", opacity = 0,
							alignment = "RIGHT", w = 990}
			group:add(group.text1,group.text2)
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
			v.collide = v.reactive
			v.reactive = false
		end
	end
	
	return group
end

local toload = { -- name, snow, row1, txt1, row2, txt2
	{"splash screen",2,		"splash",""},
	{"Penguin In Motion",1,	"level1_1","This is Penguin.",	"level1_2","Press [OK] to watch him soar!"},
	{"Don't Touch",1,		"level2_1","Can you make it?",	"level2_2","Watch your head"},
	{"Ice Trios",2,			"level3_1","Bet you can't.",	"level3_2","Don't Jump Too Far"},
	{"Double Jump!",2,		"level4_1","Mind the Gap",		"level4_2","Press [OK] in Midair!"},
	{"Tall Stuff",1,		"level5_1","Too Tall for You?",	"level5_2","Almost There"},
	{"Cold Water",2,		"level6_1","Don't Fall In ...",	"level6_2","Careful Now"},
	{"Inflation",3,			"level7_1","Reach New Heights",	"level7_2","Further Than Ever"},
	{"Evasive Action",3,	"level8_1","Triple Jump",		"level8_2","Blocks Stop for No Penguin"}}

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

levels.next = function()
	local oldlevel = levels.this
	levels.this = levels[(levels.this.id) % #levels + 1]
	
	levels.this:load()
	overlay.level:animate{opacity = 0, duration = 570, on_completed = function()
		overlay.level.text = "Level " .. (levels.this.id-1) .. ": " .. levels.this.name
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
			levels.this.text1:animate{y = 20, opacity = 255, duration = 500, mode = "EASE_IN_OUT_QUAD"}
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