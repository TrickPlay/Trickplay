local editor = {}
local rect_init_x = 0
local rect_init_y = 0
local g_init_x = 0
local g_init_y = 0
local next_position 

local menuButtonView 

local allUiElements     = {
							"ArrowPane", "Button", "ButtonPicker", "CheckBoxGroup","DialogBox","Image", "LayoutManager",
							"MenuButton", "ProgressBar","ProgressSpinner", "RadioButtonGroup", "Rectangle", "ScrollPane", 
							"TabBar",  "Text",  "TextInput", "ToastAlert", "Video"
						  }

local engineUiElements  = { 
							"Rectangle", "Text", "Image", "Video" 
						  }

local editorUiElements 	= {
							"Button", "TextInput", "DialogBox", "ToastAlert", "CheckBoxGroup", "RadioButtonGroup", 
							"ButtonPicker", "ProgressSpinner", "ProgressBar", "MenuButton", "TabBar", "LayoutManager", 
							"ScrollPane", "ArrowPane" 
				     	  }

local widget_f_map = 
{
     ["Rectangle"]	= function () input_mode = hdr.S_RECTANGLE screen:grab_key_focus() end, 
     ["Text"]		= function () editor.text() input_mode = hdr.S_SELECT end, 
     ["Image"]		= function () input_mode = hdr.S_SELECT editor.image() end, 	
     ["Video"] 		= function () input_mode = hdr.S_SELECT editor.video() end,
     ["Button"]     = function () return ui_element.button()       end, 
     ["TextInput"] 	= function () return ui_element.textInput()    end, 
     ["DialogBox"] 	= function () return ui_element.dialogBox()    end, 
     ["ToastAlert"] = function () return ui_element.toastAlert()     end,   
     ["RadioButtonGroup"]   = function () return ui_element.radioButtonGroup()  end, 
     ["CheckBoxGroup"]      = function () return ui_element.checkBoxGroup()     end, 
     ["ButtonPicker"]   	= function () return ui_element.buttonPicker() end, 
     ["ProgressSpinner"]    = function () return ui_element.progressSpinner()  end, 
     ["ProgressBar"]     	= function () return ui_element.progressBar()   end,
     ["MenuButton"]       	= function () return ui_element.menuButton()  end,
     ["MenuBar"]        	= function () return ui_element.menuBar()      end,
     ["LayoutManager"]      = function () return ui_element.layoutManager()   end,
     ["ScrollPane"]    		= function () return ui_element.scrollPane() end, 
     ["ArrowPane"]    		= function () return ui_element.arrowPane() end, 
	 ["TabBar"]		 		= function () return ui_element.tabBar() end, 
     ["MenuBar"]    		= function () return ui_element.menuBar() end, 

}

local widget_n_map = {
     ["Button"]    	= function () return "Button" end, 
     ["TextInput"] 	= function () return "Text Input" end, 
     ["DialogBox"] 	= function () return "Dialog Box" end, 
     ["ToastAlert"]	= function () return "Toast Alert" end,   
     ["RadioButtonGroup"]    = function () return "Radio Button Group" end, 
     ["CheckBoxGroup"]       = function () return "Checkbox Group" end, 
     ["ButtonPicker"]   	 = function () return "Button Picker" end, 
     ["ProgressSpinner"]     = function () return "Progress Spinner" end, 
     ["ProgressBar"]     	 = function () return "Progress Bar" end,
     ["MenuButton"]      	 = function () return "Menu Button" end,
     ["LayoutManager"]       = function () return "Layout Manager" end,
     ["ScrollPane"]    		 = function () return "Scroll Pane" end, 
     ["ArrowPane"]    		 = function () return "Arrow Pane" end, 
     ["TabBar"]    			 = function () return "Tab Bar" end, 
     ["MenuBar"]     		 = function () return "Menu Bar" end, 
}


function editor.rectangle(x, y)
    rect_init_x = x 
    rect_init_y = y 

    
    uiInstance = Widget_Rectangle{}
    for m,n in ipairs (screen.children) do
        if string.find(n.name, "Layer") then  
            for k,l in ipairs (n.children) do 
                if l.name == uiTypeStr:lower()..uiNum then 
                    uiNum = uiNum + 1
                end
            end
        end
    end 
    uiInstance.name = uiTypeStr:lower()..uiNum
    uiNum = uiNum + 1

--[[
	uiInstance = Rectangle{
    	name="rectangle"..tostring(item_num),
    	border_color= hdr.DEFAULT_COLOR,
    	border_width=0,
    	color= hdr.DEFAULT_COLOR,
    	size = {1,1},
    	position = {x,y,0}, 
		extra = {org_x = x, org_y = y}
    }
]]
    uiInstance.reactive = true

    return uiInstance
end 

function editor.rectangle_done(x,y)
	if ui.rect == nil then return end 
    ui.rect.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
    if(x-rect_init_x < 0) then
    	ui.rect.x = x
    end
    if(y-rect_init_y < 0) then
    	ui.rect.y = y
    end
    item_num = item_num + 1
    screen.grab_key_focus(screen)

	local timeline = screen:find_child("timeline")
	if timeline then 
	    ui.rect.extra.timeline = {}
        ui.rect.extra.timeline[0] = {}
	    local prev_point = 0
	    local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	    for l,k in pairs (attr_map["Rectangle"]()) do 
	        ui.rect.extra.timeline[0][k] = ui.rect[k]
	    end
	    if cur_focus_n ~= 0 then 
                ui.rect.extra.timeline[0]["hide"] = true  
	    end 

	    for i, j in util.orderedPairs(timeline.points) do 
	        if not ui.rect.extra.timeline[i] then 
		    	ui.rect.extra.timeline[i] = {} 
	            for l,k in pairs (attr_map["Rectangle"]()) do 
		         ui.rect.extra.timeline[i][k] = ui.rect.extra.timeline[prev_point][k] 
		    	end 
		    	prev_point = i 
			end 
	        if i < cur_focus_n  then 
            	ui.rect.extra.timeline[i]["hide"] = true  
			end 
	    end 
	end 
end 

function editor.rectangle_move(x,y)

	if ui.rect then 
        ui.rect.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
        if(x- rect_init_x < 0) then
            ui.rect.x = x
        end
        if(y- rect_init_y < 0) then
            ui.rect.y = y
        end
	end

end

return editor
