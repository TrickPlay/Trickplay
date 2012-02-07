local g = ... 


--[[
best	fewest deaths
level	current level
deaths	current deaths

]]

local z, zwire = Sprite{src = "logo-z.png", y = 800}, Sprite{src = "logo-z-wire.png", y = 600, h = 200}
local p, pwire = Sprite{src = "logo-p.png", y = 700}, Sprite{src = "logo-p-wire.png", y = 600, h = 100}
local zg, pg = Layer{scale = {2,2}, anchor_point = {256,0}, x = 940, y = -2420},
			   Layer{scale = {2,2}, anchor_point = {188,0}, x = 960, y = -2400}
local za, zt, pa, pt = 0, 0, 0, 0
zg:add(z,zwire)
pg:add(p,pwire)

evFrame[zg] = function(self,delta,ms)
	zt = (zt+delta/2000)%1
	if za > 0 then
		zg.z_rotation = {sin(2*pi*zt)*za,0,0}
		zg.scale = {2,2-sin(2*pi*zt)*za/150}
		za = za/2^(delta/1000)+rand(3)/2000
	end
end

evFrame[pg] = function(self,delta,ms)
	pt = (pt+delta/2000)%1
	if pa > 0 then
		pg.z_rotation = {-sin(2*pi*pt)*pa,0,0}
		pg.scale = {2,2+sin(2*pi*pt)*pa/150}
		pa = pa/2^(delta/1000)+rand(3)/2000
	end
end

local EIQ, EOQ = "EASE_IN_QUAD", "EASE_OUT_QUAD"

local sign = function()
	audio.play("theme")
	zg:animate{y = -1420, duration = 1000, mode = EIQ, on_completed = function()
		zt, za = 0, 4
		zg:animate{y = -1450, duration = 200, mode = EOQ, on_completed = function()
			zg:animate{y = -1420, duration = 200, mode = EIQ}
		end}
	end}
	
	Timer{interval = 200, on_timer = function(self)
		pg:animate{y = -1400, duration = 1000, mode = EIQ, on_completed = function()
			pt, pa = 0, 4
			pg:animate{y = -1430, duration = 200, mode = EOQ, on_completed = function()
				pg:animate{y = -1400, duration = 200, mode = EIQ}
			end}
		end}
		self:stop()
	end}
end

local a
local moving = Layer()
for i=20,30 do
	a = Image{src = "tree-" .. rand(5) .. ".png", position = {rand(20,2200),922}, opacity = 255}
	a.anchor_point = {a.w/2,a.h}
	a.scale = {(i-10)/rand(19,20)*(rand(2)==1 and 1 or -1),(i-10)/rand(19,20)}
	a.vx = -i/200
	a.nx = nrand(0.02)
	moving:add(a)
end

evFrame[moving] = function(self,delta,ms)
	for _,v in pairs(moving.children) do
		v.x = v.x + (v.vx+v.nx)*delta
		if v.x+v.w < 0 then
			v.x = 2000+rand(400)
			v.nx = nrand(0.02)
		end
	end
end

local peng = Sprite{src = "penguin.png", position = {-500,820}}
local bubble = Layer{x = 500, y = 40}

local best
t = 0
g:add(Sprite{src = "bg-slice-2.png", y = 0, size = {1920,1080}, tile = {true,false}})
g:add(Sprite{src = "bg-sun.png", position = {200,100}})
g:add(moving)
g:add(Sprite{src = "ice-slice.png", position = {0,916}, size = {1920,55}, tile = {true,false}})
g:add(Sprite{src = "floor-btm.png", position = {0,971}},
		Sprite{src = "floor-btm.png", position = {1920,971}, scale = {-1,1}})
g:add(peng)
g:add(zg,pg)
if levels.cycle then
	settings.level = nil
	audio.play("applause")
	peng.x = 760
	bubble:add(Sprite{src = "thought-bubble.png", scale = {2,2}},
			Text{x = 50,  y = 70,  w = 800, alignment = "CENTER", font = "Sigmar 80px", text = "You Killed Me"},
			Text{x = 150, y = 110, w = 600, alignment = "CENTER", font = "Sigmar 200px", text = penguin.deaths},
			Text{x = 150, y = 350, w = 600, alignment = "CENTER", font = "Sigmar 80px",
				text = "Time" .. (penguin.deaths == 1 and "!" or "s!")})
	g:add(bubble)
	g.swap = function()
		if not settings.best or penguin.deaths < settings.best then
			settings.best = penguin.deaths
		end
		if best and best.text ~= tostring(settings.best) then
			best:animate{duration = 500, opacity = 0, on_completed = function()
				best.text = settings.best
				best:animate{duration = 500, opacity = 255}
			end}
		end
		bubble:animate{y = 80, opacity = 0, duration = 300}
		sign()
		g.swap = nil
	end
else
	peng:animate{x = 1040, mode = "EASE_OUT_BACK", duration = 15000}
	sign()
end
g:add(Sprite{src = "start-sign.png", position = {1470,670}})

if settings.level then
	local sdark = Sprite{src = "start-sign-dim.png", position = {1470,670}, opacity = 0}
	local cdark = Sprite{src = "continue-sign-dim.png", position = {1470,850}}
	g:add(sdark,Sprite{src = "continue-sign.png", position = {1470,850}},cdark)
	g.anim = AnimationState{duration = 500, transitions = {
		{source = 1, target = 0, keys = {{sdark,"opacity",255},{cdark,"opacity",0}}},
		{source = 0, target = 1, keys = {{sdark,"opacity",0},{cdark,"opacity",255}}}, }}
	g.anim.state = 0
end
g:add(Sprite{src = "snow-bank.png", position = {2200,940}, scale = {-1.4,1.05}})

if settings.best then
	g:add(Text{font = "Sigmar 42px", color = "ffffff", text = "Best Score",
		alignment = "CENTER", x = 1500, y = 20, w = 400})
	best = Text{font = "Sigmar 120px", color = "ffffff", text = settings.best,
		alignment = "CENTER", x = 1500, y = 30, w = 400}
	g:add(best)
end

Event(zg,'free'):add(function()
	g.anim = nil
	evFrame:drop(zg,pg,moving)
end)