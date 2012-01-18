local cloud = Image{src = "assets/cloud_stars_animation/clouds.png",tile={true,true},opacity = 150}
cloud.orig_w = cloud.w
cloud.orig_h = cloud.h
--cloud.w = cloud.w*4
--cloud.h = cloud.h*4
local animation = Group{}


local star = Canvas(50,50)
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
star:hide()
screen:add(star)


local circle = Canvas(20,20)
circle:arc(circle.w/2,circle.h/2,circle.w/2,0,360)
circle:set_source_color("#9999ff99")
circle:fill()

circle = circle:Image()
circle:hide()
screen:add(circle)

function fade_out_star(obj,vx,vy)
    
    obj:animate{
        duration = 500,
        opacity  = 0,
        --x        = obj.x + vx*.5,
        --y        = obj.y + vy*.5,
        on_completed = function()
            obj:unparent()
        end
    }
    
end

function light_up(obj)
    
    obj.light:animate{
        mode     = "EASE_IN_QUINT",
        duration = 2500,
        opacity  = 180,--255,
    }
    
end

function travel(obj)
    
    obj:animate{
        duration = 14000+4000*math.random(),
        opacity  = 0,
        x        = obj.x + 100*math.random(),
        y        = obj.y + 100*math.random(),
        on_completed = function()
            fade_out_star(obj)
        end
    }
    
end

function fade_in_star(obj)
    
    obj:animate{
        duration = 1500,
        opacity  = 180,--255,
        x        = obj.x + 2,
        y        = obj.y + 2,
        on_completed = function()
            travel(obj)
            if math.random() < .7 then light_up(obj) end
        end
    }
    
end


function make_star()
    
    local sc = .8+(.4*math.random()-.2)
    
    local s = Group{x = 100+300*math.random(),y = 100+750*math.random(),scale = {sc,sc},opacity = 0}
    
    s.light = Clone{source = star,opacity = 0}
    
    s:add(Clone{source = circle,position = {15,15}},s.light)
    
    
    animation:add(s)
    
    return s
end

function animation:init(p)
    
    if type(p) ~= "table" then error("must pass a table",2) end
    
    self.clip = {0,0,
        p.visible_w or error("must pass 'visible_w'",2),
        p.visible_h or error("must pass 'visible_h'",2),
    }
    
    cloud.w = p.visible_w*3
    cloud.h = p.visible_h*3
    
    
    --local backing = Rectangle{w=p.visible_w,h=p.visible_h,color = {10,40,45}}
    local color = Rectangle{w=p.visible_w,h=p.visible_h,color = {10,40,45},opacity = 220}
    
    local base_tl = Timeline{
        duration = 30000,
        loop = true,
        on_new_frame = function(tl,ms,prog)
            cloud.x = -cloud.orig_w*prog
            cloud.y = -cloud.orig_h*prog
            color.opacity = 215+10*math.sin(math.pi*2*prog)
        end,
    }
    
    local s
    
    local make_star = Timer{
        interval = 600,
        on_timer = function()
            
            s = make_star()
            
            --s:lower_to_bottom()
            
            fade_in_star( s )
            
            --color:raise_to_top()
            
        end
    }
    
    base_tl:start()
    
    self:add(cloud,color)
    
end

return animation