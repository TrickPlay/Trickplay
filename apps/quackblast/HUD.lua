local hud = {}

local has_been_initialized = false

local arrow_buff = 10

local imgs, parent -- upvals to be init-ed

--------------------------------------------------------------------------------
-- links the dependencies
--------------------------------------------------------------------------------
function hud:init(t)
    
    if has_been_initialized then error("Already initialized",2) end
    
    has_been_initialized = true
    
    if type(t) ~= "table" then error("Parameter must be a table",2) end
    
    imgs   = t.imgs   or error("must have imgs",   2)
    parent = t.parent or error("must have parent", 2)
    
end

--------------------------------------------------------------------------------
-- make the object
--------------------------------------------------------------------------------
function hud:create()
    
    if not has_been_initialized then error("Must initialize",2) end
    
    ----------------------------------------------------------------------------
    -- Exit button                                                            --
    ----------------------------------------------------------------------------
    local exit_btn   = Clone{
        source       = imgs.options.exit,
        y            = 20   + imgs.options.exit.w/2,
        x            = 1840 + imgs.options.exit.h/2,
        anchor_point = {imgs.options.exit.w/2,imgs.options.exit.h/2},
        reactive     = true,
    }
    
    local exit_btn_state = AnimationState{
        duration = 200,
        transitions = {
            {
                source = "*", target = "ON",
                keys = {
                    {exit_btn, "scale", {1.5,1.5}},
                }
            },
            {
                source = "*", target = "OFF",
                keys = {
                    {exit_btn, "scale", {1,1}},
                }
            },
        }
    }
    
    
    function exit_btn:on_leave()          exit_btn_state.state = "OFF"   end
    function exit_btn:on_enter()          exit_btn_state.state = "ON"    end
    function exit_btn:on_button_down()    exit()                         end
    
    
    ----------------------------------------------------------------------------
    -- Score Text                                                             --
    ----------------------------------------------------------------------------
    local hits_text = Text{
        text = "Hits",
        font = "Chango 20px",
        color = "dcd28e",
        x      = 50,
        y      = 982,
    }
    local hits = Text{
        text = "0",
        font = "Chango 36px",
        color = "f6edb0",
        x      = 130,
        y      = 970,
    }
    local ducks_text = Text{
        text = "Ducks",
        font = "Chango 20px",
        color = "dcd28e",
        x      = 30,
        y      = 1032,
    }
    local ducks = Text{
        text = "0",
        font = "Chango 36px",
        color = "f6edb0",
        x      = 130,
        y      = 1020,
    }
    local hits_int  = 0
    local ducks_int = 0
    
    --public functions used to change the score
    function hud:ducks_launched()
        
        ducks_int = ducks_int + 1
        
        ducks.text = ducks_int
        
    end
    function hud:inc_birds_hit()
        
        hits_int = hits_int + 1
        
        hits.text = hits_int
        
    end
    
    parent:add(exit_btn,hits_text,hits, ducks_text,ducks)
    
    
end

return hud