StatusText = {}
StatusText.container = Group()
StatusText.enterButtons = {}
StatusText.container.y = 740
StatusText.container.x = 125
StatusText.defaults = {}
StatusText.defaults.z = 5
StatusText.defaults.font = "Sans 56px"
StatusText.defaults.color = "FFFFFF"
StatusText.defaults.x = 10
StatusText.defaults.y = 10

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

function StatusText:setIcon(player)

    assert(player == "X" or player == "O")

    local image_defaults = {scale={.55, .55}}
    if not self.x_icon then 
        self.x_icon = ui:createPieceLgXC(image_defaults)
    elseif not self.y_icon then
        self.o_icon = ui:createPieceLgOC(image_defaults)
    end
    
    local icon = player == "O" and self.o_icon or self.x_icon
    self:add(icon)
end

function StatusText:setText(new_text)
    if not self.text then
        self.text = StatusText:Text()
    end
    self.text:set{text=new_text}
    ui:createTextShadow(self.text)
    self:add(self.text)
end

function StatusText:pressToMove(player_icon)
	print("Getting " .. player_icon)
	self:clear()

    self:setIcon(player_icon)
    self:setText("Press to move")

	self:addEnterButton{140,0}
	PlayField:add(self:getContainer())
end

function StatusText:pressToDrop()
	self:clear()
    self:setText("Press to drop")
end

function StatusText:addEnterButton(position)
	self.enterButtons.normal = ui:createEnterButton{position=position}
	self.enterButtons.normal:show()
	self.enterButtons.normal.z = 9
	self.enterButtons.pressed = ui:createEnterButtonPress{position=position}
	self.enterButtons.pressed.z = 10
	self.enterButtons.pressed.opacity = 0
	self:add( self.enterButtons.normal , self.enterButtons.pressed )
end

function StatusText:EnterButtonPressed()
	if self.enterButtons.pressed ~= nil then
		self.enterButtons.pressed.opacity = 255
		self.enterButtons.pressed:animate{ duration=400,opacity=0 }
	end
end
