adaptersTable = { "Google", "Yahoo", "Yahoo", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Yahoo", "Google", "Google", "Google", "Google"}
picsTable = {}
adapters = {}

START_INDEX = 1
NUM_SLIDESHOW_IMAGES =16 

for i =1, #adaptersTable do
	adapters[i] = dofile("adapter/"..adaptersTable[i].."/adapter.lua")
end

function loadCovers(i,search, start_index)
	adapters[i]:loadCovers(i,search,start_index)
	adapters[i][1].required_inputs.query = search
end

function slideShow()
	
	screen:clear()
end

