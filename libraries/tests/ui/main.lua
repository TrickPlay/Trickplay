WL = dofile("Widget_Library.lua")

controllers:start_pointer()
screen:show() 

---[===[ UI test system

style = WL.Style{
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    text = {
        font = "Sans 50px",
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    fill_colors    = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155}
    }
}

images_src = {
    default = "Button/button3.png",
    focus   = "Button/button-focus.png"
}

images = {
    default = Image{src="Button/button3.png"},
    focus   = Image{src="Button/button-focus.png"}
}
---[==[
---[[
local shopManager = WL.ArrowPane{x = 60, y = 60, w = 1800 - 120, h = 910 - 120}
shopManager:add(
    WL.LayoutManager{number_of_rows = 1, number_of_cols = 1, cells = {
        {WL.Widget_Rectangle{w = 200, h = 200, color = "ffff00"}},
    }},
    WL.LayoutManager{x = 100, y = 100, number_of_rows = 1, number_of_cols = 1, cells = {
        {WL.Widget_Rectangle{w = 200, h = 200, color = "00ffff"}},
    }},
    WL.LayoutManager{x = 200, y = 200, number_of_rows = 1, number_of_cols = 1, cells = {
        {WL.Widget_Rectangle{w = 200, h = 200, color = "ff00ff"}}
}})
--]]

local group = WL.Widget_Group{name = "group"}
screen:add(group) --Widget_Rectangle{x = 60, y = 60, w = 1800, h = 910, color="00ff00"}, 

---[=[
price = WL.Widget_Text{x = 550, y = 160, alignment = "CENTER", width = 350, font = "Sans 60px", color = "FFFFFF", text = "$5,000"}
pb = WL.ProgressBar{x = 595, y = 280, w = 300, h = 50}
ps = WL.ProgressSpinner{x = 680, y = 140, animating = true, image = "ProgressSpinner/load-sun-spin.png", duration = 2000}
ps:hide()
pt = WL.Widget_Text{x = 630, y = 290, w = 240, alignment = "CENTER", text = "", font = "Sans 24px", color = "ffffff"}
st = WL.Widget_Text{x = 610, y = 350, text = "NOW YOU HAVE SHOES", font = "Sans 24px", color = "ffffff"}
st:hide()
loadingTimer = Timer{
    on_timer = function(self)
        self:stop()
        ps:hide()
        pt.text = "Installed"
        st:show()
    end
}
loadingTimer.interval = 2000

loadingAnim = Timeline{
    duration = 8000,
    on_started = function(self)
        pt.text = "Torrenting ... 0%"
        ps:hide()
    end,
    on_new_frame = function(self,ms,t)
        pb.progress = t
        pt.text = "Torrenting ... " .. math.floor(t * 100) .. "%"
    end,
    on_completed = function(self)
        pb.progress = 1
        pt.text = "Installing ..."
        price:hide()
        ps:show()
        loadingTimer:start()
    end
}

dialog = WL.DialogBox{x = 700-60, y = 150-120, title = "Sadly, you have no money.", image = "DialogBox/panel.png", children = {
    WL.Widget_Text{x = 345, y = 60, alignment = "CENTER", width = 200, font = "Sans 160px", color = "FFFFFF", text = ":("},
    WL.Button{x = 350, y = 300, label = "Close", on_pressed = function() dialog:hide() end, reactive = true}
}}
dialog:hide()

image = WL.DialogBox{name = "THIS", x = 500-60, y = 450-120, title = "Buy some shoes.", image = "DialogBox/panel.png", children = {
    WL.ScrollPane{x = 5, y = 5, pane_w = 500, pane_h = 300, virtual_x = 650, virtual_y = 320, virtual_w = 1200, virtual_h = 960, children = {
        Image{src = "shoes.jpg"}
    }},
    pb, ps, pt, st, price,
    WL.Widget_Text{x = 560, y = 40, alignment = "CENTER", width = 350, font = "Sans 30px", color = "FFFFFF", text = "Men's Manly Moccasins In Maroon"},
    WL.Button{x = 100, y = 400, label = "Close", on_pressed = function() image:hide() end, reactive = true},
    WL.Button{x = 350, y = 400, label = "Buy", on_pressed = function() dialog:show() end, reactive = true},
    WL.Button{x = 600, y = 400, label = "Pirate", on_pressed = function() loadingAnim:start() end, reactive = true}
}}
image:hide()

eula = WL.DialogBox{x = 500-60, y = 450-120, title = "Read this or die.", image = "DialogBox/panel.png", children = {
    WL.ScrollPane{x = 5, y = 5, pane_w = 850, pane_h = 370, virtual_w = 850, virtual_h = 1000, children = {
        WL.Widget_Rectangle{w = 850, h = 900, color="ffffff"},
        WL.Widget_Text{width = 850, font = "Sans 16px", text = [[END-USER LICENSE AGREEMENT FOR {INSERT PRODUCT NAME} IMPORTANT PLEASE READ THE TERMS AND CONDITIONS OF THIS LICENSE AGREEMENT CAREFULLY BEFORE CONTINUING WITH THIS PROGRAM INSTALL: {INSERT COMPANY NAME's } End-User License Agreement ("EULA") is a legal agreement between you (either an individual or a single entity) and {INSERT COMPANY NAME}. for the {INSERT COMPANY NAME} software product(s) identified above which may include associated software components, media, printed materials, and "online" or electronic documentation ("SOFTWARE PRODUCT"). By installing, copying, or otherwise using the SOFTWARE PRODUCT, you agree to be bound by the terms of this EULA. This license agreement represents the entire agreement concerning the program between you and {INSERT COMPANY NAME}, (referred to as "licenser"), and it supersedes any prior proposal, representation, or understanding between the parties. If you do not agree to the terms of this EULA, do not install or use the SOFTWARE PRODUCT.

The SOFTWARE PRODUCT is protected by copyright laws and international copyright treaties, as well as other intellectual property laws and treaties. The SOFTWARE PRODUCT is licensed, not sold.

1. GRANT OF LICENSE. 
The SOFTWARE PRODUCT is licensed as follows: 
(a) Installation and Use.
{INSERT COMPANY NAME} grants you the right to install and use copies of the SOFTWARE PRODUCT on your computer running a validly licensed copy of the operating system for which the SOFTWARE PRODUCT was designed [e.g., Windows 95, Windows NT, Windows 98, Windows 2000, Windows 2003, Windows XP, Windows ME, Windows Vista].
(b) Backup Copies.
You may also make copies of the SOFTWARE PRODUCT as may be necessary for backup and archival purposes.

2. DESCRIPTION OF OTHER RIGHTS AND LIMITATIONS.
(a) Maintenance of Copyright Notices.
You must not remove or alter any copyright notices on any and all copies of the SOFTWARE PRODUCT.
(b) Distribution.
You may not distribute registered copies of the SOFTWARE PRODUCT to third parties. Evaluation versions available for download from {INSERT COMPANY NAME}'s websites may be freely distributed.
(c) Prohibition on Reverse Engineering, Decompilation, and Disassembly.
You may not reverse engineer, decompile, or disassemble the SOFTWARE PRODUCT, except and only to the extent that such activity is expressly permitted by applicable law notwithstanding this limitation. 
(d) Rental.
You may not rent, lease, or lend the SOFTWARE PRODUCT.
(e) Support Services.
{INSERT COMPANY NAME} may provide you with support services related to the SOFTWARE PRODUCT ("Support Services"). Any supplemental software code provided to you as part of the Support Services shall be considered part of the SOFTWARE PRODUCT and subject to the terms and conditions of this EULA. 
(f) Compliance with Applicable Laws.
You must comply with all applicable laws regarding use of the SOFTWARE PRODUCT.]]},
    }},
    WL.Button{x = 670, y = 400, label = "Accept", on_pressed = function() eula:hide() end, reactive = true}
}}
eula:hide()
--]=]
---[=[
menuButtonGroup = WL.MenuButton{
    x = 500,
    y = 60,
    direction = "down",
    reactive = true,
    items = {
        ---[[
        WL.MenuButton {
            direction = "right",
            items = {
                WL.Button{label = "Download", on_pressed = function() loadingAnim:start() end},
                WL.Button()
            }
        },
        --]]
        ---[[
        WL.MenuButton {
            direction = "right",
            items = {
                WL.Button{on_pressed = function() eula:show() end},
                WL.Button{on_pressed = function() dialog:show() end},
                WL.Button{on_pressed = function() image:show() end}
            }
        }
        --]]
    }
}
--]=]

local tabbar = WL.TabBar {
    position = {60,60},
    pane_w = 1800,
    pane_h = 910,
    tab_w = 400,
    tabs = {
        {label = "Scriptability", contents = WL.Widget_Group{ children = {
            WL.Widget_Rectangle{w = 1800, h = 910, color="ff0000"},
            WL.Button{x = 60, y = 60, w = 400, label = "Read EULA", on_pressed = function() eula:show() end, reactive = true},
            WL.Button{x = 60, y = 160, w = 400, label = "Buy Shoes", on_pressed = function() image:show() end, reactive = true},
            eula, image, dialog,
             ---[==[
             WL.TabBar {
                position = {60,250},
                pane_w = 1800 - 320,
                pane_h = 910 - 250 - 60,
                tab_location = "left",
                tabs = {
                    ---[=[
                    {label = "Stuff", contents = WL.Widget_Group()},
                    {label = "Buttons", contents = WL.Widget_Group{ children = {
                        WL.Widget_Rectangle{w = 1800 - 320, h = 910 - 250 - 60, color="ffff00"},
                        --Button{},
                        --[[WL.MenuButton{
                            style = style,
                            x = 100,
                            y = 60,
                            direction = "down",
                            items = {
                                WL.Button{style = style, images = {default = images.default, focus = images.focus}}, Button{style = style}
                            }
                        },--]]
                        menuButtonGroup,
                        --pb, ps, pt
                        ---[[
                        --]]
                    }}},--]=]
                }
            }--]==]
        }}},
        {label = "Form Elements", contents = WL.Widget_Group{ children = {---[[
            WL.Widget_Rectangle{w = 1800, h = 910, color="0000ff"},
            WL.ScrollPane{x = 100, y = 400, pane_w = 800, pane_h = 300, children = {
                WL.TextInput{x = 200, y = 100, w = 400, text = "Enter Text Here"}, -- placeholder text?
                WL.ToggleButton{label = "Checkbox 1", x = 100, y = 200, reactive = true},
                WL.ToggleButton{label = "Checkbox 2", x = 500, y = 200, reactive = true},
                WL.ToggleButton{label = "Checkbox w/ wide text", x = 800, y = 200, reactive = true},
                WL.ToggleButton{label = "Option 1", x = 100, y = 300, group = "Radio", reactive = true},
                WL.ToggleButton{label = "Option 2", x = 500, y = 300, group = "Radio", reactive = true},
                WL.ToggleButton{label = "Option 3", x = 800, y = 300, group = "Radio", reactive = true},
            }}--]]
        }}},
        {label = "Shop Online", contents = WL.Widget_Group{ children = {
            WL.Widget_Rectangle{w = 1800, h = 910, color="888888"},
            shopManager
        }}}
    }
}
--]==]
--[[
dolater(function()
    tabbar:grab_key_focus()
end)
--]]
group:add(tabbar)


--]===]


