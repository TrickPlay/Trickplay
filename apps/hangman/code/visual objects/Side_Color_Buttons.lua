local self = {}

local img_srcs, make_button, make_list
function self:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    img_srcs    = t.img_srcs    or error("must pass img_srcs",    2)
    make_button = t.make_button or error("must pass make_button", 2)
    make_list   = t.make_list   or error("must pass make_list",   2)
    
end

function self:make(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    local side_bar
    
    local buttons = {}
    local text = {}
    
    for i = 1, # t.buttons do
        
        buttons[i] = make_button{
            clone           = true,
            unfocus_fades   = false,
            select_function = t.buttons[i].select,
            unfocused_image = img_srcs.button[(i-1)%3+1],
            focused_image   = img_srcs.button_f,
        }
        
        buttons[i].x = t.x
        buttons[i].y = t.y + (img_srcs.button_f.h + t.spacing)*(i-1)
        
        text[i]   = Text{
            color = "f1e6d4",
            text  = t.buttons[i].name,
            font  = g_font .. " 36px",
            x     = 0,
            y     = 15,
            w= buttons[i].w,
            alignment = "CENTER",
            wrap = true,
        }
        
        buttons[i]:add(
            Text{
                color = "000000",
                text  = t.buttons[i].name,
                font  = g_font .. " 36px",
                x     = -2,
                y     = 15-2,
                w= buttons[i].w,
                alignment = "CENTER",
                wrap = true,
            },
            text[i]
        )
        
    end
    
    side_bar = make_list{
        orientation = "VERTICAL",
        elements = buttons,
        on_focus = t.on_focus,
        display_passive_focus = false,
        resets_focus_to = t.resets_focus_to,
        resets_focus_secondary = t.resets_focus_secondary,
        ignore_override = true,
    }
    
    side_bar.buttons = buttons
    
    function side_bar:show_button(i)
        
        buttons[i]:show()
        
    end
    
    function side_bar:hide_button(i)
        
        buttons[i]:hide()
        
    end
    
    function side_bar:blacken_text(i)
        
        text[i].color = "000000"
        
    end
    
    function side_bar:whiten_text(i)
        
        text[i].color = "d1c6b4"
        
    end
    
    return side_bar
end

return self 