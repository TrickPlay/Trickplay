
local generic_srcs = {
    "seed.png",
    "seed-back.png",
    "seed-front.png",
    "cherry.png",
    "cherry-leaf.png",
    "cherry-stem-1.png",
    "cherry-stem-2.png",
    "cracker.png",
    "cracker-crumble1.png",
    "cracker-crumble2.png",
}
--[[
    Level Organization
    
Levels{
    
    [1] = { --level one
        
        --source is the number that corresponds to the index in clone_srcs
        
        tiling = {
            
            {x,y,w,source},
            
            ...
            
        },
        
        
        items = {
            {
                x,
                y,
                
                type = "static", "dynamic", "foreground", "background", "far_distance" ,
                
                shape,
                
                source or pieces = {
                    
                    {x,y,source},
                    
                    ...
                    
                }
                
                on_begin_contact = function or nil, -- for objects that need to shatter when hit
                impact_floor     = function or nil, -- for objects that cause spills when they hit the floor
                scroll           = function or nil, -- for objects in the background
            },
            
            ...
            
        },
        
        clone_srcs = {
            
            img_string,
            
            ...
            
        }
        
        
    },
    
    [2] = {},
    
    ...
    
}

--]]

local lvls
lvls = {
    {    --   Level 1 Information
        
        items = {
            
            {
                type   = "background",
                source = "bedroom-cage",
                x      = 335,
                y      = 269,
            },
            {
                type   = "foreground",
                source = "cage-door",
                x      = 531,
                y      = 286,
                w      = 900,
                anchor_point = {5,0},
                scale  = {-1,1},
            },--[[
            {
                type   = "background",
                source = "bedroom-dresser",
                x      = 808,
                y      = 275,
            },--]]
            
            {
                type   = "wall_objs",
                source = "bedroom-picture2",
                x      = 900,
                y      = 181,
                scale  = {3/4,3/4},
            },
            {
                type   = "background",
                source = "dining-plant",
                x      = 1200,
                y      = 235+75,--+300,
            },
            ---[[
            {
                type   = "static",
                source = "bedroom-bed",
                x      = 1770, --1920+138+50
                y      = 180+130+220,
                enemy  = true,
                player = true,
            },--]]
            {
                type   = "static",
                source = "bedroom-fan-base",
                x      = 1420+495-130,
                y      = 0,
                scale  = {3/4,3/4},
                player = true,
            },
            {
                type   = "background",
                source = "bed-post-1",
                x      = 1770-160,
                y      = 204+100,
                --scale  = {3/4,3/4},
            },
            {
                type   = "foreground",
                source = "bed-post-2",
                x      = 1770+264,
                y      = 204+100-40,
                --scale  = {3/4,3/4},
            },
            {
                type   = "background",
                source = "bed-post-3",
                x      = 1770+500-34,
                y      = 204+100+12,
                --scale  = {3/4,3/4},
            },
            {
                type   = "background",
                source = "bed-post-4",
                x      = 1770+800+33,
                y      = 204+100+16,
                --scale  = {3/4,3/4},
            },
            {
                type   = "background",
                source = "bedroom-socks",
                x      = 1920+1027,
                y      = 960,
            },
            {
                type   = "static",
                source = "bedroom-dresser-small",
                x      = 1920+1381-60,
                y      = 591+40,
                enemy  = true,
            },
            {
                type   = "background",
                source = "bedroom-book-shelves",
                x      = 1920+1400-65,
                y      = 126+45,
            },
            {
                type   = "dynamic",
                source = "bedroom-clock",
                x      = 1920+1596-120,
                y      = 527+5,
                m      = .5,
            },
            

            {
                type   = "wall_objs",
                source = "bedroom-picture",
                x      = 3840+196+115,
                y      = 212-20,
            },
            {
                type   = "background",
                source = "bedroom-rug",
                x      = 3840+9+240,
                y      = 873+30,
            },
            {
                type   = "wall_objs",
                source = "bathroom-doorway",
                x      = 3840+754+170,
                y      = 110,
                --scale  = {3/4*2,3/4*2}
            },
            {
                type   = "distance",
                source = "bathroom",
                x      = 3840+813-100,
                y      = 46+110,
            },
            {
                type   = "background",
                source = "bedroom-door",
                x      = 3840+1431+190,
                y      = 140,
                player = true,
            },
            {
                type   = "foreground",
                source = "bedroom-door-frame",
                x      = 3840+1880+105+13,
                y      = 135,
            },

            {
                type   = "static",
                source = "dining-light",
                x      = 5760+424+132,
                y      = 30,
                scale  = {-1,1},
                player = true,
            },
            {
                type   = "static",
                source = "dining-light",
                x      = 5760+424+300,
                y      = 30,
            },
            {
                type   = "wall_objs",
                source = "dining-pictures",
                x      = 5760+172+200,
                y      = 295+20,
            },--[[
            {
                type   = "static",
                source = "dining-table",
                x      = 5760+42+340,
                y      = 535+5,
                w      = 600,
                h      = 80,
                x_off  = 100,
                y_off  = 200,
                enemy  = true,
            },--]]
            {
                type   = "background",
                source = "dining-table-leg-back",
                x      = 5760+388+120+80-150,
                y      = 535+5+206,
            },
            {
                type   = "background",
                source = "dining-table-leg-back",
                x      = 5760+900+220-150,
                y      = 535+5+206,
            },
            {
                type   = "background",
                source = "dining-rm-chair",
                x      = 5760+42+220,
                y      = 535+45,--+300,
            },
            {
                type   = "background",
                source = "dining-table-left-corner",
                x      = 5760+42+340,
                y      = 535+5+156,
                enemy  = true,
                player = true,
                scale = {3/4,3/4},
            },
            {
                type   = "static",
                source = "dining-table-right-corner",
                x      = 5760+42+940+40,
                y      = 535+5+156,
                scale = {3/4,3/4},
                m      = .5,
            },
            {
                type   = "dynamic",
                source = "dining-fruit-basket",
                x      = 5760+454+240,
                y      = 556+40,
                m      = 1,
            },
            {
                type   = "foreground",
                source = "dining-table-leg",
                x      = 5760+388+120+80,
                y      = 787+31,
            },
            {
                type   = "foreground",
                source = "dining-table-leg",
                x      = 5760+900+220,
                y      = 787+30,
            },
            {
                type   = "background",
                source = "dining-plant",
                x      = 5760+1051+140,
                y      = 214+90,
            },
            {
                type   = "background",
                source = "dining-rm-chair",
                x      = 5760+42+940+60,
                y      = 535+45,--+300,
                scale = {-1,1},
            },
            {
                type   = "background",
                source = "dining-shelves",
                x      = 5760+1305+160,
                y      = 96+50,
            },
            {
                type   = "static",
                source = "living-chair",
                x      = 5760+1387+40,
                y      = 549+70,
                enemy  = true,
                player = true,
            },

            {
                type   = "dynamic",
                x      = 5760+1526,
                y      = 302,
                m      = .7,
                pieces = {
                    
                    {
                        source  = "snowglobe-top-left",
                        x      = 11,
                        y      = 0,
                    },
	
                    {
                        source  = "snowglobe-top-right",
                        x      = 41,
                        y      = 2,
                    },
	
                    {
                        source  = "snowglobe-btm-left",
                        x      = 0,
                        y      = 11,
                    },
	
                    {
                        source  = "snowglobe-btm-right",
                        x      = 46,
                        y      = 11,
                    },
	
                    {
                        source  = "snowglobe_base",
                        x      = 4,
                        y      = 40,
                    },
                }
            },
            --[[
            {
                type   = "background",
                source = "livingrm-middle",
                x      = 114+4*screen_w+240,
                y      = 135,
                --scale  = {3/4,3/4},
            },
            --]]

            {
                type   = "background",
                source = "living-light-behind-couch",
                x      = 7680+81+140,
                y      = 175+75,
            },

            {
                type   = "background",
                source = "living-couch-half",
                x      = 7680+45+190,
                y      = 450+50,
            },

            {
                type   = "background",
                source = "living-couch-half",
                x      = 7680+552+350,
                y      = 450+50,
                scale  = {-1,1},
            },

            {
                type   = "static",
                source = "living-ottoman",
                x      = 7680+196+160,
                y      = 845+30,
                enemy  = true,
            },

            {
                type   = "static",
                source = "living-coffee-table",
                x      = 7680+870+160,
                y      = 806+35,
                enemy  = true,
            },
            {
                type   = "distance",
                source = "living-farm-scene",
                x      = 7680+212+730-750,
                y      = 100,
            },
            {
                type   = "wall_objs",
                source = "living-window",
                x      = 7680+212+190,
                y      = 100,
                scale  = {-1,1},
            },
            {
                type   = "wall_objs",
                source = "living-window",
                x      = 7680+212+730,
                y      = 100,
            },
            
            {
                type   = "foreground",
                source = "living-tv",
                x      = 7680+1506+160,
                y      = 420+80,
                player = true,
            },

            {
                type   = "foreground",
                source = "living-tv-pic1",
                x      = 7680+1543+150,
                y      = 453+40,
            },

            {
                type   = "foreground",
                source = "plant-fern",
                x      = 7680+1700+160,
                y      = 814+80,
            },

            {
                type   = "static",
                source = "living-hanging-plant",
                x      = 7680+1241+140,
                y      = 50,
                player = true,
            },
--[[
{
                type   = "background",
                source = "livingrm-right",
                x      = 114+5*screen_w+240,
                y      = 135,
                --scale  = {3/4,3/4},
            },
            --]]
            {
                type   = "background",
                source = "bar-bookshelf",
                x      = 9600+33+265,
                y      = 181+100,
            },

            {
                type   = "background",
                source = "plant-fern",
                x      = 9600+431+220,
                y      = 624,
            },

            {
                type   = "wall_objs",
                source = "bar-picture",
                x      = 9600+821+320,
                y      = 165+40,
            },
            
            {
                type   = "static",
                source = "bar-lights",
                x      = 9600+904+295,
                y      = 15,
                scale  = {-1,1},
                player = true,
            },
            {
                type   = "static",
                source = "bar-lights",
                x      = 9600+904+510,
                y      = 15,
            },
            {
                type   = "static",
                source = "bar",
                x      = 9600+904+230,
                y      = 550+30,
                enemy  = true,
            },--[[
            {
                type   = "static",
                source = "bar-stool",
                x      = 9600+1078+270,
                y      = 760+30,
            },
            {
                type   = "static",
                source = "bar-stool",
                x      = 9600+1309+270,
                y      = 706+30,
            },--]]
            {
                
                type   = "dynamic",
                x      = 9600+1324+270,
                y      = 410,
                m      = 1,
                pieces = {
                    {
                        source = "scotch-top",
                        x      = 26,
                        y      = 0,
                    },
    
                    {
                        source = "scotch-mid-stem",
                        x      = 23,
                        y      = 17,
                    },
                    {
                        source = "scotch-right-btm",
                        x      = 11,
                        y      = 46,
                    },
	
                    {
                        source = "scotch-left-btm",
                        x      = -1,
                        y      = 70,
                    },
	
                    {
                        source = "scotch-base",
                        x      = 0,
                        y      = 82,
                    },
                }
            },

            {
                type   = "static",
                source = "bar-glass",
                x      = 9600+1295+270,
                y      = 516,
            },
            --[[
{
                type   = "background",
                source = "kitchen_left",
                x      = 114+6*screen_w+240,
                y      = 135,
                --scale  = {3/4,3/4},
            },
            
            {
                type   = "background",
                source = "kitchen_middle",
                x      = 114+7*screen_w+240,
                y      = 135,
                --scale  = {3/4,3/4},
            },
            --]]
            {
                type   = "background",
                source = "kitchen-archway",
                x      = 11520+254-110,
                y      = 135,
                player = true,
            },
            {
                type   = "foreground",
                source = "kitchen-arch-piece",
                x      = 11520+254+20,
                y      = 135,
            },

            {
                type   = "background",
                source = "kitchen-cupboard-side",
                x      = 11520+254+130,
                y      = 120,
            },

            

            {
                type   = "background",
                source = "kitchen-cupboard-top",
                x      = 11520+371+170,
                y      = 30,
                tile   = {6,1},
                --w      = 6,
            },

            {
                type   = "background",
                source = "kitchen-microwave",
                x      = 11520+974,
                y      = 30,
            },

            {
                type   = "background",
                source = "kitchen-cupboard-btm",
                x      = 11520+524,
                y      = 536+77-25,
            },

            {
                type   = "background",
                source = "kitchen-cupboard-btm",
                x      = 11520+384+226+140,
                y      = 536+77-25,
                scale  = {-1,1},
            },

            {
                type   = "background",
                source = "kitchen-cupboard-btm",
                x      = 11520+1380,
                y      = 536+77-25,
                scale  = {-1,1},
            },

            {
                type   = "background",
                source = "kitchen-cupboards",
                x      = 11520+1454+290,
                y      = 536+77-25,
            },
--[[
            {
                type   = "background",
                source = "kitchen-cupboard-btm",
                x      = 11520,
                y      = 0,
            },
            --]]
---[[
            {
                type   = "background",
                source = "kitchen-counter",
                x      = 11520+264+470,
                y      = 446+15,
                enemy  = true,
            },
--]]
            {
                type   = "background",
                source = "kitchen-toaster",
                x      = 11520+374+130,
                y      = 376+20,
            },

            {
                type   = "background",
                source = "kitchen-oven",
                x      = 11520+744+180,
                y      = 346+77,
            },

            {
                type   = "dynamic",
                source = "kitchen-cookbook",
                x      = 11520+1314+150,
                y      = 426,
                m      = 1.1,
            },

            {
                type   = "background",
                source = "kitchen-sink",
                x      = 11520+1674+170,
                y      = 286+30,
            },

            {
                type   = "background",
                source = "kitchen-board",
                x      = 11520+2194+170,
                y      = 386+20,
            },

            {
                type   = "background",
                source = "kitchen-books",
                x      = 11520+2814+140,
                y      = 326+20,
            },

            {
                type   = "background",
                source = "kitchen-rug",
                x      = 11520+1664+200,
                y      = 946+10,
            },

            {
                type   = "dynamic",
                source = "kitchen-spoon",
                x      = 11520+1204+140,
                y      = 436+10,
                m      = .5,
            },

            {
                type   = "dynamic",
                source = "kitchen-lemon",
                x      = 11520+2144+170,
                y      = 436+20,
                m      = .5,
            },

            {
                type   = "dynamic",
                source = "kitchen-lemon2",
                x      = 11520+2284+170,
                y      = 436+20,
                m      = .6,
            },

            {
                type   = "dynamic",
                source = "kitchen-bowl",
                x      = 11520+2644+140,
                y      = 346+20,
                m      = 1.8,
            },
            
            {
                type   = "wall_objs",
                source = "kitchen-fridge",
                x      = 11520+2934+190,
                y      = 120,
            },
            {
                type   = "wall_objs",
                source = "kitchen-cupboard-btm",
                x      = 11520+2814+175,
                y      = 536+77-25,
                scale  = {-1,1},
            },
            {
                type   = "background",
                source = "kitchen_right",
                x      = 114+8*screen_w+240,
                y      = 135,
                --scale  = {3/4,3/4},
            },
            {
                type   = "background",
                source = "kitchen-window",
                x      = 11520+3670+250+165,
                y      = 58,
                scale  = {-1,1},
            },
            {
                type   = "background",
                source = "kitchen-window",
                x      = 11520+3670+250+460,
                y      = 58,
            },
            {
                type   = "distance",
                source = "kitchen_backyard",
                x      = 11520+3670+350,
                y      = 0,
            },
            {
                type   = "background",
                source = "kitchen-chair",
                x      = 11520+3870+35-150,
                y      = 600-150,
            },
            {
                type   = "static",
                source = "kitchen-table-2",
                x      = 11520+3870+135,
                y      = 300+160,
                scale  = {-1,1},
                enemy  = true,
            },
            {
                type   = "background",
                source = "kitchen-table-2",
                x      = 11520+3870+505,
                y      = 300+160,
            },
            {
                type   = "background",
                source = "kitchen-chair",
                x      = 11520+3870+750,
                y      = 600-150,
                scale  = {-1,1},
            },
            {
                type   = "dynamic",
                source = "kitchen-flower-vase",
                x      = 11520+3870+505-90,
                y      = 300+160-240,
                m      = 2.5,
            },
            {
                type   = "wall_objs",
                source = "sliding-door-1",
                x      = 11520+4660+220,
                y      = 125,
                enemy_stop = true,
            },

            {
                type   = "foreground",
                source = "sliding-door-2",
                x      = 11520+5500+145,
                y      = 125,
                w      = 195,
                stop_scroll = true,
                player = true,
            },

            
            
        },
        
        tiling = {
            --{x,y,w,source},
            {
                x = 0,
                y = 0,
                w = 3840+754+170,
                h = 878,
                source = "wallpaper-pc.jpg",
            },
            {
                x = -114,
                y = 868,
                w = 11520+264-10,
                source = "tile-wood-floor.jpg",
            },
            {
                type   = "items",
                x      =  5760+42+340+172*4/3-29-29,
                y      =  535+5+156+1,
                w      = (5760+42+940+40+59) - (5760+42+340+172*4/3),
                source = "dining-table-slice.jpg",
            },
            {
                x = 3840+754+170+340,
                y = 0,
                w = (7680+212+190) - (3840+754+170+340),
                --h = 868,
                source = "wallpaper-pc.jpg",
            },
            {
                x = 7680+212+190+429*2,
                y = 0,
                w = (11520+254-110) - (7680+212+190+429*2),
                --h = 868,
                source = "wallpaper-pc.jpg",
            },
            {
                x = 11520+254-110+194,
                y = 0,
                w = (11520+3670+450) - (11520+254-110+194),
                source = "wall-gradient-pc.jpg",
            },
            {
                x = 11520+254-110+194,
                y = 868,
                w = (11520+5500+145+195*4/3) - (11520+254-110+194),
                h = 212 ,
                source = "kitchen-tile.jpg",
            },
            {
                x = 11520+3670+450,
                y = 389,
                w = (11520+3670+950) - (11520+3670+450),
                source = "wall-gradient-half.jpg",
            },
            {
                x = 11520+3670+950,
                y = 0,
                w = (11520+4660+120) - (11520+3670+950),
                source = "wall-gradient-pc.jpg",
            },
        },
        player_obstacles = {
            {
                x = 1970, 
                y = 650 ,
                w = 550 ,
                h = 200 ,
                arrow = "up",
            },
            {
                x = 1785 ,
                y = 0 ,
                w = 173, 
                h = 149 ,
                arrow = "down",
            },
            {
                x = 5800 ,
                y = 0 ,
                w = 120 ,
                h = 40 ,
                arrow = "down",
            },
            {
                x = 6316 ,
                y = 30 ,
                w = 300 ,
                h = 200 ,
                arrow = "down",
            },
            {
                x = 6282 ,
                y = 756 ,
                w = 650 ,
                h = 40 ,
                arrow = "up",
            },
            {
                x = 9346, 
                y = 550 ,
                w = 100 ,
                h = 497 ,
                arrow = "up",
            },
            {
                x = 9091 ,
                y = 100 ,
                w = 100 ,
                h = 160 ,
                arrow = "down",
            },
            {
                x = 10799 ,
                y = 15 ,
                w = 340 ,
                h = 104 ,
                arrow = "down",
            },
            {
                x = 11664, 
                y = 0 ,
                w = 234 ,
                h = 160 ,
                arrow = "down",
            },
            {
                x = 17165, 
                y = 800 ,
                w = 195 ,
                h = 100 ,
                arrow = "up",
            },
        },
        enemy_obstacles = {
            {
                x = 1970 ,
                y = 650 ,
                w = 550 ,
                h = 200 ,
            },
            {
                x = 3221 ,
                y = 651 ,
                w = 400 ,
                h = 400 ,
            },
            {
                x = 6332 ,
                y = 756 ,
                w = 580 ,
                h = 40 ,
            },
            {
                x = 7287-100, 
                y = 819 ,
                w = 200 ,
                h = 50 ,
            },
            {
                x = 8036, 
                y = 915 ,
                w = 300 ,
                h = 130 ,
            },
            {
                x = 8710 ,
                y = 881 ,
                w = 293 ,
                h = 170 ,
            },
            {
                x = 10734, 
                y = 610 ,
                w = 520 ,
                h = 377 ,
            },
            {
                x = 12204, 
                y = 501 ,
                w = 230 ,
                h = 83 ,
                can_jump_through = true,
            },
            {
                x = 12854, 
                y = 501 ,
                w = 450 ,
                h = 83 ,
                can_jump_through = true,
            },
            
            {
                x = 13754, 
                y = 501 ,
                w = 700 ,
                h = 83 ,
                can_jump_through = true,
            },
            {
                x = 15525 ,
                y = 530 ,
                w = 700 ,
                h = 70 ,
            },
        },
        
        collectables = {
            ----pre-bed
            {
                x = 1000,
                y = 700,
                type = "cracker",
            },
            {
                x = 1200,
                y = 700,
                type = "cracker",
            },
            {
                x = 1400,
                y = 700,
                type = "cracker",
            },
            {
                x = 1920+1250,
                y = 700,
                type = "cherry",
            },
            --bathroom area
            {
                x = 3840+813- 750,
                y = 700,
                type = "seed",
            },
            {
                x = 3840+813- 550,
                y = 700,
                type = "seed",
            },
            {
                x = 3840+813- 350,
                y = 700,
                type = "seed",
            },
            {
                x = 3840+813- 150,
                y = 700,
                type = "seed",
            },
            {
                x = 3840+813+150,
                y = 700,
                type = "seed",
            },
            {
                x = 3840+813+350,
                y = 700,
                type = "seed",
            },
            {
                x = 3840+813+550,
                y = 700,
                type = "seed",
            },
            {
                x = 5977,
                y = 700,
                type = "cracker",
            },
            {
                x = 6177,
                y = 700,
                type = "cracker",
            },
            
            {
                x = 5760+1387+100,
                y = 700,
                type = "cherry",
            },
            --couches
            {
                x = 7680+196+360,
                y = 700,
                type = "seed",
            },
            {
                x = 7680+196+510,
                y = 700,
                type = "seed",
            },
            {
                x = 7680+196+760,
                y = 700,
                type = "seed",
            },
            {
                x = 7680+196+910,
                y = 700,
                type = "seed",
            },
            --pre-bar
            {
                x = 9600+33+265,
                y = 700,
                type = "seed",
            },
            {
                x = 9600+33+465,
                y = 700,
                type = "seed",
            },
            {
                x = 9600+33+665,
                y = 700,
                type = "seed",
            },
            {
                x = 9600+33+865,
                y = 700,
                type = "seed",
            },
            --bar
            {
                x = 9600+33+1065,
                y = 400,
                type = "seed",
            },
            {
                x = 9600+33+1265,
                y = 400,
                type = "seed",
            },
            {
                x = 9600+33+1465,
                y = 400,
                type = "seed",
            },
            {
                x = 11520+254+25,
                y = 700,
                type = "cherry",
            },
            --kitchen counter
            {
                x = 11520+264+470,
                y = 350,
                type = "seed",
            },
            {
                x = 11520+264+570,
                y = 350,
                type = "seed",
            },
            {
                x = 11520+264+670,
                y = 350,
                type = "seed",
            },
            
            {
                x = 11520+1674-70,
                y = 200,
                type = "seed",
            },
            {
                x = 11520+1674+170,
                y = 200,
                type = "seed",
            },
            {
                x = 11520+1674+370,
                y = 200,
                type = "seed",
            },
            {
                x = 11520+1674+570,
                y = 200,
                type = "cherry",
            },
            {
                x = 11520+1674+770,
                y = 200,
                type = "seed",
            },
            {
                x = 11520+1674+970,
                y = 200,
                type = "seed",
            },
            {
                x = 11520+1674+1170,
                y = 200,
                type = "seed",
            },
        },
        intro = {
            {
                duration = 1.2,
                on_step = function()
                end,
                on_completed = function()
                    
                    Animation_Loop:add_animation(  lvls[1].intro[2]  )
                    
                    mediaplayer:play_sound("audio/creek-door.wav")
                    
                end,
            },
            {
                duration = .5,
                on_step = function(s,p)
                    
                    lvls[1].intro[2].actors[1].y_rotation = {
                        -180*p,0,0
                    }
                    
                end,
                on_completed = function()
                    
                    lvls[1].intro[2].actors[1]:unparent()
                    layers.background:add(lvls[1].intro[2].actors[1])
                    
                    for _,f in pairs(lvls[1].intro.post_intro_funcs) do
                        
                        f()
                        
                    end
                    
                    Animation_Loop:add_animation(LVL_Object.on_idle,"ACTIVE")
                    
                end
            },
        },
        clone_srcs = {
            --"bdrm-left.jpg",
            --"bdrm-rt.png",
            --"livingrm-left.jpg",
            --"livingrm-middle.jpg",
            --"livingrm-right.jpg",
            --"kitchen_left.jpg",
            --"kitchen_middle.jpg",
            --"kitchen_right.png",
            "bar.png",
            "bar-bookshelf.png",
            "bar-glass.png",
            "bar-lights.png",
            "bar-picture.png",
            "bar-shelf-candle.png",
            "bar-stool.png",
            "bathroom.jpg",
            "bathroom-doorway.png",
            "bed-post-1.png",
            "bed-post-2.png",
            "bed-post-3.png",
            "bed-post-4.png",
            "bedroom-bed.png",
            "bedroom-book-shelves.png",
            "bedroom-cage.png",
            "bedroom-clock.png",
            "bedroom-door.png",
            "bedroom-door-frame.jpg",
            "bedroom-door-frame.png",
            "bedroom-dresser-small.png",
            "bedroom-fan-base.png",
            "bedroom-fan-btm-left.png",
            "bedroom-fan-btm-right.png",
            "bedroom-fan-top-left.png",
            "bedroom-fan-top-right.png",
            "bedroom-picture.png",
            "bedroom-picture2.png",
            "bedroom-rug.png",
            "bedroom-socks.png",
            "cage-door.png",
            "dining-fruit-basket.png",
            "dining-light.png",
            "dining-pictures.png",
            "dining-plant.png",
            "dining-rm-chair.png",
            "dining-shelves.png",
            "dining-table-left-corner.png",
            "dining-table-right-corner.png",
            "dining-table-slice.jpg",
            "dining-table-leg.png",
            "dining-table-leg-back.png",
            "kitchen-arch-piece.png",
            "kitchen-archway.jpg",
            "kitchen_backyard.jpg",
            "kitchen-board.png",
            "kitchen-books.png",
            "kitchen-bowl.png",
            "kitchen-chair.png",
            "kitchen-cookbook.png",
            "kitchen-counter.png",
            "kitchen-cupboard-side.png",
            "kitchen-cupboard-btm.png",
            "kitchen-cupboards.png",
            "kitchen-cupboard-top.png",
            "kitchen-drip.png",
            "kitchen-flower-vase.png",
            "kitchen-fridge.png",
            "kitchen-lemon.png",
            "kitchen-lemon2.png",
            "kitchen-microwave.png",
            "kitchen-oven.png",
            "kitchen-rug.png",
            "kitchen-sink.png",
            "kitchen-spoon.png",
            "kitchen-window.png",
            "kitchen-table-2.png",
            "kitchen_table_leg_left.png",
            "kitchen_table_leg_right.png",
            "kitchen-tile.jpg",
            "kitchen-toaster.png",
            "living-chair.png",
            "living-coffee-table.png",
            "living-couch-half.png",
            "living-farm-scene.jpg",
            "living-hanging-plant.png",
            "living-light-behind-couch.png",
            "living-ottoman.png",
            "living-tv.png",
            "living-tv-pic1.png",
            "living-tv-pic2.png",
            "living-tv-pic3.png",
            "living-window.png",
            "lvl1_candle_table.png",
            "lvl1_lamp.png",
            "lvl1_laundry.png",
            "plant-fern.png",
            "scotch-base.png",
            "scotch-left-btm.png",
            "scotch-mid-stem.png",
            "scotch-right-btm.png",
            "scotch-spill.png",
            "scotch-top.png",
            "sliding-door-1.png",
            "sliding-door-2.png",
            "snowglobe_base.png",
            "snowglobe-btm-left.png",
            "snowglobe-btm-right.png",
            "snowglobe-drops.png",
            "snowglobe-top-left.png",
            "snowglobe-top-right.png",
            "snowglobe_water.png",
            "tile-wood-floor.jpg",
            "wall-gradient-pc.jpg",
            "wallpaper-pc.jpg",

        }
        
    },
    ----------------------------------------------------------------------------
    { --Level 2 Information
        items = {
            
            {
                type   = "wall_objs",
                source = "yard_1",
                x      = 417-100,
                y      = 135,
                --scale = {3/4,3/4},
            },
            {
                type   = "foreground",
                source = "umbrella",
                x      = 1300-100,
                y      = 335,
                --scale = {3/4,3/4},
            },
            {
                type   = "background",
                x = 2300-52-1-100,
                y = 255+14,
                source = "yard-fence-piece",
                exit_piece = true
            },
            {
                type   = "background",
                x = 2300+40-100,
                y = 600-130,
                source = "yard-flowers",
            },
            {
                type   = "foreground",
                x = 2000+40-100,
                y = 900,
                source = "yard-barrow",
            },
            {
                type   = "foreground",
                x = 2500+40-100,
                y = 870,
                source = "yard-flamingos",
            },
            {
                type   = "wall_objs",
                source = "yard_2",
                x      = 2*screen_w-693-100,
                y      = 135,
                --scale = {3/4,3/4},
            },
            {
                type   = "foreground",
                x = 3300+70-200-100,
                y = 900-240,
                source = "yard-fountain",
                scale  = {-1,1}
            },
            {
                type   = "foreground",
                x = 3300+40-100,
                y = 900-240,
                source = "yard-fountain",
            },
            {
                type   = "foreground",
                x = 4300+40-100,
                y = 900,
                source = "yard-pool",
            },
            {
                type   = "background",
                x = 4300+40+516-100,
                y = 600-160,
                source = "yard-hammock",
            },
            {
                type   = "wall_objs",
                source = "swamp_1",
                x      = screen_w*4-1803-100,
                y      = 135,
                --scale = {3/4,3/4},
            },
            {
                type   = "wall_objs",
                source = "swamp_2",
                x      = screen_w*6-1803-1110-100,
                y      = 135,
                --scale = {3/4,3/4},
            },
            {
                type   = "wall_objs",
                source = "swamp_3",
                x      = screen_w*8-1803-1110-1313+210-7-100,
                y      = 135,
                w      = 2048+340,
                --scale = {3/4,3/4},
                stop_scroll = true,
                enemy_stop = true,
            },--[[
            {
                type   = "background",
                source = "swamp-splash-btm-cutout",
                x      = 12090,
                y      = 500,
                opacity = 0,
            },--]]
            {
                type   = "background",
                source = "heart",
                x      = 12990,
                y      = 500,
                opacity = 0,
            },
            {
                type   = "background",
                source = "heart1",
                x      = 13190,
                y      = 500,
                opacity = 0,
            },
            {
                type   = "background",
                source = "maxina-eyelids",
                x      = 13290,
                y      = 760,
                opacity = 0,
            },
            {
                type   = "wall_objs",
                source = "swamp_3",
                x      = screen_w*8-1803-1110-1313+210-7-100,
                y      = 135,
                w      = 2048+340,
                --scale = {3/4,3/4},
                stop_scroll = true,
                enemy_stop = true,
            },
        },
        outro = {
            {
                duration = 1,
                on_step = function()
                end,
                on_completed = function()
                    print(1)
                    Animation_Loop:add_animation(  lvls[2].outro[2]  )
                    
                    mediaplayer:play_sound("audio/birds-meet-greet.wav")
                    
                end,
            },
            {
                duration = .3,
                loop     = true,
                on_step  = function(s,p)
                    
                    if p > .3 then
                        
                        lvls[2].outro[2].actors[1].opacity = 0
                        
                    end
                    
                end,
                on_loop = function()
                    
                    lvls[2].outro[2].count = (lvls[2].outro[2].count or 1) + 1
                    print(2)
                    if lvls[2].outro[2].count > 3 then
                        
                        lvls[2].outro[2].count = 0
                        
                        dolater(
                            function()
                                
                                Animation_Loop:delete_animation(lvls[2].outro[2])
                                Animation_Loop:add_animation(  lvls[2].outro[3]  )
                                
                                
                            end
                        )
                        
                    else
                        
                        lvls[2].outro[2].actors[1].opacity = 255
                        
                    end
                end,
            },
            {
                duration = .5,
                on_step = function()
                end,
                on_completed = function()
                    lvls[2].outro[4].actors[1].opacity = 255
                    lvls[2].outro[4].actors[1].scale = {0,0}
                    Animation_Loop:add_animation(  lvls[2].outro[4]  )
                    
                end,
            },
            {
                duration = .5,
                on_step = function(s,p)
                    
                    lvls[2].outro[4].actors[1].scale = {.5*p,.5*p}
                end,
                on_completed = function()
                    Animation_Loop:add_animation(  lvls[2].outro[5]  )
                    
                end,
            },
            {
                duration = .5,
                on_step = function()
                end,
                on_completed = function()
                    lvls[2].outro[6].actors[1].opacity = 255
                    lvls[2].outro[6].actors[1].scale = {0,0}
                    Animation_Loop:add_animation(  lvls[2].outro[6]  )
                    
                end,
            },
            {
                duration = .5,
                on_step = function(s,p)
                    
                    lvls[2].outro[6].actors[1].scale = {.5*p,.5*p}
                end,
                on_completed = function()
                    Animation_Loop:add_animation(  lvls[2].outro[7]  )
                    
                end,
            },
            {
                duration = 1,
                on_step = function(s,p)
                end,
                on_completed = function()
                    gamestate:change_state_to("LVL_TRANSITION")
                    
                end,
            },
        },
        tiling = {
        },
        player_obstacles = {
            {
                x = 5900-100,
                y =  500,
                w =  50,
                h =  600,
                arrow = "up",
            },
        },
        enemy_obstacles = {
            {
                x =  500-100,
                y =  780,
                w =  250,
                h =   30,
            },
            {
                x =  830-100,
                y =  700,
                w =  180,
                h =   30,
            },
            {
                x = 1100-100,
                y =  780,
                w =  180,
                h =   30,
            },
            {
                x = 2026-100,
                y =  220,
                w =  200,
                h =   30,
                pre_exit = true,
            },
            {
                x = 2300-100,
                y =  750,
                w =  200,
                h =   30,
                post_exit = true,
            },
            {
                x = 5654-100,
                y =  830,
                w =  180,
                h =   30,
                reentry = "floorless",
            },
            
            {
                x = 6654-100,
                y =  830,
                w =  200,
                h =   30,
                can_jump_through = true,
            },
            {
                x = 7180-130,
                y =  730,
                w =  200,
                h =   30,
                can_jump_through = true,
            },--[[
            {
                x = 7340,
                y = 1010,
                w =  170,
                h =   30,
                can_jump_through = true,
            },--]]
            {
                x = 7680-200,
                y =  860,
                w =  200,
                h =   30,
                can_jump_through = true,
            },--[[
            {
                x = 7790,
                y = 1010,
                w =  300,
                h =   30,
                can_jump_through = true,
            },--]]
            {
                x = 8110-200,
                y =  750,
                w =  200,
                h =   30,
                can_jump_through = true,
            },--[[
            {
                x = 8350,
                y = 1010,
                w =  270,
                h =   30,
                can_jump_through = true,
            },
            --]]
            {
                x = 8600-100,
                y =  760,
                w =  200,
                h =   30,
                can_jump_through = true,
            },
            {
                x = 9200-100,
                y =  800,
                w =  200,
                h =   30,
                can_jump_through = true,
            },
            {
                x = 10150-100,
                y =   870,
                w =   200,
                h =    30,
                can_jump_through = true,
                cat_exit = true,
            },
        },
        collectables = {
            --table and chairs
            {
                x = 700-100,
                y = 400,
                type = "seed",
            },
            {
                x = 800-100,
                y = 400,
                type = "seed",
            },
            {
                x = 900-100,
                y = 400,
                type = "seed",
            },
            --umbrella
            {
                x = 1300-100,
                y = 100,
                type = "seed",
            },
            {
                x = 1400-100,
                y = 100,
                type = "seed",
            },
            {
                x = 1500-100,
                y = 100,
                type = "seed",
            },
            --wheel barrow
            {
                x = 2000-100,
                y = 800,
                type = "seed",
            },
            {
                x = 2100-100,
                y = 800,
                type = "seed",
            },
            {
                x = 2200-100,
                y = 800,
                type = "seed",
            },
            {
                x = 2700-100,
                y = 800,
                type = "seed",
            },
            {
                x = 2800-100,
                y = 800,
                type = "cherry",
            },
            {
                x = 2900-100,
                y = 800,
                type = "seed",
            },
            
            --fountain
            {
                x = 3100-100,
                y = 800,
                type = "seed",
            },
            {
                x = 3200-100,
                y = 800,
                type = "seed",
            },
            {
                x = 3300-100,
                y = 800,
                type = "seed",
            },
            {
                x = 3700-100,
                y = 800,
                type = "seed",
            },
            {
                x = 3800-100,
                y = 800,
                type = "cherry",
            },
            --fountain
            {
                x = 3900-100,
                y = 800,
                type = "seed",
            },
            {
                x = 4300-100,
                y = 800,
                type = "seed",
            },
            {
                x = 4400-100,
                y = 800,
                type = "seed",
            },
            {
                x = 4500-100,
                y = 800,
                type = "seed",
            },
            
            --pool
            {
                x = 5200-100,
                y = 700,
                type = "cracker",
            },
            {
                x = 5200-100,
                y = 800,
                type = "cracker",
            },
            {
                x = 5400-100,
                y = 700,
                type = "cracker",
            },
            {
                x = 5400-100,
                y = 800,
                type = "cracker",
            },
            {
                x = 5600-100,
                y = 700,
                type = "cracker",
            },
            {
                x = 5600-100,
                y = 800,
                type = "cracker",
            },
            --swamp begin
            {
                x = 7000-100,
                y = 800,
                type = "seed",
            },
            {
                x = 7200-100,
                y = 800,
                type = "seed",
            },
            {
                x = 7400-100,
                y = 800,
                type = "seed",
            },
            {
                x = 7600-100,
                y = 800,
                type = "seed",
            },
            --
            {
                x = 8000-100,
                y = 800,
                type = "seed",
            },
            {
                x = 8200-100,
                y = 800,
                type = "seed",
            },
            {
                x = 8400-100,
                y = 800,
                type = "cherry",
            },
            {
                x = 8600-100,
                y = 800,
                type = "seed",
            },
            {
                x = 8800-100,
                y = 800,
                type = "seed",
            },
            --main tree
            {
                x = 9800-100,
                y = 800,
                type = "cherry",
            },
            {
                x = 9800-100,
                y = 700,
                type = "seed",
            },

        },
        clone_srcs = {
            --[[
            "algae.png",
            "bbq.png",
            "cattail-1.png",
            "cattail-2.png",
            "cattail-3.png",
            "deck.png",
            "deck-chair.png",
            "deck-end-piece.png",
            "deck-table.png",
            "grass-1.png",
            "grass-background.png",
            "lily-flower.png",
            "lily-pads.png",
            "plant-1.png",
            "plant-2.png",
            "plant-3.png",
            "plant-4.png",
            "plant-clump-back-1.png",
            "plant-clump-back-2.png",
            "plant-clump-back-3.png",
            "plant-clump-back-4.png",
            "plant-clump-front-1.png",
            "plant-clump-front-2.png",
            "pots-watercan.png",
            "sidegate.png",
            "sky-water.jpg",
            --]]
            "heart.png",
            "heart1.png",
            "maxina-eyelids.png",
            "swamp_1.jpg",
            "swamp_2.jpg",
            "swamp_3.jpg",
            --"swamp-splash-btm-cutout.jpg",
            --[[
            "tree.png",
            "tree2.png",
            "tree-left.png",
            "tree-limbs.png",
            "tree-middle.png",
            "umbrella.png",
            "water-waves.png",
            --]]
            "umbrella.png",
            "yard_1.jpg",
            "yard_2.jpg",
            "yard-barrow.png",
            "yard-fence-piece.jpg",
            "yard-flamingos.png",
            "yard-flowers.png",
            "yard-fountain.png",
            "yard-hammock.png",
            "yard-pool.png",
            --"yard_3.jpg",
            --[[
            "yard-barrow.png",
            "yard-bush.png",
            "yard-deck.png",
            "yard-doghouse.png",
            "yard-fence.png",
            "yard-fence-end.jpg",
            "yard-flamingos.png",
            "yard-flowers.png",
            "yard-football.png",
            "yard-fountain.png",
            "yard-hammock.png",
            "yard-pool.png",
            "yard-rake.png",
            "yard-tree1.png",
            "yard-tree2.png",
            "yard-treetop1.png",
            "yard-treetop2.png",
            "yard-treetop3.png",
            "yard_waterdrop.png",
            "yard-waterdrop.png",
            --]]
        }
    }
}


