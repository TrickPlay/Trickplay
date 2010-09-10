adapterTypes  = {"Google","Yahoo","Flickr", "Photobucket"}
adaptersTable = settings.adaptersTable or 
                { "Google", "Yahoo", "Yahoo", "Google", "Google", 
                  "Yahoo", "Google"}
searches = settings.searches or 
           {"space", "dinosaurs", "dog", "cat", "jessica%20alba",
            "national%20geographic", "NFL"}
user_ids = settings.user_ids or {}
dontswap = false

adapters = {}
adapterTypesTable = {}

for i =1, #adaptersTable do
	adapters[i] = dofile("adapter/"..adaptersTable[i].."/adapter.lua")
	adapters[i][1].required_inputs.query = searches[i]
end

for i =1, #adapterTypes do
	adapterTypesTable[i] = dofile("adapter/"..adapterTypes[i].."/adapter.lua")
end


function loadCovers(child,slot,search, start_index)
        error("badddddddd user.... bad")
	if (adapters[i] ~= nil) then
		adapters[#adapters+1-i]:loadCovers(i,slot,search, start_index)
	end
end

function slideShow()
	screen:clear()
end

function deleteAdapter(index)
	
	
--[[
	model.album_group:clear()
	model.albums = {}
	Setup_Album_Covers()
--]]

    index = #adapters+1 - index
    table.remove(adapters,index)
    table.remove(searches,index)
    table.remove(adaptersTable,index)
end


