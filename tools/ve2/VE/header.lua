local hdr = {}

WL = dofile("LIB/Widget/Widget_Library.lua")

VL = dofile("LIB/VE/ve_runtime")

hdr.test = 0
----------------
-- Constants 
----------------
-- Screen states 
hdr.S_SELECT          = 0
hdr.S_RECTANGLE       = 1
hdr.S_POPUP        	  = 2
hdr.S_MENU        	  = 3
hdr.S_FOCUS        	  = 4
hdr.S_MENU_M	  	  = 5

-- Mouse state 
hdr.BUTTON_UP         = 0
hdr.BUTTON_DOWN       = 1

-- Undo/Redo action items  
hdr.ADD               = 1
hdr.CHG               = 2
hdr.DEL               = 3
hdr.ARG		 	      = 4

hdr.BRING_FR	      = 5
hdr.SEND_BK		      = 6
hdr.BRING_FW	      = 7
hdr.SEND_BW		      = 8

-- Style constants
hdr.DEFAULT_COLOR     = {255,255,255,255}

hdr.uiElements = {"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", 
                  "ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", "ScrollPane", "ArrowPane" }

hdr.uiContainers = {"DialogBox", "LayoutManager", "ScrollPane", "Widget_Group", "ArrowPane", "TabBar", "MenuButton"} 

-------------------------------
-- UI Element Creation Function Map 
-------------------------------

hdr.uiElementCreate_map = 
    {
        ['Clone'] = function(p) local obj = WL.Widget_Clone(p) if p.source then obj.source = screen:find_child(p.source) end return obj end, 
        ['Widget_Clone'] = function(p) local obj = WL.Widget_Clone(p) if p.source then obj.source = screen:find_child(p.source) end return obj end, 
        ['Group'] = function(p)  return WL.Widget_Group(p) end, 
        ['Widget_Group'] = function(p)  return WL.Widget_Group(p) end, 
        ['Rectangle'] = function(p)  return WL.Widget_Rectangle(p) end, 
        ['Widget_Rectangle'] = function(p)  return WL.Widget_Rectangle(p) end, 
        ['Text'] = function(p)  return WL.Widget_Text(p) end, 
        ['Widget_Text'] = function(p)  return WL.Widget_Text(p) end, 
        ['Image'] = function(p)  return WL.Widget_Sprite(p) end, 
        ['Widget_Sprite'] = function(p)  return WL.Widget_Sprite(p) end, 
    
        ['Button'] = function(p)  return WL.Button(p) end, 
        ['DialogBox'] = function(p) return WL.DialogBox(p) end,
        ['ToastAlert'] = function(p) return WL.ToastAlert(p) end,
        ['ProgressSpinner'] = function(p) return WL.ProgressSpinner(p) end,
        ['ProgressBar'] = function(p) return WL.ProgressBar(p) end,
        ['OrbittingDots'] = function(p) return WL.OrbittingDots(p) end,
        ['TextInput'] = function(p) return WL.TextInput(p) end,
        ['RadioButton'] = function(p) return WL.RadioButton(p) end,
        ['CheckBox'] = function(p) return WL.CheckBox(p) end,
        ['LayoutManager'] = function(p)  return WL.LayoutManager(p) end, 
        ['Slider'] = function(p)  return WL.Slider(p) end, 
        ['ArrowPane'] = function(p)  return WL.ArrowPane(p) end, 
        ['ScrollPane'] = function(p)  return WL.ScrollPane(p) end, 
        ['TabBar'] = function(p)  return WL.TabBar(p) end, 
        ['ButtonPicker'] = function(p)  return WL.ButtonPicker(p) end, 
        ['MenuButton'] = function(p)  return WL.MenuButton(p) end, 
    }

hdr.uiNum_map = 
    {
        ['Clone'] = 0,
        ['Widget_Clone'] = 0,
        ['Group'] = 0,
        ['Widget_Group'] = 0,
        ['Rectangle'] = 0,
        ['Widget_Rectangle'] = 0,
        ['Text'] = 0,
        ['Widget_Text'] = 0,
        ['Image'] = 0,
        ['Widget_Sprite'] = 0,
    
        ['Button'] = 0,
        ['DialogBox'] =0, 
        ['ToastAlert'] = 0,
        ['ProgressSpinner'] = 0,
        ['ProgressBar'] = 0,
        ['OrbittingDots'] = 0,
        ['TextInput'] = 0,
        ['RadioButton'] = 0,
        ['CheckBox'] = 0,
        ['LayoutManager'] = 0,
        ['Slider'] = 0,
        ['ArrowPane'] = 0,
        ['ScrollPane'] = 0,
        ['TabBar'] = 0,
        ['ButtonPicker'] = 0,
        ['MenuButton'] = 0,
    }

hdr.neighberKey_map = 
    {
        [ keys.Return ] = function(selObj, focObj) selObj.neighbors.Return = focObj end ,
        [ keys.Left  ] = function(selObj, focObj) selObj.neighbors.Left = focObj end ,
        [ keys.Right ] = function(selObj, focObj) selObj.neighbors.Right = focObj end ,
        [ keys.Down  ] = function(selObj, focObj) selObj.neighbors.Down = focObj end,
        [ keys.Up    ] = function(selObj, focObj) selObj.neighbors.Up = focObj end,
    }

---------------------
-- Global Variables
---------------------
editor_lb = editor
buildInsp = false

current_dir 	   = ""
debugger_script = "trickplay-debugger"
current_focus 	   = nil
selected_container = nil
selected_content   = nil

input_mode         = hdr.S_SELECT

focusKey = nil

mouse_state       = hdr.BUTTON_UP

-- UI Element / Layer Naming Number 
uiNum = 0
layerNum = 0

-- current Layer 
curLayer= nil

-- block report flag 
blockReport= false

--guideline_show	  = true
snapToGuide	      = true

-- index for new guideline
h_guideline       = 0
v_guideline       = 0

-- for the modifier keys 
shift 		      = false
control 	      = false

-- table for ui elements selcection 
selected_objs	  = {}

-- guide line  
guideline_inspector_on = false
selected_guideline = nil

-- The asset cache
assets = dofile( "assets-cache" )


util = dofile("util")
ui = {
      assets  = assets,
      factory = dofile( "ui-factory" ),
    } 
editor = dofile("editor")
screen_ui = dofile("screen_ui")

function dump_properties( o )
        local t = {}
        local l = 0
        for k , v in pairs( getmetatable( o ).__getters__ ) do
            local s = v( o )
            if type( s ) == "table" then
                s = serialize( s )
            elseif type( s ) == "string" then
                s = string.format( "%q" , s )
            else
                s = tostring( s )
            end
            table.insert( t , { k , s } )
            l = math.max( l , # k )
        end
        table.sort( t , function( a , b ) return a[1] < b[1] end )
        for i = 1 , # t do
            print( string.format( "%-"..tostring(l+1).."s = %s" , t[i][1] , t[i][2] ) )
        end
end

return hdr

