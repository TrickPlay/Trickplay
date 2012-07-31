local directory,all_posters_list = ...

local poster_names = dofile(directory.."list.lua")
local posters = {}

-- Create a queue with filenames and a destination into which to insert them when they're loaded
for i=1,#poster_names do
    table.insert( all_posters_list, { file = directory..poster_names[i], dest = posters } )
end

poster_names = nil

return posters
