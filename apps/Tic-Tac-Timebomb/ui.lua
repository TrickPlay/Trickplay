-- 
-- The assetfactory greates and controls all the onscreen resources

ui = {}
ui.assets = {}
bg_layer 	= 3
field_layer = 4
piece_layer = 5
-- really a private function to streamline the logic
function ui.factory(name,defaults,override)
	if ui.assets[name] == nil then
		ui.assets[name] = Image(defaults)
		ui.assets[name]:hide()
		screen:add(ui.assets[name])
	end
	local the_clone = Clone{source = ui.assets[name]}
	if override ~= nil then
		the_clone:set(override)
	end
	
	return the_clone
end




function ui:createFieldLg(override)
	local defaults = {}
	defaults.src = "assets/FieldLg.png"
	defaults.z=field_layer
	return self.factory("FieldLg",defaults,override)
end

function ui:createFieldSm(override) 
	local defaults = {}
	defaults.src = "assets/FieldSm.png"
	defaults.z=field_layer
	return self.factory("FieldSm",defaults,override)
end

function ui:createPieceLgOC(override)
	local defaults = {}
	defaults.src = "assets/PieceLgOC.png"
	defaults.z=piece_layer
	return self.factory("PieceLgOC",defaults,override)
end

function ui:createPieceHalfOC(override)
	local defaults = {}
	defaults.src = "assets/PieceHalfOC.png"
	defaults.z=piece_layer
	return self.factory("PieceHalfOC",defaults,override)
end

function ui:createPieceHalfXC(override)
	local defaults = {}
	defaults.src = "assets/PieceHalfXC.png"
	defaults.z=piece_layer
	return self.factory("PieceHalfXC",defaults,override)
end

function ui:createPieceLgOG(override)
	local defaults = {}
	defaults.src = "assets/PieceLgOG.png"
	defaults.z=piece_layer
	return self.factory("PieceLgOG",defaults,override)
end

function ui:createPieceLgXC(override)
	local defaults = {}
	defaults.src = "assets/PieceLgXC.png"
	defaults.z=piece_layer
	return self.factory("PieceLgXC",defaults,override)
end

function ui:createPieceLgXG(override)
	local defaults = {}
	defaults.src = "assets/PieceLgXG.png"
	defaults.z=piece_layer
	return self.factory("PieceLgXG",defaults,override)
end

function ui:createPieceSmOC(override)
	local defaults = {}
	defaults.src = "assets/PieceSmOC.png"
	defaults.z=piece_layer
	return self.factory("PieceSmOC",defaults,override)
end

function ui:createPieceSmOG(override)
	local defaults = {}
	defaults.src = "assets/PieceSmOG.png"
	defaults.z=piece_layer
	return self.factory("PieceSmOG",defaults,override)
end


function ui:createPieceSmXC(override)
	local defaults = {}
	defaults.src = "assets/PieceSmXC.png"
	defaults.z=piece_layer
	return self.factory("PieceSmXC",defaults,override)
end

function ui:createPieceSmXG(override)
	local defaults = {}
	defaults.src = "assets/PieceSmXG.png"
	defaults.z=piece_layer
	return self.factory("PieceSmXG",defaults,override)
end

function ui:createEnterButton(override)
	local defaults = {}
	defaults.Text = "assets/EnterButton.png"
	defaults.z=piece_layer
	return self.factory("EnterButton",defaults,override)
end

function ui:createEnterButtonPress(override)
	local defaults = {}
	defaults.src = "assets/EnterButtonPress.png"
	defaults.z=piece_layer
	return self.factory("EnterButtonPress",defaults,override)
end

function ui:createTimerBack(override)
	local defaults = {}
	defaults.src = "assets/TimerBack.png"
	defaults.z=bg_layer
	return self.factory("TimerBack",defaults,override)
end

function ui:createTimerOffBlue(override)
	local defaults = {}
	defaults.src = "assets/TimerOffBlue.png"
	defaults.z=piece_layer
	return self.factory("TimerOffBlue",defaults,override)
end

function ui:createTimerOffRed(override)
	local defaults = {}
	defaults.src = "assets/TimerOffRed.png"
	defaults.z=piece_layer
	return self.factory("TimerOffRed",defaults,override)
end

function ui:createTimerOnBlue(override)
	local defaults = {}
	defaults.src = "assets/TimerOnBlue.png"
	defaults.z=piece_layer
	return self.factory("TimerOnBlue",defaults,override)
end

function ui:createTimerOnRed(override)
	local defaults = {}
	defaults.src = "assets/TimerOnRed.png"
	defaults.z=piece_layer
	return self.factory("TimerOnRed",defaults,override)
end

function ui:createTextShadow(textObject)
	local shadow = Text{
		text	= textObject.text,
		color	= "000000",
		opacity	= 255/2,
		y		= textObject.y + 2,
		x		= textObject.x,
		z		= textObject.z,
		font	= textObject.font,
		anchor_point = textObject.anchor_point
	}
	textObject.z = textObject.z + 1
	if textObject.parent ~= nil then
		textObject.parent:add(shadow)
	end
	return shadow
end

local restartButton = Image{
				src = "/assets/TimerOnBlue.png",
				opacity = 200,
				y = 988,
				x = 1803,
				scale = {.7,1.3},
				anchor_point = {0,0},
				z = 5,
				}	
local restartButton2 = Image{
				src = "/assets/TimerOffBlue.png",
				opacity = 150,
				y = 988,
				x = 1803,
				scale = {.7,1.3},
				anchor_point = {0,0},
				z = 4,
				}	
local restartText = Text{
				text = "Restart",
				opacity = 255,
				color = "ffffff",
				font = "DejaVu Sans 30px",
				x = 1693,
				y = 1010,
				z = 5,
				anchor_point = {0,0},
				}
screen:add(restartText, restartButton, restartButton2)
