
local letter_slots = Group{x = 85, y = 780, name = "Letter Slots"}

local slots        = {}
local lights       = {}
local q_marks      = {}
local letters      = {}

local initialized  = false

function letter_slots:init(t)
    
    if initialized then error("already initialized") end
    
    if type(t)           ~= "table"  then error("parameter must be a table",2) end
    if type(t.num_slots) ~= "number" then error("must pass num_slots",      2) end
    if type(t.font)      ~= "string" then error("must pass font",           2) end
    if type(t.img_srcs)  ~= "table"  then error("must pass img_srcs",       2) end
    
    lights_up_on_complete = t.lights_up_on_complete or error("must pass lights_up_on_complete",2)
    
    local bg_on  = t.img_srcs.letter_bg_on
    local bg_off = t.img_srcs.letter_bg_off
    local q      = t.img_srcs.q_mark
    
    for i = 1, t.num_slots do
        
        lights[i]        = Clone{
            source       =  bg_on,
            anchor_point = {bg_on.w/2,bg_on.h/2},
            position     = {bg_on.w/2 + (bg_on.w + 4)*(i-1), bg_on.h/2+3},
            opacity      = 0,
        }
        slots[i]         = Clone{
            source       =  bg_off,
            anchor_point = {bg_off.w/2,bg_off.h/2},
            x            = lights[i].x,
            y            = lights[i].y - 3,
        }
        q_marks[i]       = Clone{
            source       =  q,
            anchor_point = {q.w/2,q.h/2},
            position     =  slots[i].position,
            opacity      =  0,
        }
        letters[i]       = Text{
            font         = t.font .. " bold 130px",
            text         = "",
            x            = q_marks[i].x,
            y            = q_marks[i].y+5,
            color        = "000000",
        }
    end
    
    letter_slots:add( unpack(slots)   )
    letter_slots:add( unpack(lights)  )
    letter_slots:add( unpack(q_marks) )
    letter_slots:add( unpack(letters) )
    
    initialized = true
    
end

local num_active
function letter_slots:light_up(num)
    
    if type(num) ~= "number" or num > # lights then error("param must be less then num_slots", 2) end
    
    num_active = num
    local lights_up = {duration = 2000,properties = {}}
    
    for i = 1, num do
        
        lights_up.properties[i] = {
            source = lights[i],
            name   = "opacity",
            keys   = {
                {  0.0,          "LINEAR",    0 },
                {  i   /(num+2), "LINEAR",    0 },
                { (i+1)/(num+2), "LINEAR",  255 },
                {  1.0,          "LINEAR",  255 },
            },
        }
        if letters[i].text == "" then
            lights_up.properties[i+num] = {
                source = q_marks[i],
                name   = "opacity",
                keys   = {
                    {  0.0,            "LINEAR",    0 },
                    { (num+1)/(num+2), "LINEAR",    0 },
                    {  1.0,            "LINEAR",  255 },
                },
            }
        else
        --[[
            lights_up.properties[i+num] = {
                source = letters[i],
                name   = "opacity",
                keys   = {
                    {  0.0,            "LINEAR",    0 },
                    { (num+1)/(num+2), "LINEAR",    0 },
                    {  1.0,            "LINEAR",  255 },
                },
            }
            --]]
        end
        
    end
    
    lights_up = Animator(lights_up)
    
    lights_up.timeline.on_completed = lights_up_on_complete
    
    lights_up:start()
    
end

function letter_slots:light_down()
    
    local lights_down = {duration = 500,properties = {}}
    
    for i = 1, num_active do
        
        lights_down.properties[i] = {
            
            source = lights[i],
            name   = "opacity",
            keys   = {
                {  0.0, "LINEAR", 255 },
                {  1.0, "LINEAR",   0 },
            },
        }
        
        if letters[i].text == "" then
            
            lights_down.properties[i+num_active] = {
                
                source = q_marks[i],
                name   = "opacity",
                keys   = {
                    {  0.0, "LINEAR", 255 },
                    {  1.0, "LINEAR",   0 },
                },
            }
            
        else
            
            lights_down.properties[i+num_active] = {
                
                source = letters[i],
                name   = "opacity",
                keys   = {
                    {  0.0, "LINEAR", 255 },
                    {  1.0, "LINEAR",   0 },
                },
            }
            
        end
        
    end
    
    lights_down = Animator(lights_down)
    
    --need upval, else will be referencing a nil global in the on_completed
    local num = num_active
    lights_down.timeline.on_completed = function()
        for i = 1, num do
            letters[i].text  = ""
            letters[i].color = "000000"
        end
    end
    lights_down:start()
    num_active = nil
    
end

function letter_slots:get_word()
    
    local s = ""
    
    for i = 1, # letters do
        
        s = s .. letters[i].text
        
    end
    
    return s
end

function letter_slots:num_slots()       return # slots      end

function letter_slots:num_active()      return num_active   end

function letter_slots:put_letter(letter,i,red)
    
    if type(letter) ~= "string" then error("invalid letter",2) end
    if type(i) ~= "number" or i < 1 or i > # letters then error("invalid index",2) end
    
    if letters[i].text == letter then return false end
    if letters[i].text ~= "" then error("already has a letter",2) end
    
    letters[i].text         = letter
    letters[i].color        = red and "aa0000" or "000000"
    letters[i].opacity      = 0
    letters[i].anchor_point = {letters[i].w/2,letters[i].h/2}
    
    if q_marks[i].opacity == 0 then
        letters[i]:animate{
            duration = 500,
            opacity  = 255,
        }
    else
        Timeline{
            interval = 500,
            on_new_frame = function(self,ms,p)
                
                letters[i].opacity = 255*p
                q_marks[i].opacity = 255*(1-p)
                
            end
        }:start()
    end
    
    return true
end

function letter_slots:fill_in(word)
    
    if type(word) ~= "string" then error("must be of type string",2) end
    
    if word:len() ~= num_active then error("length mismatch",2) end
    
    word = string.upper(word)
    
    for i = 1, num_active do
        
        if letters[i].text == "" then
            
            self:put_letter(word:sub(i,i),i,true)
            
        end
        
    end
    
end
function letter_slots:reset()
    
    for i = 1, #slots do
        
        letters[i].opacity = 0
        letters[i].text    = ""
        lights[i].opacity  = 0
        q_marks[i].opacity = 0
        
    end
    
    num_active = nil
end

return letter_slots