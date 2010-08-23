--dofile ("FlickrTest.lua")
dofile("Slideshow.lua")
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"


--calls adapters/sources, loads default images
function Setup_Album_Covers()
    model.albums = {}
    model.fp_slots = {}
    model.placeholders = {}


    assert(model.default,"default is not init yet")
	for i =1, #adapters do
		 loadCovers(i,searches[#adapters+1-i], math.random(5))
	end
    model.album_group.x = screen.width  / (NUM_VIS_COLS + 1)*.5

    --fill the thing with clones of the default-loading image
    for i = 1,NUM_ROWS do 
        model.placeholders[i] = {}
        model.albums[i] = {}
        model.fp_slots[i] = {}
        for j = 1,math.ceil(#adapters/NUM_ROWS) do
				local pic_index = ((((j-1)*NUM_ROWS+i)-1)%8+1)
            if ((j-1)*NUM_ROWS+i)<=#adapters then
            model.placeholders[i][j] = Clone{ source = model.default[pic_index], opacity =255}
            model.placeholders.opacity = 255
            model.fp_slots[i][j] = Group
            {
                name     = "Slot "..i.." "..j, 
                position = { PIC_W * (j-1), PIC_H * (i-1)+10 },
                clip     = { 0, 0,  PIC_W, PIC_H },
                opacity  = 255
            }
            --model.fp_slots[i][j]:add(Clone{ source = model.fp_backing, opacity = 255 })
            model.fp_slots[i][j]:add(model.placeholders[i][j])

            model.album_group:add(model.fp_slots[i][j])
            end
        end
    end
end

--Called by the adapter's on_complete function
function Load_Image(site,index)
    local i = (index-1)%NUM_ROWS +1
    local j = math.ceil(index/NUM_ROWS)
    
    print ("SITE: "..site)

    print("getting a pic for ",i,j,index)
		
	 if (site == "") then
	 		loadCovers(index, searches[#adapters+1-index], math.random(16))
    elseif model.albums[i] ~= nil and  model.albums[i][j] == nil then
        model.albums[i][j] = Image
        {
            async    = true,
            src      = site,
            --position = { PIC_W * (j-1), PIC_H * (i-1) },
            -- toss the filler image and scale it once loaded
            on_loaded = function(image,failed)
            	 if (failed) then					 	 
            	 		loadCovers(index, searches[#adapters+1-index], 1)
            	 		print ("FAILED MOFUCKA\n\n\n\n\n\n\n\n\n")
           	 
                elseif model.albums[i] ~= nil and model.albums[i][j] ~= nil and not failed then
                    print("loading pic at",i,j,index)
                    if model.placeholders[i] ~= nil and 
                       model.placeholders[i][j] ~= nil then

                        model.placeholders[i][j]:unparent()
                        model.placeholders[i][j] = nil
                    end
                    Scale_To_Fit(model.albums[i][j],
                                 model.albums[i][j].base_size,
                                 {PIC_W,PIC_H})
                    model.fp_slots[i][j]:add(model.albums[i][j])

                    --if model.fp_index[1] == i and model.fp_index[2] == j then
                        --model:notify()
                        model.albums[i][j]:lower_to_bottom()
                    --end
                end
            end
        }
    elseif model.albums[i] ~= nil and model.albums[i][j] ~= nil then

        model.swap_pic = Image{
            async    = true,
            src      = site,
            -- toss the filler image and scale it once loaded
            on_loaded = function(image,failed)
            	if not failed then
                if model.swap_pic == nil or model.albums[i] == nil or 
                                       model.albums[i][j] == nil or 
                                    model.swap_pic.loaded == false then 
                    --print("\n\nFailed to load")
                    model.swap_pic = nil 
                    model.swapping_cover = false
                else
                    Scale_To_Fit(model.swap_pic,
                                 model.swap_pic.base_size,
                                 {PIC_W,PIC_H})

                    model.fp_slots[i][j]:add(model.swap_pic)
                    model.albums[i][j]:raise_to_top()
                    model.albums[i][j]:animate{
                        duration     = 4*CHANGE_VIEW_TIME,
                        y            = model.albums[i][j].y + PIC_H,
                        opacity      = 0,
                        on_completed = function()
                            if model.albums[i] == nil or 
                               model.albums[i][j] == nil then 
                                model.swap_pic = nil 
                            else
                                if model.albums[i][j] ~= nil then
                                    model.albums[i][j]:unparent() 
                                    model.albums[i][j] = nil
                                end
                                model.albums[i][j] = model.swap_pic
                            end
                            model.swapping_cover = false
                        end
                    }
                end            
                end
            end
        }
    else
        model.swapping_cover = false
    end
end

function Scale_To_Fit(img,base_size,target_size)
    local scale_x = target_size[1] / base_size[1]
    local scale_y = target_size[2] / base_size[2]

--TODO: this might only apply when scaling down
    print( scale_x, scale_y )


    if scale_y > scale_x  then--[[(scale_x < scale_y and scale_y < 1) or
                       (scale_x > scale_y) then]]
print("chose y")
        img.size = {scale_y*base_size[1],scale_y*base_size[2]}

        img.clip  = { (img.w-target_size[1])/2, 0,
                      target_size[1],target_size[2]}
        img.anchor_point = { (img.w-target_size[1])/2,      0}
    else
print("chose x")
        img.size = {scale_x*base_size[1],scale_x*base_size[2]}

        img.clip  = { 0,(img.h-target_size[2])/2,
               target_size[1], target_size[1]}
          img.anchor_point = {  0,(img.h-target_size[2])/2        }

    end

end


