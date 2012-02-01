local overlay = Group{name = "overlay", y = -1200}
overlay.deaths = Text{font = "Sigmar 68px", x = 240,  y = 568, color = "8bbbe0", text = "0"}
overlay.level  = Text{font = "Sigmar 68px", x = 350, y = 568, width = 1400, alignment = "CENTER", color = "ffffff"}
overlay.effects = Group{name = "effects"}
overlay.armor = Group{name = "armor"}

local dx, dy = 0, 0
local d = {_Image{src = "assets/dark3.png", scale = {3,3}},
	Rectangle{color = "000000", w = 1920},
	Rectangle{color = "000000", h = 768},
	Rectangle{color = "000000", w = 1920},
	Rectangle{color = "000000", h = 768},
	Rectangle{color = "000000", w = 1920, h = 1080, opacity = 0}}
darkness = Group{name = "darkness", opacity = 0}
darkness:add(d[1],d[2],d[3],d[4],d[5],d[6])

overlay:add(overlay.effects,penguin,
	Image{src = "assets/igloo-front.png", y = 134},overlay.armor,
	Image{src = "assets/death-bug.png", x = 150, y = 591},
	overlay.deaths,overlay.level)
screen:add(overlay,darkness)
overlay.clone = _Clone{source = overlay, name = "overclone"}

darkness.dark = AnimationState{ duration = 500, transitions = {
	{source = "*", target = 0,keys = {
		{d[6],"opacity","EASE_IN_QUAD",0}}},
	{source = "*", target = 1,keys = {
		{d[6],"opacity","EASE_OUT_QUAD",255}}},
	{source = "*", target = 2,keys = {
		{d[6],"opacity","EASE_IN_QUAD",255}}}
}}
darkness.dark.state = 0

local quad = "EASE_IN_OUT_QUAD"
local anim = Animator{properties = {
	{source = overlay,		   name = "y", keys = {{0,quad,-1300}}},
	{source = overlay.clone,   name = "y", keys = {{0,quad,0}}},
	{source = snowbank,		   name = "y", keys = {{0,quad,-1300}}},
	{source = snowbank.clone,  name = "y", keys = {{0,quad,0}}},
	{source = overlay.level,   name = "opacity", keys = {{0,255},{0.5,0},{1,255}}},
	{source = overlay.effects, name = "opacity", keys = {{0,255},{0.5,0},{1,255}}},
	{source = overlay.armor,   name = "opacity", keys = {{0,255},{0.5,0},{1,255}}} },
	timeline = Timeline{duration = 1120, on_completed = function(self)
		if levels.this.id == 1 then return end
		overlay.y = 0
		if levels.this.bank == 1 then
			snowbank.y = 0
			snowbank:show()
		else
			snowbank:hide()
		end
		overlay.clone:unparent()
		snowbank.clone:unparent()
	end}}
	
local timer = Timer{on_timer = function(self)
	overlay.level.text = (levels.this.id-1) .. ": " .. levels.this.name
	overlay.effects.level = levels.this.id
	for k,v in ipairs(overlay.effects.children) do
		v:free()
	end
	for k,v in ipairs(overlay.armor.children) do
		if v.level ~= levels.this.id then
			v:free()
		else
			v.opacity = 255
		end
	end
	self:stop()
end}
timer.interval = 560

local a
step[darkness] = function(delta)
	if darkness.opacity > 0 then
		a = anim.timeline.is_playing and -160*(overlay.y+1300)/1140 or overlay.y
		px, py = penguin.x+45-384, penguin.y+a+65-384
		dx = floor(min(max(-384,px),1920-384)) --[[-(px-dx)/2^(delta/100)]]
		dy = floor(min(max(-384,py),1080-384)) --[[-(py-dy)/2^(delta/100)]]
		d[1].x, d[1].y = dx, dy
		d[2].h = dy
		d[3].x, d[3].y, d[3].w = dx+768, dy, 1920-768-dx
		d[4].y, d[4].h = dy+768, 1080-768-dy
		d[5].y, d[5].w = dy, dx
	end
end

overlay.next = function(first)
	snow(levels.this.snow)
	if levels.this.id > 1 then
		screen:add(overlay.clone)
		overlay.clone:raise(overlay)
		overlay.clone.y = first and 1080 or 1120
		if levels.this.bank == 1 then
			screen:add(snowbank.clone)
			snowbank.clone.y = first and 1080 or 1120
		end
		if levels.this.bank == 2 then
			darkness:animate{opacity = 232, duration = 1120}
		elseif darkness.opacity ~= 0 then
			darkness:animate{opacity = 0, duration = 1120}
		end
	elseif darkness.opacity ~= 0 then
		darkness:animate{opacity = 0, duration = 1120}
	end
	anim:start()
	timer:start()
end

local anim2 = Animator{duration = 500, properties = {
	{source = overlay,  name = "y", keys = {{0,quad,-160}}},
	{source = snowbank, name = "y", keys = {{0,quad,-160}}} }}

overlay.lift = function()
	anim2:start()
	levels.this:animate{y = -160, duration = 500, mode = "EASE_IN_OUT_QUAD"}
end

return overlay