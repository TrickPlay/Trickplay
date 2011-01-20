--dofile ("FlickrTest.lua")
--dofile("Slideshow.lua")
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

failed_to_load = Image{src = "assets/placeholder.jpg",opacity=0}
screen:add(failed_to_load)
sources = {}
terms = {"Bokeh","Sunset","City","Scenic","Clouds","Mountain","Autumn","Grass"}

loadGroup = {}

PIC_DIR = "assets/thumbnails/"
function loading(group)

    group:add(Rectangle
    {
        name   = "backing",
        color  = "000000",
        width  = screen.h,
        height = screen.h 
    })
    local loading_dots = 
    {
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},

        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},

        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
        Clone{source = model.loading_dot, anchor_point= {screen.h/-2,screen.h/-2}},
    }

    for i=1,#loading_dots do
        local r   = 100
        local rad = (2*math.pi)/(#loading_dots) * i

        loading_dots[i].x = math.floor( r * math.cos(rad) )
        loading_dots[i].y = math.floor( r * math.sin(rad) )

        group:add(loading_dots[i])
        --print(loading_dots[i].x ,loading_dots[i].y, deg)
    end

    local load_timeline = Timeline
    {
            name      = "Selection animation",
            loop      =  true,
            duration  =  150 * (#loading_dots),
            direction = "FORWARD", 
    }
    function load_timeline.on_new_frame(t)
        --print("on_frame",msecs)
		local msecs = t.elapsed
        local increment = math.ceil(255/(#loading_dots))
        local start_i = math.ceil(msecs/150)
        for i = 1,#loading_dots do
            local curr_i = (start_i + (i-1))%(#loading_dots) +1

            loading_dots[curr_i].opacity = increment*i
        end
    end
    load_timeline:start()
    return load_timeline
end
--calls adapters/sources, loads default images
function Setup_Album_Covers()
    model.fp_slots     = {}

    model.album_group.x = screen.width  / (NUM_VIS_COLS + 1)*.5

    --fill the thing with clones of the default-loading image
    for i = 1,NUM_ROWS do 

        model.fp_slots[i]     = {}

        for j = 1,math.ceil(#terms/NUM_ROWS) do
            if ((j-1)*NUM_ROWS+i)<= #terms then--#adapters then
                model.fp_slots[i][j] = Group
                {
                    position = { PIC_W * (j-1), PIC_H * (i-1) },
                    clip     = { 0, 0,  PIC_W, PIC_H },
                    opacity  = 255
                }
                model.fp_slots[i][j]:add(Clone
                {
                    name    = "placeholder",
                    source  = model.default[math.random(1,8)],
                    opacity = 255
                })
				model.fp_slots[i][j].extra.lic_tit = "Waiting for Picture"
				model.fp_slots[i][j].extra.lic_auth = " "
				model.fp_slots[i][j].extra.index = 0
                model.album_group:add(model.fp_slots[i][j])
            end
        end
    end

    for i =1, #terms do
        local ii = (i-1)%NUM_ROWS +1
        local jj = math.ceil(i/NUM_ROWS)

        sources[i] = Flickr_Interesting(model.fp_slots[ii][jj],terms[i])
        sources[i]:get_interesting_photos()
--[[
        adapters[#adapters+1-i]:loadCovers(model.fp_slots[ii][jj],
                                           searches[#adapters+1-i],
                                           math.random(5))
--]]
    end
end

function LoadImg(url,slot,lic_tit,lic_auth, index)
    print("Load_Image(",url,")")
    --if url returned is empty, do it again
    if (url == "") then
        --error("\n\n\nNEED ASSET TO LOAD FOR A BLANK IMG URL\n\n")
        --src:loadCovers(slot,search, math.random(16))
    --if the album is empty, then it is the initial load
    elseif slot ~= nil then

        local pic = Image{
            name  = "cover",
            async = true,
            src   = url,
            -- toss the filler image and scale it once loaded
            on_loaded = function(img,failed)
                --if everything went right
                if not failed and img ~= nil then
                    --print("\tloading pic at",index,"\t a.k.a ("..i..", "..j..")")
                    local placeholder = slot:find_child("placeholder")
                    if placeholder ~= nil then
                        placeholder:unparent()
						local r = Rectangle
                        {
                            size = {
                                PIC_W,
                                PIC_H
                            },
                            color="000000",
                        }
                        slot:add(r)
                        r:lower_to_bottom()
                    end
					slot.extra.lic_tit  = lic_tit
					slot.extra.lic_auth = lic_auth
					slot.extra.index = index
					if slot == model.fp_slots[model.fp_index[1] ][model.fp_index[2] ] then
						sel_tit  = fp_selector:find_child("title")
						sel_auth = fp_selector:find_child("auth")
						sel_img  = fp_selector:find_child("img")
						sel_tit.text = lic_tit
						sel_auth.text = lic_auth

	
					end
                    local prev_cover = slot:find_child("cover")        
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
                    --error("\n\n\nNEED ASSETS TO LOAD WHEN IMG FAILED TO LOAD\n\n")
                    --print("\tloading pic at",index,"\t a.k.a ("..i..", "..j..")")
                    local placeholder = slot:find_child("placeholder")
                    if placeholder ~= nil then
                        placeholder:unparent()
						local r = Rectangle
                        {
                            size = {
                                PIC_W,
                                PIC_H
                            },
                            color="000000",
                        }
                        slot:add(r)
                        r:lower_to_bottom()
                    end
					slot.extra.lic_tit  = "Could not load the image"
					slot.extra.lic_auth = "URL does not exist"
					
                    local prev_cover = slot:find_child("cover") 
					img = Clone{source=failed_to_load}
                    --add the next album cover
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
