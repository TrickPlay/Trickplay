adapterTypes = {"Google","Yahoo"}
adaptersTable = { "Google", "Yahoo", "Yahoo", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Yahoo", "Google", "Google", "Google", "Google"}
searches = {"space", "dinosaur", "puppy", "cat", "interesting","robots", "family", "stuff", "funny", "cool", "music", "meganfox", "starwars", "twitter", "digg", "scene"}

picsTable = {}
adapters = {}
adapterTypesTable = {}



START_INDEX = 1
NUM_SLIDESHOW_IMAGES =16 

for i =1, #adaptersTable do
	adapters[i] = dofile("adapter/"..adaptersTable[i].."/adapter.lua")
	adapters[i][1].required_inputs.query = searches[i]
end

for i =1, #adapterTypes do
	adapterTypesTable[i] = dofile("adapter/"..adapterTypes[i].."/adapter.lua")
end


function loadCovers(i,search, start_index)
	adapters[i]:loadCovers(i,search,start_index)
end

function slideShow()
	
	screen:clear()
end

