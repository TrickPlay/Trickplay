--dofile ("FlickrTest.lua")

NUM_OF_3X3 = 1
NUM_OF_2X2 = 2

NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"

function Init_Pics(ui)

    for i = 1,NUM_ROWS do 
        model.vis_pics[i] = {}
        for j = 1,NUM_VIS_COLS do 
            local index = (j-1)*NUM_ROWS+i
            model.vis_pics[i][j] = Image{

                    position = 
                    {
                        screen.width  * (j-1) / (NUM_VIS_COLS + 1) +
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    },

                    src = PIC_DIR.."Album"..index..".jpg"
            }
            model.vis_pics[i][j].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.vis_pics[i][j].base_size[1],
                        (screen.height/NUM_ROWS) / 
                         model.vis_pics[i][j].base_size[2]
                    }
            ui:add(model.vis_pics[i][j])            
        end
    end

    for i = 1,NUM_ROWS do 
       local index = i + NUM_ROWS*NUM_VIS_COLS

        model.left_edge[i]  = nil
        model.right_edge[i] = Image{

             position = 
             {
                  screen.width  -
                  screen.width  / (NUM_VIS_COLS + 1)*.5,
                  screen.height * (i-1) / NUM_ROWS
             },

             src = PIC_DIR.."Album"..index..".jpg"
        }
        model.right_edge[i].scale = 
             {
                 (screen.width/(NUM_VIS_COLS+1))  / 
                  model.right_edge[i].base_size[1],
                 (screen.height/NUM_ROWS) / 
                  model.right_edge[i].base_size[2]
             }
        ui:add(model.right_edge[i])
    end
end


