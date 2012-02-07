local levels = {}
local noop = function() end
local a

Level = Class {
	extends = Layer,
	shared = {
		generate = function(self,top)
			self:add(Sprite{src = "bg-slice-" .. (self.bank == 2 and "3" or "2") .. ".png", y = 0, size = {1920,542}, tile = {true,false}})
			if top and self.bank ~= 2 then
				self:add(Sprite{src = "bg-sun.png", position = {math.random(300,1600),100}})
			end
			for i=12,15 do
				if rand(2) == 1 then
					a = Sprite{src = "tree-" .. rand(5) .. ".png"}
					a.position = {rand(20,1900),542}
					a.anchor_point = {a.w/2,a.h}
					a.scale = {i/rand(13,15)*(rand(2)==1 and 1 or -1),i/rand(13,15)}
					a.opacity = 255*i/15
					self:add(a)
				end
			end
			self.ice = Sprite{src = "ice-slice.png", position = {0,536}, size = {1920,55}, tile = {true,false}}
			self:add(self.ice)
			if self.bank == 1 then
				self:add(Sprite{src = "snow-bank.png", position = {top and 1904 or 30,410}, scale = {top and -1.12 or 1.12,1}})
			end
			if top then
				self:add(Sprite{src = "igloo-back.png", position = {235,374,0}})
				self:loader1()
			else
				self:loader2()
			end
			self:add(Sprite{src = "floor-btm.png", position = {0,591}},
					 Sprite{src = "floor-btm.png", position = {1920,591}, scale = {-1,1}})
		end,
		load = function(self)
			evInsert:clear()
			if self.loader2 then
				self:generate(false)
				for k,v in pairs(self.children) do
					v.y = v.y + 640
					v.row = 2
					if v.name then
						v.name = "_" .. v.name
					end
				end
				
				for k,v in pairs(self.children) do
					(evInsert[v] or noop)(v,self)
				end
				evInsert:clear()
				self:generate(true)
			else
				self:loader1()
			end
			
			for k,v in ipairs(self.children) do
				v.row = v.row ~= 0 and v.row or 1
				v.reactive = false
				(evInsert[v] or noop)(v,self)
			end
			
			for k,v in pairs(self.children) do
			end
			evInsert:clear()
		end,
		unload = function(self)
			self:unparent()
			self.ice = false
			for _,v in pairs(self.children) do
				evFrame[v] = nil
				(v.free or v.unparent)(v)
			end
		end
	},
	public = {
		snow = false,
		bank = false,
		name = "",
		id = -1,
		bridges = false,
		ice = false
	},
	new = function(self,def)
		self.loader1 = loadfile("levels/"..def[1].."_1.lua")
		if def[1] ~= 0 then
			self.loader2 = loadfile("levels/"..def[1].."_2.lua")
		end
		
		self.snow = def[2]
		self.bank = def[3]
		self.name = def[4]
		self.id = #levels+1
		self.bridges = {[ground[1]] = 1}
		self.trans = ground[1]+640
	end
}

local toload = {
	{0,	2,0,"Splash Screen"}, -- save/continue
	--
	--[[
	--]]
	{1,	1,0,"Learning To Fly"}, -- button press anim?
	{2,	1,0,"You're Probably Gonna Die"},
	{3,	2,0,"Ice Trios"},
	{4,	2,0,"Double Jump!"},
	{5,	1,0,"Great Heights"},
	{6,	2,0,"Cold Water"},
	{7,	3,0,"It Matters How You Bounce"},
	{8,	1,0,"Pool Party"},
	{9,	3,0,"A Brief Exercise in Futility"},
	{10,2,0,"Blocks Stop for No Penguin"}, -- time tweaking?
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
	levels[#levels+1] = Level(v)
end

levels.this = levels[1]

screen:show()
screen:add(levels.this)

levels.cycle = false
levels.next = function(arg)
	objectSet:clear()
	local oldlevel = levels.this
	if arg == 0 then
		if oldlevel.id == 1 then return end
		levels.cycle = false
		levels.this = levels[1]
	else
		levels.cycle = true
		levels.this = levels[oldlevel.id % #levels + (oldlevel.id > 1 and arg or 1)]
		settings.level = levels.this.id
	end
	settings.deaths = penguin.deaths
	levels.this:load()
	levels.this.y = oldlevel.id == 1 and 1070 or 1120
	screen:add(levels.this)
	levels.this:lower(oldlevel)
	
	levels.this:animate{y = 0, duration = 1120, mode = "EASE_IN_OUT_QUAD"}
	oldlevel:animate{y = oldlevel.id == 1 and -1080 or -1300, duration = 1120,
					mode = "EASE_IN_OUT_QUAD", on_completed = function()
		oldlevel:unload()
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