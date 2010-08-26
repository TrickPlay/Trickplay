--dofile ("FlickrTest.lua")
--dofile("Slideshow.lua")
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0
loadGroup = {}

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
        model.albums[i]       = {}
        model.fp_slots[i]     = {}

        for j = 1,math.ceil(#adapters/NUM_ROWS) do
            local pic_index = ((((j-1)*NUM_ROWS+i)-1)%8+1)
            if ((j-1)*NUM_ROWS+i)<=#adapters then
                model.placeholders[i][j] = Clone
                {
                    source  = model.default[math.random(1,8)],
                    opacity = 255
                }
                model.placeholders[i][j].opacity = 255
                model.fp_slots[i][j] = Group
                {
                    position = { PIC_W * (j-1), PIC_H * (i-1)+10 },
                    clip     = { 0, 0,  PIC_W, PIC_H },
                    opacity  = 255
                }
                model.fp_slots[i][j]:add(model.placeholders[i][j])

                model.album_group:add(model.fp_slots[i][j])
            end
        end
    end
end

--Called by the adapter's on_complete function
function Load_Image(site,index)
    print("Load_Image(",site,",",index,")")
    -- 2D version of the index
    local i = (index-1)%NUM_ROWS +1
    local j = math.ceil(index/NUM_ROWS)
    --keep a local version for the callbacks
    local slot  = model.fp_slots[i][j]
    local prev_cover = nil
    if model.albums[i][j] ~= nil then
        prev_cover         = model.albums[i][j]
        model.albums[i][j] = nil
    end

    --if url returned is empty, do it again
    if (site == "") then
        loadCovers(index, searches[#adapters+1-index], math.random(16))
    --if the album is empty, then it is the initial load
    elseif model.albums[i] ~= nil and slot ~= nil then

        model.albums[i][j] = Image{
            async = true,
            src   = site,
            -- toss the filler image and scale it once loaded
            on_loaded = function(img,failed)
                --if everything went right
                if not failed and img ~= nil then
                    print("\tloading pic at",index,"\t a.k.a ("..i..", "..j..")",model.albums[i][j])
                        
                    --add the next album cover
                    Scale_To_Fit(img, img.base_size,{PIC_W,PIC_H})
                    slot:add(img)
                    --put the old one on top and animate it down
                    --only animate if there is a picture already there
                    if prev_cover ~= nil then
                        print("\tan old cover exists, animating it out")
                        prev_cover:raise_to_top()
                        prev_cover:animate{
                            duration     = 4*CHANGE_VIEW_TIME,
                            y            = img.y + PIC_H,
                            opacity      = 0,
                            on_completed = function(image)
                                --toss the old cover after the animation
                                prev_cover:unparent()
                                prev_cover = nil
                            end
                        }
                    end
                --if it failed to load 
                else
                    loadCovers(index, searches[#adapters+1-index], math.random(16))
                end
                model.swapping_cover = false
            end
        }
    else
        model.swapping_cover = false
    end
end

function Scale_To_Fit(img,base_size,target_size)
    local scale_x = target_size[1] / base_size[1]
    local scale_y = target_size[2] / base_size[2]

    if scale_y > scale_x  then
        img.size  = {scale_y*base_size[1], scale_y*base_size[2]}
        img.clip  = { (img.w-target_size[1])/2, 0,
                       target_size[1],target_size[2]}
        img.anchor_point = { (img.w-target_size[1])/2, 0 }
    else
        img.size  = {scale_x*base_size[1],scale_x*base_size[2]}
        img.clip  = { 0,(img.h-target_size[2])/2,
                      target_size[1], target_size[1]}
        img.anchor_point = {  0, (img.h-target_size[2])/2 }

    end

end
