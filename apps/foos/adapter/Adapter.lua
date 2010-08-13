adaptersTable = { "Yahoo", "Google" }
picsTable = {}


START_INDEX = 1
NUM_SLIDESHOW_IMAGES = 10

function startAdapter(selection)
	dofile(adaptersTable[selection].."/adapter.lua")
end

function getPictureUrl()
	
	for k,v in pairs(picsTable) do
		print(k,v) 
	end
	return picsTable
end

function setUrls(source)
	-- this function would call something in the Slideshow App
	picsTable = source
end

startAdapter(2)
getPictureUrl()
