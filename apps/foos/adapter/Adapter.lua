adaptersTable = { "Yahoo", "Google" }
picsTable = {}


START_INDEX = 1
NUM_SLIDESHOW_IMAGES = 10

function startAdapter(selection)
	dofile(adaptersTable[selection].."/adapter.lua")
end

function getPictureUrl()
	return picsTable
end

function getUrls(source)
	-- this function would call something in the Slideshow App
	picsTable = source
	for k,v in pairs(source) do
		print(k,v) 
	end
end

startAdapter(2)