--------------------------------------------------------------------------------
----  The Level Loader
--------------------------------------------------------------------------------
local LVL_Object  = {}

local has_been_initialized = false

local lvl_srcs    = Group{}
-- inited globals
local layers, physics_world

local generic_imgs = {}
local generic_imgs_g = Group{name="generic assets"}

function LVL_Object:init(t)
    
    if has_been_initialized then
        
        error("LVL_Object has already been initialized",2)
        
    end
    
    has_been_initialized = true
    
    --assert that everything that needs to be initialized is being initialized
    if type(t.layers) ~= "table" then
        
        error("LVL_Object:init() did not receive proper layers",2)
        
    elseif type(t.physics_world) ~= "userdata" then
        
        error("LVL_Object:init() did not receive proper physics_world",2)
        
    end
    
    layers        = t.layers
    physics_world = t.physics_world
    
    layers.srcs:add(lvl_srcs)
    
    for i, src in ipairs(generic_srcs) do
        
        obj = Image{src = "assets/collectables/"..src}
        
        generic_imgs[
            string.sub(
                src,
                1,
                string.find(
                    src,
                    "%."
                ) - 1
            )
        ] = obj
        
        generic_imgs_g:add(obj)
    end
    
    dumptable(generic_imgs)
    generic_imgs_g:hide()
    
    layers.srcs:add(generic_imgs_g)
    
    lvl_srcs:hide()
    print("me")