---[==[
local color_scheme_uri = 'app/color_schemes.json'
local style_uri        = 'app/styles.json'
local layer_dir        = 'app/'

--------------------------------------------------------------------------------

local styles

function load_styles(str)
    
    if type(styles) == "table" then
        
        print("WARNING. Styles table already exists")
        
    end
    
    if type(str) ~= "string" then
        
        error("Expected string. Received "..type(str),2)
        
    end
    
    styles = json:parse(str)
    
    if type(styles) ~= "table" then
        
        error("String is not valid json",2)
        
    end
    
    for name,attributes in pairs(styles) do
        
        styles[name] = WL.Style(name):set(attributes)
        
    end
    
    return styles
    
end

--------------------------------------------------------------------------------

function load_layer(str)
    
    --load_styles should be called before load_layer
    if type(styles) ~= "table" then
        
        print("WARNING. Styles table is empty")
        
    end
    
    --load_layer expects to receive a json string
    if type(str) ~= "string" then
        
        error("Expected string. Received "..type(str),2)
        
    end
    
    --parse the json
    local layer = json:parse(str)
    
    --load_layer expects valid json
    if type(layer) ~= "table" then
        
        error("String is not valid json",2)
        
    end
    
    --the setter for Widget_Group.children calls the appropriate 
    --constructors when it receives an attributes table as an entry
    return WL.Widget_Group(layer)
    
end


--------------------------------------------------------------------------------


--style_json = get_all_styles()
--print(style_json)
--[==[
layer_json = wg:to_json()
print(layer_json)
screen:clear()

collectgarbage("collect")
load_styles(style_json)

screen:add(load_layer(layer_json))
--]==]
