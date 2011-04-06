
screen:show()
clone_sources = Group{name="clone_sources"}
screen:add(clone_sources)
clone_sources:hide()
dofile("Level.lua")


local keys = {
	[keys.Up] = function()
		world:move(60)
	end,
	[keys.Down] = function()
		world:move(-20)
	end,
	[keys.Left] = function()
		
		world:rotate_by(-5)
	end,
	[keys.Right] = function()
		world:rotate_by(5)
	end,
}
function screen:on_key_down(k)
	if keys[k] then keys[k]() end
end