screen:show()

local curr_page = "front_page"
function change_page_to(next_page)
	
	assert(_g[next_page] ~= nil,"Next page \""..next_page.."\" does not exist")
	
	_g[curr_page].func_tbls.fade_out_to[next_page]
	_g[next_page].func_tbls.fade_in_from[curr_page]
	
	curr_page = next_page
	
end

dofile("App_Loop.lua")
dofile("FrontPage.lua")

function screen:on_key_down(key)
	if _g[curr_page].keys[key] == nil then
		print("Page \""..curr_page.."\" does not support that key.")
	else
		_g[curr_page].keys[key]()
	end
end