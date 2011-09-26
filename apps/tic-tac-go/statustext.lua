StatusText = {}
StatusText.container = Group()
StatusText.enterButtons = {}
StatusText.container.y = 728
StatusText.container.x = 0
StatusText.container.w = 720
StatusText.container.h = 120
StatusText.defaults = {}
StatusText.defaults.z = 5
StatusText.defaults.font = "DejaVu Sans 50px"
StatusText.defaults.color = "FFFFFF"
StatusText.defaults.x = 5
StatusText.defaults.y = 20

function StatusText:clear()
	return self.container:clear()
end

function StatusText:getContainer()
	return self.container
end

function StatusText:add(...)
	return self.container:add(...)
end

function StatusText:Text()
   return Text(self.defaults)
end

function StatusText:pressToMove(player_icon)
	-- adding Icon
	self:clear(pressToDrop)
    local image_defaults = {x=5,y=-8}
    local PlayIconImage = player_icon == "O" and ui:createPieceHalfOC(image_defaults)
                                             or ui:createPieceHalfXC(image_defaults)
	self:add(PlayIconImage)
-- adding text "press"
--	local textPress = StatusText:Text()
--	textPress:set{text="Press",x=120}
--	self:add(textPress)
--	ui:createTextShadow(textPress)
--
-- adding Enter Button
--	local textToEnter = StatusText:Text()
--	textToEnter:set{text="Enter", x=200}
--	self:add(textToEnter)
--	ui:createTextShadow(textToEnter)
--	
	-- adding text "to move"
	local textToMove = StatusText:Text()
	textToMove:set{text="Press enter to move",x=150}
	self:add(textToMove)
	ui:createTextShadow(textToMove)
	local c = self:getContainer()
	if c.parent ~= nil then c:unparent() end
	PlayField:add(c)
	c.opacity = 255
	
end

function StatusText:pressToDrop(player_icon)

	self:clear()

	local image_defaults = {x=5,y=-8}
    	local PlayIconImage = player_icon == "O" and
            ui:createPieceHalfOC(image_defaults) or
            ui:createPieceHalfXC(image_defaults)
		self:add(PlayIconImage)
	-- adding text "press"
	local textPress = StatusText:Text()
	textPress:set{text="Press enter to drop",x=150}
	self:add(textPress)
	ui:createTextShadow(textPress)
	
end

function StatusText:addEnterButton(position)
	if self.enterButtons.normal == nil or self.enterButtons.normal.parent == nil then
		self.enterButtons.normal = ui:createEnterButton{position=position}
		self.enterButtons.normal:show()
		self.enterButtons.normal.z = 9
		self.enterButtons.pressed = ui:createEnterButtonPress{position=position}
		self.enterButtons.pressed.z = 10
		self.enterButtons.pressed.opacity = 0
		PlayField:add( self.enterButtons.normal , self.enterButtons.pressed )
	else
		self.enterButtons.normal.position = position
		self.enterButtons.pressed.position = position
	end
end

function StatusText:EnterButtonPressed()

	if self.enterButtons.pressed ~= nil then
		self.enterButtons.pressed.opacity = 255
		self.enterButtons.pressed:animate{ duration=400,opacity=0 }
	end
end
