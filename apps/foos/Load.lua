--dofile ("FlickrTest.lua")
dofile("Slideshow.lua")
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"


--calls adapters/sources, loads default images
function Setup_Album_Covers()
    assert(model.default,"default is not init yet")
    screen:add(model.default)
	for i =1, 16 do
		 loadCovers(i,searches[i], 1)
	end
   -- startAdapter(1) --TODO fix this one source shit
    model.album_group.x = screen.width  / (NUM_VIS_COLS + 1)*.5

    --fill the thing with clones of the default-loading image
    for i = 1,NUM_ROWS do 
        model.placeholders[i] = {}
        model.albums[i] = {}
        for j = 1,math.ceil(model.num_sources/NUM_ROWS) do

            model.placeholders[i][j] = Clone{ source = model.default, opacity =150}
            model.placeholders[i][j].position = 
            {
                PIC_W * (j-1) + PIC_W/4, PIC_H * (i-1)+PIC_H/4
--[[
                screen.width  * (j-1) / (NUM_VIS_COLS + 1),
                screen.height * (i-1) / NUM_ROWS
--]]
            }
				model.placeholders[i][j].z_rotation = {0, model.default.w/2, model.default.h/2}
--[[            model.placeholders[i][j].scale = 
            {
                 PIC_W / 
--                 (screen.width/(NUM_VIS_COLS+1))  / 
                  model.default.base_size[1],
                  PIC_H / 
--                 (screen.height/NUM_ROWS) / 
                  model.default.base_size[2]
            }]]
            model.placeholders.opacity = 255
            model.album_group:add(model.placeholders[i][j])
        end
    end
    
end

--Called by the adapter's on_complete function
function Load_Image(site,index)

    local i = (index-1)%NUM_ROWS +1
    local j = math.ceil(index/NUM_ROWS)

    print("getting a pic for ",i,j,index)
    if model.albums[i] ~= nil and  model.albums[i][j] == nil then
        model.albums[i][j] = Image
        {
            async    = true,
            src      = site,
            position = { PIC_W * (j-1), PIC_H * (i-1) },
            -- toss the filler image and scale it once loaded
            on_loaded = function()
                if model.albums[i] ~= nil and model.albums[i][j] ~= nil then
                    print("loading pic at",i,j,index)
                    if model.placeholders[i] ~= nil and 
                       model.placeholders[i][j] ~= nil then

                        model.placeholders[i][j]:unparent()
                        model.placeholders[i][j] = nil
                    end

                    if model.fp_index[1] == i and model.fp_index[2] == j then
                        model.albums[i][j].scale = 
                        {
                            SEL_W / model.albums[i][j].base_size[1],
                            SEL_H / model.albums[i][j].base_size[2]
                        }
                        model.albums[i][j]:raise_to_top()
                    else
                        model.albums[i][j].scale = 
                        {
                            PIC_W / model.albums[i][j].base_size[1],
                            PIC_H / model.albums[i][j].base_size[2]
                        }
                    end
                    model.album_group:add(model.albums[i][j])
                    model.albums[i][j]:lower_to_bottom()
                    --model:notify()
                end
            end
        }
    elseif model.albums[i] ~= nil and model.albums[i][j] ~= nil then

        model.swap_pic = Image{
            async    = true,
            src      = site,
            position = { PIC_W * (j-1), PIC_H * (i-1) },
            -- toss the filler image and scale it once loaded
            on_loaded = function()
                if (model.swap_pic == nil or model.albums[i] == nil or model.albums[i][j] == nil) then 
                    model.swap_pic = nil 
                    model.swapping_cover = false
                else
                    if model.fp_index[1] == i and model.fp_index[2] == j then
                        model.swap_pic.scale = {
                            SEL_W / model.swap_pic.base_size[1],
                            SEL_H / model.swap_pic.base_size[2]
                        }
                    else
                        model.swap_pic.scale = {
                            PIC_W / model.swap_pic.base_size[1],
                            PIC_H / model.swap_pic.base_size[2]
                        }
                    end
                    model.album_group:add(model.swap_pic)
                    model.albums[i][j]:lower_to_bottom()
                    model.swap_pic:lower_to_bottom()
                    model.albums[i][j]:animate{
                        duration     = 4*CHANGE_VIEW_TIME,
                        y            = model.albums[i][j].y + PIC_H,
                        opacity      = 0,
                        on_completed = function()
                            if (model.albums[i] == nil or model.albums[i][j] == nil) then 
                                model.swap_pic = nil 
                            else
                                print("changeCover called back",model.albums[i][j],model.swap_pic)
                                if model.albums[i][j] ~= nil then
                                    model.albums[i][j]:unparent() 
                                    model.albums[i][j] = nil
                                end
                                model.albums[i][j] = model.swap_pic
                                model.swap_pic:lower_to_bottom()
                            end
                            model.swapping_cover = false
                        end
                    }
                end            
            end
        }
    end
end

function Scale_To_Fit(img,base_size,target_size)
    local scale_x = target_size[1] / base_size[1]
    local scale_y = target_size[2] / base_size[2]

    if scale_x > scale_y then
        img.scale = {scale_y,scale_y}
        img.anchor_point = {base_size[1]*(1-scale_y)/2,0}
        img.clip  = {0,0,base_size[1]*scale_y,
                         base_size[2]*scale_y}
    else
        img.scale = {scale_x,scale_x}
        img.anchor_point = {0,base_size[2]*(1-scale_x)/2}
        img.clip  = {0,0,base_size[1]*scale_x,
                         base_size[2]*scale_x} 
    end
end


