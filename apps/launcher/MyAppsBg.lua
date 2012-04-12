
local animation = Group{}


local star, circle, cloud

local recycled_stars = {}




function make_star()
    
    local sc = .8+(.4*math.random()-.2)
    
    local s = Group{scale = {sc,sc},opacity = 0}
    
    s.light = Clone{source = star,opacity = 0}
    
    s:add(Clone{source = circle,position = {15,15}},s.light)
    
    
    local tot_dur = 1500 + 14000+4000*math.random() + 500
    
    local start_x = 100+300*math.random()
    local start_y = 100+750*math.random()
    
    s.animator = Animator{
        duration = tot_dur,
        properties = {
            {
                source = s,  name = "x",
                keys = {
                    {0.0, "LINEAR", start_x},
                    {1.0, "LINEAR", start_x + 20+80*math.random()},
                }
            },
            {
                source = s,  name = "y",
                keys = {
                    {0.0, "LINEAR", start_y},
                    {1.0, "LINEAR", start_y + 20+80*math.random()},
                }
            },
            {
                source = s,  name = "opacity",
                keys = {
                    {0.0, "LINEAR", 0},
                    {1500/tot_dur, "LINEAR", 180},
                    {(tot_dur-500)/tot_dur, "LINEAR", 180},
                    {1.0, "LINEAR", 0},
                }
            },
            math.random(1,10) < 8 and {
                source = s.light,  name = "opacity",
                keys = {
                    {0.0, "LINEAR", 0},
                    {1500/tot_dur, "LINEAR", 0},
                    {4000/tot_dur, "LINEAR", 180},
                }
            } or nil,
        },
        timeline = Timeline{
            duration = tot_dur,
            on_started = function()
                s.x = start_x
                s.y = start_y
                
                animation:add(s)
            end,
            on_completed = function()
                s:unparent()
                
                table.insert(recycled_stars,s)
            end
        }
    }
    
    return s
end

function animation:init(p)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    --Clone Sources for:
    --Star
    star = Canvas(50,50)
    star:rectangle(0,0,star.w,star.h)
    star:set_source_radial_pattern(
        star.w/2, star.h/2,
        2,
        
        star.w/2, star.h/2,
        star.w/2
    )
    
    star:add_source_pattern_color_stop( 0, "#ffffffff")
    star:add_source_pattern_color_stop(.5, "#0000ff55")
    star:add_source_pattern_color_stop(.9, "#0000ff00")
    
    star:fill()
    
    star = star:Image()
    
    --Circle
    circle = Canvas(20,20)
    circle:arc(circle.w/2,circle.h/2,circle.w/2,0,360)
    circle:set_source_color("#9999ff99")
    circle:fill()
    
    circle = circle:Image()
    
    p.img_srcs:add(star,circle)
    
    --define the clipping region
    self.clip = {0,0,
        p.visible_w or error("must pass 'visible_w'",2),
        p.visible_h or error("must pass 'visible_h'",2),
    }
    
    --setup up the tiled bg cloud
    cloud = Image{
        src     = "assets/cloud_stars_animation/clouds.png",
        tile    = {true,true},
        opacity = 150
    }
    local cloud_orig_w = cloud.w
    local cloud_orig_h = cloud.h
    
    cloud.w = p.visible_w*3
    cloud.h = p.visible_h*3
    
    --the blue color
    local color = Rectangle{w=p.visible_w,h=p.visible_h,color = {10,40,45},opacity = 220}
    
    local base_tl = Timeline{
        duration  = 30000,
        loop      = true,
        on_new_frame = function(tl,ms,prog)
            cloud.x  = -cloud_orig_w*prog
            cloud.y  = -cloud_orig_h*prog
            color.opacity = 215+10*math.sin(math.pi*2*prog)
        end,
    }
    
    local s
    
    local make_star = Timer{
        interval = 800,
        on_timer = function()
            
            s = table.remove(recycled_stars) or make_star()
            
            s.animator:start()
            
        end
    }
    
    base_tl:start()
    
    self:add(cloud,color)
    
end

return animation