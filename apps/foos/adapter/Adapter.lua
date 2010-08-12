adaptersTable = { "Yahoo", "Google" }

START_INDEX = 1
NUM_SLIDESHOW_IMAGES = 10
selection = 2

dofile(adaptersTable[selection].."/adapter.lua")

function getUrls(source)
	-- this function would call something in the Slideshow App
	for k,v in pairs(source) do
		print(k,v) 
	end
end
