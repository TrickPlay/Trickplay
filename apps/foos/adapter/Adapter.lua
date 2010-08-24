adapterTypes = {"Google","Yahoo","Flickr","Yahoo","Google","Yahoo","Google","Yahoo"}
adaptersTable = settings.adaptersTable or { "Google", "Yahoo", "Yahoo", "Google", "Google", "Yahoo", "Google"}
searches = settings.searches or {"space", "dinosaurs", "dog", "cat", "jessica%20alba","national%20geographic", "NFL"}
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


function loadCovers(i,search, start_index)
	if (adapters[i] ~= nil) then
		adapters[#adapters+1-i]:loadCovers(i,search,start_index)
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

function Delete_Cover(index)
    local del_timeline = Timeline
    {
        name      = "Deletion animation",
        loop      =  false,
        duration  =  200,
        direction = "FORWARD",
    }

    function del_timeline.on_started()
--[[
        model.fp_slots[(index-1)%NUM_ROWS +1]
                      [math.ceil(index/NUM_ROWS)] = nil
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)]:unparent()
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)] = nil
--]]
        
    end
    function del_timeline.on_new_frame(t,msecs)
        local progress = msecs/t.duration

        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)].opacity = (1-progress)*255
        for ind = index, #adapters do
            local targ_i = (ind-1)%NUM_ROWS +1
            local targ_j = math.ceil(ind/NUM_ROWS)

            local curr_i = (ind+1-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind+1)/NUM_ROWS)

            if model.fp_slots[curr_i]        ~= nil and
               model.fp_slots[curr_i][curr_j] ~= nil then
                --model.fp_slots[new_i][new_j]:raise_to_top()
                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(curr_j-1) + progress * ((PIC_W*(targ_j-1)) -
                                                   (PIC_W*(curr_j-1))),
                    PIC_H*(curr_i-1)+10 + progress * ((PIC_H*(targ_i-1)) -
                                                      (PIC_H*(curr_i-1)))
                }
            end
        end
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
           model.front_page_index ~= 1 and ((#adapters-1)%NUM_ROWS) == 0 then

            --stupid edge case
            if model.front_page_index == 2 then
                model.album_group.x = (1-progress)*(-1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W)) - 10 + progress*10
            else
                model.album_group.x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W) - 10 + progress*PIC_W
            end
        end
    end
    function del_timeline.on_completed()
        model.fp_slots[(index-1)%NUM_ROWS +1]
                      [math.ceil(index/NUM_ROWS)] = nil
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)]:unparent()
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)] = nil

        for ind = index, #adapters do
            local targ_i = (ind-1)%NUM_ROWS +1
            local targ_j = math.ceil(ind/NUM_ROWS)

            local curr_i = (ind+1-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind+1)/NUM_ROWS)

            if  model.fp_slots[curr_i]        ~= nil and
                model.fp_slots[curr_i][curr_j] ~= nil then

                --model.fp_slots[new_i][new_j]:raise_to_top()
                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(targ_j-1) ,
                    PIC_H*(targ_i-1) + 10
                }
                model.fp_slots[targ_i][targ_j] =
                     model.fp_slots[curr_i][curr_j]
                model.albums[targ_i][targ_j] = model.albums[curr_i][curr_j]
---[[
            else
                model.fp_slots[targ_i][targ_j] = nil
                 model.albums[targ_i][targ_j] = nil
--]]
            end
        end
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
           model.front_page_index ~= 1 and ((#adapters-1)%NUM_ROWS) == 0 then
            model.front_page_index = model.front_page_index - 1
        end
        if index  == #adapters then
            local i = ((index-1)-1)%NUM_ROWS +1
            local j = math.ceil((index-1)/NUM_ROWS)
            
            
        end
        deleteAdapter(index)
        model:notify()
    end
    del_timeline:start()
end
