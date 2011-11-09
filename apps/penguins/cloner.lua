_Image = Image
_Clone = Clone

local src = ""
local cubes = {"cube-128.png","cube-128-4.png"}

local factory = dofile("factory.lua")
local make = {
	--["fish-orange.png"]   = factory("fish-orange.png"),
	["cube-64.png"]			= factory("cube-64.png"),
	["cube-128.png"]		= factory("cube-128.png"),
	["cube-128-4.png"]		= factory("cube-128-4.png"),
	["floor-btm.png"]		= factory("floor-btm.png"),
	["ice-slice.png"]		= factory("ice-slice.png"),
	["igloo-back.png"]		= factory("igloo-back.png"),
	["sun.png"]				= factory("sun.png"),
	["bg-slice-2.png"]		= factory("bg-slice-2.png"),
	["tree-1.png"]			= factory("tree-1.png"),
	["tree-2.png"]			= factory("tree-2.png"),
	["tree-3.png"]			= factory("tree-3.png"),
	["tree-4.png"]			= factory("tree-4.png"),
	["tree-5.png"]			= factory("tree-5.png"),
	["icicles.png"]			= factory("icicles.png"),
	["explode-16.png"]		= factory("explode-16.png"),
	["explode-24.png"]		= factory("explode-24.png"),
	["explode-32.png"]		= factory("explode-32.png"),
	["explode-128.png"]		= factory("explode-128.png"),
	["splash.jpg"]			= factory("splash.jpg"),
	["cube-128-move.png"]	= factory("cube-128-move.png", function (obj)
			obj.x = -200
			obj.vx, obj.vy = 0.8, 0
			obj:animate{x = 2000, duration = 3000, loop = true}
			obj.moves = true
		end),
	["beach-ball.png"]	= factory("beach-ball.png", function (obj)
			local amp = 25
			local y = obj.y
			
			local anim = Timeline{loop = true, duration = 1000,
				on_new_frame = function(self,ms,t)
					amp = amp/2^(self.delta/self.duration) + 0.04
					obj.y = y + math.cos(math.pi*2*t)*amp
				
				end}
				
			obj.insert = function()
				y = obj.y
				anim:start()
			end
			
			obj.free = function(self)
				anim:stop()
				anim = nil
				self.freed = true
				self:unparent()
			end
			
			obj.collision = function()
				if penguin.y - penguin.h/2 > obj.y then
					penguin.kill(obj,player.skating.elapsed)
				else
					if anim.elapsed > anim.duration/2 then
						anim:advance(anim.duration-anim.elapsed)
					end
					anim:advance(math.asin((obj.y-y)/(amp+20))*anim.duration)
					amp = amp + 20
					penguin.jump(-20*math.sin(math.atan2(obj.y-penguin.y,obj.x-penguin.x)))
				end
			end
			obj.moves = true
		end),
	["river-left.png"]		= factory("river-left.png"),
	["river-right.png"]		= factory("river-right.png"),
	["river-slice.png"]		= factory("river-slice.png", function (obj)
			obj.insert = function(self)
				local group = self.parent
				local x, y, w = group.ice.x, group.ice.y, group.ice.w
				obj.y = y
			    group.ice.w = obj.x-34-x
				local img = Image{src = "assets/images/river-left.png", position = {obj.x-34,y}}
				group:add(img)
				img:raise(group.ice)
				img = Image{src = "assets/images/river-right.png", position = {obj.x+obj.w,y}}
				group:add(img)
				img:raise(group.ice)
				img = Image{src = "assets/images/ice-slice.png", position = {obj.x+obj.w+42,y},w = w-(obj.x+obj.w+42-x)}
				group:add(img)
				img:raise(group.ice)
				group.ice = img
				
			end
			obj.collision = function()
				penguin:sink()
			end
			dolater(function() end)
		end)
}

recycle = function(i,src)
	src = src:sub((src:find('/',10,true) or src:find('/',0,true) or 0)+1,-1)
	
	if src == cubes[1] then
		return make[cubes[rand(#cubes)]](i)
	end
	
	if make[src] then
		return make[src](i)
	end
end

Image = function(i)
	return recycle(i,i.src) or _Image(i)
end

Clone = function(i)
	while i.source.source do
		i.source = i.source.source
	end
	
	return recycle(i,i.source.src) or _Clone(i)
end