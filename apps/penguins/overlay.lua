local overlay = Group{name = "overlay", y = -1200}
overlay.deaths = Text{font = "Sigmar 68px", x = 240,  y = 568, color = "8bbbe0", text = "0"}
overlay.level  = Text{font = "Sigmar 68px", x = 350, y = 568, width = 1400, alignment = "CENTER", color = "ffffff"}
overlay.effects = Group{name = "effects"}
overlay.armor = Group{name = "armor"}

overlay:add(overlay.effects,penguin,
			Image{src = "assets/igloo-front.png", y = 134},
			Image{src = "assets/death-bug.png", x = 150, y = 591},
			overlay.armor,overlay.deaths,overlay.level)
screen:add(overlay)
overlay.clone = _Clone{source = overlay, name = "overclone"}

local quad = "EASE_IN_OUT_QUAD"
local anim = Animator{properties = {
	{source = overlay,		  name = "y", keys = {{0,quad,-1300}}},
	{source = overlay.clone,  name = "y", keys = {{0,quad,0}}},
	{source = snowbank,		  name = "y", keys = {{0,quad,-1300}}},
	{source = snowbank.clone, name = "y", keys = {{0,quad,0}}},
	{source = overlay.level,   name = "opacity", keys = {{0,255},{0.5,0},{1,255}}},
	{source = overlay.effects, name = "opacity", keys = {{0,255},{0.5,0},{1,255}}},
	{source = overlay.armor,   name = "opacity", keys = {{0,255},{0.5,0},{1,255}}} },
	timeline = Timeline{duration = 1120, on_completed = function(self)
		if levels.this.id == 1 then return end
		overlay.y = 0
		if levels.this.bank > 0 then
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

overlay.next = function(first)
	snow(levels.this.snow)
	if levels.this.id > 1 then
		screen:add(overlay.clone)
		overlay.clone.y = first and 1080 or 1120
		if levels.this.bank > 0 then
			screen:add(snowbank.clone)
			snowbank.clone.y = first and 1080 or 1120
		end
	end
	anim:start()
	timer:start()
end

return overlay