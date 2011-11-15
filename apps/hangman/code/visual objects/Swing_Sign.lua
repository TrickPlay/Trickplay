local self = Group{name = "Swing Sign", y = -200}

local sway_dist = 0
sway_interval = Interval(0,0);

--Timelines
local sway, new_text_tl_1, new_text_tl_2, pull_up, drop
--visual pieces
local sign_g, fade_in_txt, sign_text

local hold = false
local hold_timer = Timer{
    on_timer = function(self_timer)
        assert(hold,"something went wrong")
        hold = false
        self_timer:stop()
    end
}
hold_timer:stop()

sway = Timeline{
    duration     = 1000,
    on_started = function()
        
        sway_interval.from = sway_interval.to
        sway_interval.to   = sway_interval.from/2
        
        if  sway_interval.to  <= 1 then
            sway_interval.from = 1
            sway_interval.to   = 1
        end
        
    end,
    on_new_frame = function(self,ms,p)
        
        sway_dist = sway_interval:get_value(p)
        
        if math.cos(math.pi*2*p) > 0 then
            sign_g.x_rotation = {-sway_dist*math.cos(math.pi*2*p)*2,0,0}
        else
            sign_g.x_rotation = {-sway_dist*math.cos(math.pi*2*p),0,0}
        end
        
    end,
    on_completed = function(self)
        
        if new_text == false then
            
            pull_up:start()
            
        elseif new_text ~= nil then
            
            new_text_tl_1:start()
            
        else
            
            self:start()
            
        end
        
    end
    
}

new_text_tl_1 = Timeline{
    duration  = sway.duration / 4,
    on_started = function()
        fade_in_txt.markup = new_text
        fade_in_txt.txt = new_text
        new_text = nil
        sway_interval.from = sway_interval.to
        sway_interval.to   = 20
    end,
    on_new_frame = function(self,ms,p)
        if math.cos(math.pi/2*p) > 0 then
            sign_g.x_rotation = {-sway_interval.from*math.cos(math.pi/2*p)*2,0,0}
        else
            sign_g.x_rotation = {-sway_interval.from*math.cos(math.pi/2*p),0,0}
        end
        sign_g.x_rotation   = {-sway_interval.from*math.cos(math.pi/2*p),0,0}
        fade_in_txt.scale   = {1+.3*(1-p),1+.3*(1-p)}
        fade_in_txt.opacity =   155+100*p
    end,
    on_completed = function(self)
        new_text_tl_2:start()
    end
    
}

new_text_tl_2 = Timeline{
    duration  = sway.duration / 4,
    on_started = function()
        sign_text.markup = fade_in_txt.txt
        sign_text_s.markup = fade_in_txt.txt
        fade_in_txt.opacity = 0
    end,
    on_new_frame = function(self,ms,p)
        if math.sin(math.pi/2*p) > 0 then
            sign_g.x_rotation = {-sway_interval.to*math.sin(math.pi/2*p)*2,0,0}
        else
            sign_g.x_rotation = {-sway_interval.to*math.sin(math.pi/2*p),0,0}
        end
    end,
    on_completed = function(self)
        print("complete: new_text_tl_2",sign_g.x_rotation[1])
        if new_text == false then
            pull_up:start()
        elseif new_text ~= nil then
            new_text_tl_1:start()
        else
            sway:start()
        end
    end
    
}

sign_y_interval = Interval(0,0)
pull_up = Timeline{
    duration  = sway.duration / 2,
    mode = "EASE_IN_BACK",
    on_started = function()
        new_text = nil
        sign_y_interval.from = self.y
        sign_y_interval.to   = -200
    end,
    on_new_frame = function(tl,ms,p)
        self.y = sign_y_interval:get_value(p)
    end,
    on_completed = function(self)
        if new_text then
            drop:start()
        end
    end
    
}

drop = Timeline{
    duration  = sway.duration / 2,
    mode = "EASE_OUT_BACK",
    on_started = function()
        sign_text.markup   = new_text
        sign_text_s.markup = new_text
        new_text = nil
        sign_y_interval.from = self.y
        sign_y_interval.to   = -5
    end,
    on_new_frame = function(tl,ms,p)
        self.y = sign_y_interval:get_value(p)
    end,
    on_completed = function(self)
        if new_text == false then
            pull_up:start()
            
        elseif new_text then
            new_text_tl_1:start()
        else
            sway:start()
        end
    end
    
}

function self:init(t)
    
    
    local sign_clone = Clone{source = t.img_srcs.sign}
    
    sign_text = Text{
        text  = "",
        color = "black",
        font  = "Maiden Orange 48px",
        w     = t.img_srcs.sign.w-80,
        x     = t.img_srcs.sign.w/2,
        y         = t.img_srcs.sign.h-43,
        ellipsize = "END",
        alignment = "CENTER",
        on_text_changed = function(self)
            
            self.anchor_point = {self.w/2,self.h/2}
            
        end,
    }
    
    sign_text_s = Text{
        text  = "",
        color = "87410E",
        font  = "Maiden Orange 48px",
        w     = t.img_srcs.sign.w-80,
        x     = t.img_srcs.sign.w/2-2,
        y         = t.img_srcs.sign.h-43-2,
        ellipsize = "END",
        alignment = "CENTER",
        on_text_changed = function(self)
            
            self.anchor_point = {self.w/2,self.h/2}
            
        end,
    }
    
    sign_g = Group{x = screen_w/2}
    sign_g.anchor_point = {t.img_srcs.sign.w/2,0}
    sign_g:move_anchor_point(t.img_srcs.sign.w/2,-100)
    sign_g:add(sign_clone,sign_text)
    
    fade_in_txt   = Text{
        text      = "",
        x         = sign_g.x,
        y         = t.img_srcs.sign.h-43,
        color     = "black",
        font      = "Maiden Orange 48px",
        w         = t.img_srcs.sign.w,
        ellipsize = "END",
        alignment = "CENTER",
        on_text_changed = function(self)
            
            self.anchor_point = {self.w/2,self.h/2}
            
        end,
    }
    
    self:add(sign_g,fade_in_txt)
    
end

function self:holding() return hold end
function self:new_text(text,lock_message)
    
    if hold then
        
        print("Swing_Sign:new_text(",text,",",lock_message,"): can't... holding")
        
        return false
        
    end
    print("Swing_Sign:new_text(",text,",",lock_message,")")
    new_text = text
    
    if lock_message then
        
        hold = true
        hold_timer.interval = lock_message
        hold_timer:start()
        
    end
    
    if  sway.is_playing or
        new_text_tl_1.is_playing or
        new_text_tl_2.is_playing or
        pull_up.is_playing or
        drop.is_playing then
        
        new_text = text
        
    elseif text then
        print("dahhhh")
        new_text = text
        drop:start()
        
    end
    
end

return self