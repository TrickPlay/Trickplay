local spacing = 65
local first_x = 37

local focus_scale = 1.2
local unsel_scale = 1

local bottles = {
    Image{src="assets/left/bottles/1.png"},
    Image{src="assets/left/bottles/2.png"},
    Image{src="assets/left/bottles/3.png"},
    Image{src="assets/left/bottles/4.png"},
    Image{src="assets/left/bottles/5.png"},
    Image{src="assets/left/bottles/6.png"},
    Image{src="assets/left/bottles/7.png"},
    Image{src="assets/left/bottles/8.png"},
}

local selector_old = Image{src = "assets/left/bottle-focus.png",x=first_x + bottles[1].w/2}
selector_old.anchor_point = {selector_old.w/2,selector_old.h-14}

local selector_new = Clone{source = selector_old,opacity = 0}
selector_new.anchor_point = {selector_new.w/2,selector_new.h-14}


local dock = Group{name="BOTTLE DOCK"}

dock:add(selector_old,selector_new)
dock:add(unpack(bottles))
for i,img in pairs(bottles) do
    img.anchor_point = {img.w/2,img.h}
    img.name = "BOTTLE "..i
    img.x    = first_x + spacing * (i - 1) + img.w/2
    img.scale = {unsel_scale,unsel_scale}
end
bottles[1].scale = {focus_scale,focus_scale}
dock.y = bottles[1].h+100



dock.focus_out = function(self,index,duration)
    
    assert(index > 0 and index <= #bottles)
    
    bottles[index]:complete_animation()
    
    bottles[index]:animate{
        duration = duration,
        mode     = "EASE_OUT_CIRC",
        scale={unsel_scale,unsel_scale}
    }
    
    selector_old.x = bottles[index].x
    
    selector_old:complete_animation()
    
    selector_old.scale = {focus_scale,focus_scale}
    
    selector_old.opacity = 255
    
    selector_new.opacity = 0
    
    selector_old:animate{
        duration = duration,
        scale = {unsel_scale,unsel_scale},
        mode     = "EASE_OUT_CIRC",
        opacity  = 0
    }
    
end

dock.focus_in = function(self,index,duration)
    
    assert(index > 0 and index <= #bottles)
    
    bottles[index]:complete_animation()
    
    bottles[index]:animate{
        duration = duration,
        mode     = "EASE_OUT_CIRC",
        scale={focus_scale,focus_scale}
    }
    
    selector_new.x = bottles[index].x
    
    selector_new:complete_animation()
    
    selector_new.scale = {unsel_scale,unsel_scale}
    
    
    
    selector_new:animate{
        duration = duration,
        scale = {focus_scale,focus_scale},
        mode     = "EASE_OUT_CIRC",
        opacity  = 255,
        on_completed = KEY_HANDLER.release
    }
    
end



return dock
