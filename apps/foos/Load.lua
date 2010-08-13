--dofile ("FlickrTest.lua")
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"


--calls adapters/sources, loads default images
function Setup_Album_Covers()
    screen:add(model.default)

    startAdapter(2) --TODO fix this one source shit
    model.album_group.x = screen.width  / (NUM_VIS_COLS + 1)*.5

    --fill the thing with clones of the default-loading image
    for i = 1,NUM_ROWS do 
        model.placeholders[i] = {}
        model.albums[i] = {}
        for j = 1,math.ceil(model.num_sources/NUM_ROWS) do

            model.placeholders[i][j] = Clone{ source = default }
            model.placeholders[i][j].position = 
            {
                screen.width  * (j-1) / (NUM_VIS_COLS + 1),
                screen.height * (i-1) / NUM_ROWS
            }
            model.placeholders[i][j].scale = 
            {
                (screen.width/(NUM_VIS_COLS+1))  / 
                 model.default.base_size[1],
                (screen.height/NUM_ROWS) / 
                 model.default.base_size[2]
            }
            model.placeholders.opacity = 255

            model.album_group:add(model.placeholders[i][j])
        end
    end
end

--Called by the adapter's on_complete function
function Load_Image(site,index)

    local i = index%NUM_ROWS + 1
    local j = math.ceil(index/NUM_ROWS)

    print("getting a pic for ",i,j,index)
    model.albums[i][j] = Image
    {
        async    = true,
        src      = site,
        position = 
        {
            screen.width  * (j-1) / (NUM_VIS_COLS + 1),
            screen.height * (i-1) / NUM_ROWS
        },
        -- toss the filler image and scale it once loaded
        on_loaded = function()
            print("loading pic at",i,j,index)
            model.placeholders[i][j]:unparent()
            model.placeholders[i][j] = nil

            model.albums[i][j].scale = 
            {
                 (screen.width/(NUM_VIS_COLS+1))  / 
                  model.albums[i][j].base_size[1],
                 (screen.height/NUM_ROWS) / 
                  model.albums[i][j].base_size[2]
            }
            model.album_group:add(model.albums[i][j])
        end
    }
end

--[[
function Reload_Images(view)
    print("Reload_Images()")
    if model.albums_loaded == false then     
        local curr_pics = getPictureUrl()
        if #curr_pics ~= 0 then
            for i = 1,#curr_pics do 
                print(i,curr_pics[i],model.album_covers[i],#curr_pics)
                model.album_covers[i]:unparent()
                model.album_covers[i] = Image{
                    async = true,
                    src = curr_pics[i],
                    opacity = 0
                }
                model.album_base_sizes[i] = {model.album_covers[i].base_size[1],
                                             model.album_covers[i].base_size[2]}
                screen:add( model.album_covers[i])
            end
            model.albums_loaded = true



            for i = 1, NUM_ROWS do
                --left edge
                if model.front_page_index >= 2 then
                    local index = model.front_page_index*NUM_ROWS+ i-4
                    model.left_edge[i]:unparent()
                    model.left_edge[i] = Clone{
                         source=model.album_covers[index]}
                    model.left_edge[i].position = 
                       {
                            0  -
                            screen.width  / (NUM_VIS_COLS + 1)*.5,
                            screen.height * (i-1) / NUM_ROWS
                        }
                    model.left_edge[i].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.album_base_sizes[index][1],
                        (screen.height/NUM_ROWS) / 
                         model.album_base_sizes[index][2]
                    }
                    model.left_edge[i].opacity = 255
                    view.ui:add(model.left_edge[i])
                end
                --visible columns
                for j = 1,NUM_VIS_COLS do
                    local index = (j-1)*NUM_ROWS+i

                    model.vis_pics[i][j] = Clone{
                        source=model.album_covers[index]}
                    model.vis_pics[i][j].position = 
                    {
                        screen.width  * (j-1) / (NUM_VIS_COLS + 1) +
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }

                    model.vis_pics[i][j].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.album_base_sizes[index][1],
                        (screen.height/NUM_ROWS) / 
                         model.album_base_sizes[index][2]
                    }
                    model.vis_pics[i][j].opacity = 255
                    view.ui:add(model.vis_pics[i][j])
                end
                --right edge TODO maybe an off by one error
                if (model.front_page_index+3)*2 -1 < model.num_sources then
                    local index = (model.front_page_index + 3)*2 + i

                    model.right_edge[i] = Clone{
                         source = model.album_covers[index]
                    }
                    model.right_edge[i].position = 
                    {
                        screen.width  -
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }
                    model.right_edge[i].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.album_base_sizes[index][1],
                        (screen.height/NUM_ROWS) / 
                         model.album_base_sizes[index][2]
                    }
                    view.ui:add(model.right_edge[i])

                end
            end
        end
    else
        print("didnt do it")
    end
end

function Init_Pics(ui)

    --if model.albums_loaded ~= 0 then return end    

    --model.album_covers=getPictureUrl()
    for i = 1,NUM_ROWS do 
        model.vis_pics[i] = {}
        for j = 1,NUM_VIS_COLS do 
            local index = (j-1)*NUM_ROWS+i

print("init_pics index:",index,model.album_covers[index])
                model.vis_pics[i][j] = Clone{
                source=model.album_covers[index]}
                model.vis_pics[i][j].position = 
                    {
                        screen.width  * (j-1) / (NUM_VIS_COLS + 1) +
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }

                model.vis_pics[i][j].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.album_base_sizes[index][1],
                        (screen.height/NUM_ROWS) / 
                         model.album_base_sizes[index][2]
                    }
                model.vis_pics[i][j].opacity = 255

            ui:add(model.vis_pics[i][j])            
        end
    end

    for i = 1,NUM_ROWS do 
        local index = i + NUM_ROWS*NUM_VIS_COLS

        model.left_edge[i]  = nil

            model.right_edge[i] = Clone{source = model.album_covers[index]}
            model.right_edge[i].position = 
            {
                    screen.width  -
                    screen.width  / (NUM_VIS_COLS + 1)*.5,
                    screen.height * (i-1) / NUM_ROWS
            }

            model.right_edge[i].scale = 
             {
                 (screen.width/(NUM_VIS_COLS+1))  / 
                  model.album_base_sizes[index][1],
                 (screen.height/NUM_ROWS) / 
                  model.album_base_sizes[index][2]
             }

        ui:add(model.right_edge[i])
    end
end

--]]