end

--current level data


--local curr_lvl    = Group{}
local curr_lvl_i  = 1

local lvl_objs        = {} --contains the Image{}'s from lvls[i].clone_srcs
local on_screen_items = {}

local tiling_i      = 1
local item_i        = 1
local collectable_i = 1
local player_obst_i = 1

local items        = lvls[curr_lvl_i].items        --pointer to items
local tiling       = lvls[curr_lvl_i].tiling       --pointer to tiling
local collectables = lvls[curr_lvl_i].collectables --pointer to tiling
local player_obst  = lvls[curr_lvl_i].collectables --pointer to tiling

local final_edge = nil
local call_before_outro, outro_actors
function LVL_Object:curr_lvl() return curr_lvl_i end

local base_path = "assets/lvl"
function LVL_Object:setup_for_level(t)
    
    if not has_been_initialized then
        error("LVL_Object has not been initialized",2)
    end
    
    scroll_speed = t.scroll_speed or 100
    curr_lvl_i   = t.level        or error("Must specify which 'level'",2)
    
    --clear out everything
    LVL_Object.obstacles = {}
    lvl_objs = {}
    lvl_srcs:clear()
    --curr_lvl:clear()
    physics_world.x = screen_w
    
    LVL_Object.left_screen_edge  = -screen_w
    LVL_Object.right_screen_edge = LVL_Object.left_screen_edge + screen_w
    
    t.set_progress(#lvls[curr_lvl_i].clone_srcs)
    
    --load up the assets for the level
    for _,img in pairs(lvls[curr_lvl_i].clone_srcs) do
        
        obj = Image{ src = "assets/lvl"..curr_lvl_i.."/"..img }
        
        lvl_srcs:add(obj)
        
        lvl_objs[
            string.sub(
                img,
                1,
                string.find(
                    img,
                    "%."
                ) - 1
            )
        ] = obj
        
        t.inc_progress()
        
    end
    
    -- get the list of obstacles
    
    local exit_count = 0
    
    for j = 1, # lvls[curr_lvl_i].items do
        
        if lvls[curr_lvl_i].items[j].exit_piece then
            
            exit_count = exit_count + 1
            
            local other_exit_count = 0
            
            for i = 1, # lvls[curr_lvl_i].enemy_obstacles do
                
                if lvls[curr_lvl_i].enemy_obstacles[i].pre_exit then
                    
                    other_exit_count = other_exit_count + 1
                    
                    if exit_count == other_exit_count then
                        
                        lvls[curr_lvl_i].enemy_obstacles[i].exit_piece =
                            lvls[curr_lvl_i].items[j]
                        lvls[curr_lvl_i].items[j].exit_link = lvls[curr_lvl_i].enemy_obstacles[i]
                        break
                        
                    end
                end
                
            end
            
        end
        if lvls[curr_lvl_i].items[j].enemy_stop then
            
            LVL_Object.enemy_stop = lvls[curr_lvl_i].items[j].x
            
        end
        if lvls[curr_lvl_i].items[j].stop_scroll then
            
            LVL_Object.stop_scroll = lvls[curr_lvl_i].items[j].x + lvls[curr_lvl_i].items[j].w
            
        end
    end
    
    LVL_Object.obstacles = lvls[curr_lvl_i].enemy_obstacles
    ---[[
    for j,o in ipairs(LVL_Object.obstacles) do
        layers.foreground:add(Rectangle{x = o.x,y = o.y, w = o.w, h = o.h, color="77770099"})
    end
    for j,o in ipairs(lvls[curr_lvl_i].player_obstacles) do
        layers.foreground:add(Rectangle{x = o.x,y = o.y, w = o.w, h = o.h, color="00777755"})
    end
    --]]
    -- reset the counters    
    tiling_i      = 1
    item_i        = 1
    collectable_i = 1
    player_obst_i = 1
    
    items        = lvls[curr_lvl_i].items  
    tiling       = lvls[curr_lvl_i].tiling 
    collectables = lvls[curr_lvl_i].collectables
    player_obst  = lvls[curr_lvl_i].player_obstacles
    outro_actors      = t.outro_actors
    call_before_outro = t.call_before_outro
    
    if t.intro_actors then
        
        local need_actors = {}
        
        for i,as in pairs(t.intro_actors) do
            
            for j,actor_i in pairs(as) do
                print("gggg")
                need_actors[actor_i] = true
                
            end
            
        end
        
        dumptable(need_actors)
        
        self:scroll_by(physics_world.x,need_actors)
        
        
        dumptable(need_actors)
        dumptable(t.intro_actors)
        for i,as in pairs(t.intro_actors) do
            
            lvls[curr_lvl_i].intro[i].actors = {}
            
            for j,actor_i in pairs(as) do
                
                lvls[curr_lvl_i].intro[i].actors[j] = need_actors[actor_i]
                
            end
            
        end
        
        lvls[curr_lvl_i].intro.post_intro_funcs = t.call_after_intro
        
        Animation_Loop:add_animation(lvls[curr_lvl_i].intro[1],"ACTIVE")
        
        dumptable(lvls[curr_lvl_i].intro)
        
    else
        
        self:scroll_by(physics_world.x)
        
        Animation_Loop:add_animation(LVL_Object.on_idle,"ACTIVE")
        
    end
    
    
    
    
    
end



--upvals
local dx, obj

local function make_obj(item)
    
    local obj
    
    if type(item.source) == "string" then
        
        obj = Clone{
            name   = item.source,
            source = lvl_objs[ item.source ],
            x      = item.x,
            y      = item.y,
            opacity = item.opacity,
        }
        
        if item.scale then
            obj.scale  = {
                4/3*item.scale[1],
                4/3*item.scale[2]
            }
        else
            obj.scale  = {
                4/3,
                4/3
            }
        end
        
    elseif type(item.pieces) == "table" then
        
        obj = Group{
            x      = item.x,
            y      = item.y,
        }
        
        for _,piece in pairs(item.pieces) do
            
            obj:add(
                Clone{
                    name   = piece.source,
                    source = lvl_objs[ piece.source ],
                    x      = piece.x,
                    y      = piece.y,
                }
            )
            
        end
    else
        
        error("item needs either a source string or a pieces table")
        
    end
    
    
    
    if item.anchor_point then
        obj:move_anchor_point(  unpack(item.anchor_point)  )
    else
        obj:move_anchor_point(obj.w/2,obj.h/2)
    end
    
    if item.type == "static" then
        
        assert(item.source)
        
        layers.items:add( obj )
        
    elseif items[item_i].type == "dynamic" then
        
        layers.items:add( obj )
        
        Item{
                source         = obj,
                item_type      = "knockdownable",
                targ_y         = 1200,
                initial_impact = function() end,
                m              = items[item_i].m
            }
        collides_with_max[obj]   = obj
        collides_with_enemy[obj] = obj
    else
        
        assert(item.source)
        
        assert(layers[item.type],item.type.." is not a layer")
        
        layers[item.type]:add(obj)
        
        
    end
    
    
    on_screen_items[ obj ] = obj.x + (item.w and item.w - obj.w/2 or obj.w/2*4/3)
    
    if item.exit_link then
        item.exit_link.exit_piece = obj
    end
    
    clone_counter[obj] = obj.source and obj.source.src or true
    
    return obj
    
end





function LVL_Object:add_to_scroll_off(obj)
    
    on_screen_items[ obj ] = obj.x + obj.w
    
end


function LVL_Object:scroll_by(dx,need_actors)
    
    if not has_been_initialized then
        
        error("LVL_Object has not been initialized",2)
        
    end
    
    --dx = SCROLL_SPEED*s
    LVL_Object.left_screen_edge  = LVL_Object.left_screen_edge  + dx
    LVL_Object.right_screen_edge = LVL_Object.right_screen_edge + dx
    
    physics_world.x = physics_world.x - dx
    
    --exit clause
    if LVL_Object.right_screen_edge > LVL_Object.stop_scroll then
        
        physics_world.x = -(LVL_Object.stop_scroll - screen_w)
        LVL_Object.right_screen_edge = LVL_Object.right_screen_edge + 1000
        print("exit clause")
        Animation_Loop:delete_animation(LVL_Object.on_idle)
        
        if lvls[curr_lvl_i].outro then
            
            for i,as in pairs(outro_actors) do
                
                lvls[curr_lvl_i].outro[i].actors = {}
                
                for j,actor_name in pairs(as) do
                    
                    lvls[curr_lvl_i].outro[i].actors[j] = screen:find_child(actor_name)
                    
                end
                
            end
            
            dumptable(lvls[curr_lvl_i].outro)
            
            Animation_Loop:add_animation(lvls[curr_lvl_i].outro[1])
            
            for f,p in pairs(call_before_outro) do
                
                f(p)
                
            end
            
        end
        
        return
        
    end
    
    -- remove objects that scrolled off the left side
    for obj,right_edge in pairs(on_screen_items) do
        
        if right_edge < -physics_world.x then
            print("delete")
            if obj.parent then obj:unparent() end
            
            if obj.on_idle then
                if Animation_Loop:has_animation(obj.on_idle) then
                    
                    Animation_Loop:delete_animation(obj.on_idle)
                    
                end
                obj.on_idle = nil
                
            end
            
            on_screen_items[     obj ] = nil
            collides_with_max[   obj ] = nil
            collides_with_enemy[ obj ] = nil
            
        end
        
        
    end
    
    
    for i,obj in pairs(layers.distance.children) do
        obj.x = obj.x+dx/15
        on_screen_items[ obj ] = obj.x + obj.w
    end
    ---[[
    while  tiling_i <= # tiling   and
        tiling[tiling_i].x    <    ( 2*screen_w - physics_world.x)  do
        
        local obj = Image{
            src    = "assets/lvl"..curr_lvl_i.."/"..tiling[tiling_i].source,
            x      = tiling[ tiling_i ].x,
            y      = tiling[ tiling_i ].y,
            tile   = { true, false },
            w      = tiling[ tiling_i ].w,
            h      = tiling[ tiling_i ].h,
        }
        
        if tiling[tiling_i].type then
            layers[tiling[tiling_i].type]:add( obj )
        else
            layers.wall:add( obj )
        end
        
        on_screen_items[ obj ] = obj.x + obj.w
        
        tiling_i = tiling_i + 1
        
    end
    
    while  player_obst_i <= # player_obst   and
        player_obst[player_obst_i].x    <    (  2*screen_w - physics_world.x)  do
        
        local obj = player_obst[player_obst_i]
        
        collides_with_max[obj] = obj
        
        obj.anchor_point = {0,0}
        
        obj.collision = Max.undo_move
        
        on_screen_items[ obj ] = obj.x + obj.w
        
        player_obst_i = player_obst_i + 1
        
    end
    ---[[
    while  collectable_i <= # collectables   and
        collectables[collectable_i].x    <    (  2*screen_w - physics_world.x)  do
        
        local obj = Clone{
            x     = collectables[collectable_i].x,
            y     = collectables[collectable_i].y,
        }
        if collectables[collectable_i].type == "seed" then
            
            obj.source = generic_imgs["seed"]
            
            obj = Item{
                source         = obj,
                item_type      = "collectable",
                initial_impact = Max.collect_seed,
                pieces = {
                    generic_imgs["seed-back"],
                    generic_imgs["seed"],
                }
            }
            
        elseif collectables[collectable_i].type == "cherry" then
            
            obj.source = generic_imgs["cherry"]
            
            obj = Item{
                source         = obj,
                item_type      = "collectable",
                initial_impact = Max.collect_cherry,
                pieces = {
                    generic_imgs["cherry-stem-1"],
                    generic_imgs["cherry-stem-2"],
                    generic_imgs["cherry-leaf"],
                },
            }
            
        elseif collectables[collectable_i].type == "cracker" then
            
            obj.source = generic_imgs["cracker"]
            
            obj = Item{
                source         = obj,
                item_type      = "collectable",
                initial_impact = Max.collect_seed,
                pieces = {
                    generic_imgs["cracker-crumble1"],
                    generic_imgs["cracker-crumble2"],
                },
            }
            
        end
        clone_counter[obj] = obj.source.src
        
        obj.anchor_point = {
            obj.w/2,
            obj.h/2,
        }
        
        
        collides_with_max[obj] = obj
        
        
        layers.items:add(obj)
        
        on_screen_items[ obj ] = obj.x + obj.w
        
        collectable_i = collectable_i + 1
        
    end
    
    --]]
    
    -- add objects that are supposed to have come into view
    
    --print("items",item_i , # items)
    --print("x's",items[item_i].x    ,    (  2*screen_w - physics_world.x))
    
    while  item_i <= # items   and
        items[item_i].x    <    (  2*screen_w - physics_world.x  )  do
        
        --print("add item")
        
        if type(items[item_i].tile) == "table" then
            
            local orig_x = items[item_i].x
            local orig_y = items[item_i].y
            
            --print("\n\n\nPREEENT:\t\t",orig_x,orig_y,"\n\n\n")
            
            for i = 1, items[item_i].tile[1] do
                for j = 1, items[item_i].tile[2] do
                    
                    --print(i,j)
                    
                    items[item_i].x = orig_x + (i-1)*lvl_objs[ items[item_i].source ].w*4/3
                    items[item_i].y = orig_y + (j-1)*lvl_objs[ items[item_i].source ].h*4/3
                    
                    make_obj(items[item_i])
                    
                end
            end
            
            items[item_i].x = orig_x
            items[item_i].y = orig_y
            
        else
            
            if need_actors and need_actors[item_i] then
                
                need_actors[item_i] = make_obj(items[item_i])
                
            else
                
                make_obj(items[item_i])
                
            end
            
        end
        
        item_i = item_i + 1
        
    end
    
end


LVL_Object.on_idle = {
    
    on_step = function(s)   LVL_Object:scroll_by(scroll_speed*s)   end
    
}

function LVL_Object:unload_lvl()
    obj = nil
    print("this happens")
    
    if Animation_Loop:has_animation(LVL_Object.animation) then
        
        Animation_Loop:delete_animation(LVL_Object.animation)
        
    elseif lvls[curr_lvl_i].outro then
        
        for i,o in ipairs(lvls[curr_lvl_i].outro) do
            
            o.actors = nil
            if Animation_Loop:has_animation(o) then
                
                Animation_Loop:delete_animation(o)
                
            end
            
        end
        
    end
    
    if lvls[curr_lvl_i].intro then
        for _,i in ipairs(lvls[curr_lvl_i].intro) do
            
            i.actors = nil
            
        end
    end
    for obj,_ in pairs(on_screen_items) do
        
        
        if obj.parent then obj:unparent() end
        
        if obj.on_idle then
            if Animation_Loop:has_animation(obj.on_idle) then
                
                Animation_Loop:delete_animation(obj.on_idle)
                
            end
            obj.on_idle = nil
            
        end
        
        on_screen_items[     obj ] = nil
        collides_with_max[   obj ] = nil
        collides_with_enemy[ obj ] = nil
        
    end
    on_screen_items     = {}
    collides_with_max   = {}
    collides_with_enemy = {}
    
    layers.distance:clear()
    
    layers.wall:clear()
    layers.wall_objs:clear()
    layers.background:clear()
    layers.items:clear()
    layers.player:clear()
    layers.enemy:clear()
    layers.foreground:clear()
    
    LVL_Object.obstacles = {}
    lvl_objs = {}
    lvl_srcs:clear()
    
    collectgarbage("collect")
end

gamestate:add_state_change_function(
    function()
        LVL_Object:unload_lvl()
    end,
    "ACTIVE","LVL_TRANSITION"
)

--[[
local seg
local speed = 100
LVL_Object.scroll_by = {
    
    on_step = function(s)
        
        --scroll the level
        curr_level.x = curr_level.x + speed*s
        
        --check to see if you scrolled off the right edge
        if curr_level.x > right_border then
            
            --add the next segment
            segment_i = segment_i + 1
            
            seg = segments[segment_i]
            
            if seg then
                
                --remove the leftmost segment
                seg:unparent()
                
                curr_level:add(seg)
                
                --screen can see up to 2 segments
                seg = segments[segment_i-2]
                
                if seg then
                    
                    seg:unparent()
                    
                    not_visible:add(seg)
                    
                end
                
                right_border = right_border + screen_w
                
            --there is no next segment
            else
                
                curr_level.x = right_border
                
                --stop scrolling the level, you reached the end
                Animation_Loop:remove(LVL_Object.scroll_by)
                
                if LVL_Object.on_end_of_level then
                    LVL_Object:on_end_of_level(right_border)
                end
                
            end
            
        end
        
    end
}
--]]

return LVL_Object