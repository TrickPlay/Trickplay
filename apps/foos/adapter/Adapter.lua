adaptersTable = { "Yahoo", "Google" }
picsTable = {}


START_INDEX = 1
NUM_SLIDESHOW_IMAGES =16 

function startAdapter(selection)
print("\n\n\n\n\n shit")
	dofile("adapter/"..adaptersTable[selection].."/adapter.lua")
end

function getPictureUrl()
        if type(picsTable[1]) == "string" then 
    		return picsTable
        else
            return {}
        end
end

function getUrls(source)
	-- this function would call something in the Slideshow App
	picsTable = source
	for k,v in pairs(source) do
		print(k,v) 
	end
end

--startAdapter(2)
