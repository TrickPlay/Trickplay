local hud = {}

local has_been_initialized = false
local arrow_buff = 10
local imgs, parent

function hud:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    print("duck launcher has been initialized")
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    imgs         = t.imgs
    parent       = t.parent
    
end

function hud:start()
    
    if not has_been_initialized then error("Must initialize",2) end
    
    
    -- Exit button
    local exit_btn = Clone{
        source = imgs.options.exit,
        y = 10,
        x = 1850,
    }
    exit_btn.reactive = true
    function exit_btn:on_button_down()  exit()  end
    
    
    local score_text = Text{
        text = "Score",
        font = "Chango 24px",
        color = "f6edb0",
        x      = 30,
        y      = 980,
    }
    local score = Text{
        text = "0/0",
        font = "Chango 48px",
        color = "a78958",
        x      = 30,
        y      = 1010,
    }
    local birds_hit = 0
    local shots_fired = 0
    function hud:inc_shots_fired(amt)
        
        shots_fired = shots_fired + 1
        
        score.text = birds_hit.."/"..shots_fired
        
    end
    function hud:inc_birds_hit(amt)
        
        birds_hit = birds_hit + 1
        
        score.text = birds_hit.."/"..shots_fired
        
    end
    
    parent:add(exit_btn, score,score_text)
    
    
end

return hud