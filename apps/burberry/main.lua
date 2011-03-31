screen:show()
screen_w = screen.w
screen_h = screen.h
local curr_page = "front_page"
function change_page_to(next_page)
	
	assert(_G[next_page] ~= nil,"Next page \""..next_page.."\" does not exist")
	
	animate_list[_G[curr_page].func_tbls.fade_out_to[next_page]]  = _G[curr_page]
	animate_list[_G[next_page].func_tbls.fade_in_from[curr_page]] = _G[next_page]
	
	curr_page = next_page
	
end

dofile("App_Loop.lua")
dofile("Utils.lua")
dofile("FrontPage.lua") -- global: front_page
--dofile("CollectionPage.lua")
dofile("CategoryPage.lua")

screen:add(
	category_page.group,
	--collection_page.group,
	front_page.group
)

function key_handler(self,key)
	if _G[curr_page].keys[key] == nil then
		print("\""..curr_page.."\" does not support that key.")
	else
		_G[curr_page].keys[key](_G[curr_page])
	end
end

function restore_keys()
	screen.on_key_down = key_handler
end

function lose_keys()
	screen.on_key_down = nil
end

restore_keys()