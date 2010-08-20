adapterTypes = {"Google","Yahoo","Google","Yahoo","Google","Yahoo","Google","Yahoo"}
adaptersTable = settings.adaptersTable or { "Google", "Yahoo", "Yahoo", "Google", "Google", "Google", "Google"}
searches = settings.searches or {"space", "dinosaurs", "dog", "cat", "jessica%20alba","national%20geographic", "mila%20kunis"}

adapters = {}
adapterTypesTable = {}

for i =1, #adaptersTable do
	adapters[i] = dofile("adapter/"..adaptersTable[i].."/adapter.lua")
	adapters[i][1].required_inputs.query = searches[i]
end

for i =1, #adapterTypes do
	adapterTypesTable[i] = dofile("adapter/"..adapterTypes[i].."/adapter.lua")
end


function loadCovers(i,search, start_index)
	if (adapters[i] ~= nil) then
		adapters[i]:loadCovers(i,search,start_index)
	end
end

function slideShow()
	
	screen:clear()
end

function deleteAdapter(index)

	index = #adapters+1 - index
	table.remove(adapters,index)
	table.remove(searches,index)
	table.remove(adaptersTable,index)
	model.album_group:clear()
	model.albums = {}
	Setup_Album_Covers()
end

