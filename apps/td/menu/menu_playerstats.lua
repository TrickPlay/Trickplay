--menu_playerstats

-- Load the first player
function Menu:load_first_player()

	self.player_data[1].opacity = 255
	self.y = 1
	self:update_cursor_position()
	self.photo.src=self.info[self.y]["url"]
	self.clone.source=self.photo
	
	self.photo.on_loaded = function() self.clone.opacity = 255 end --Photo is hidden until loaded
	
	self.temp = {} -- Store photo urls here... probably should've called this something better
	for i =1, #self.info do self.temp[i] = self.info[i]["url"] end
	
	if not self.photo.extra.x then self.photo.extra.x = self.photo.x end
	if not self.photo.extra.y then self.photo.extra.y = self.photo.y end
	if not self.photo.extra.src then self.photo.extra.src = {} end
	
	if self.starting_y then self.container.y = self.starting_y
	else self.starting_y = self.container.y
	end

end

-- Hide the players... but this doesn't do anything really
function Menu:hide_player()

	self.player_data[self.y].opacity = 0
	self.clone.opacity = 0

end

-- Apply button scroll on top of the keypresses
function Menu:apply_button_scroll()

	local temp_down = self.buttons.extra.down 
	self.buttons.extra.down = function()	
		if self.y < self.max_y then
			self.player_data[self.y].opacity = 0
			temp_down() -- Call the old function
			if self.y > 3 and self.max_y - self.y > 2 then self.container.y=self.container.y-36-self.list[1][1].h end
			self:update_cursor_position() -- Update cursor
			self.clone.source = self.load:getNextPhoto() -- Get next photo from the loader
			self.clone.opacity = 255
			self.player_data[self.y].opacity = 255
		end
	end
	
	local temp_up = self.buttons.extra.up
	self.buttons.extra.up = function()
		if self.y > 1 then
			self.player_data[self.y].opacity = 0
			temp_up() -- Call the old function
			if self.y > 2 and self.max_y - self.y > 3 then self.container.y=self.container.y+36+self.list[1][1].h end
			self:update_cursor_position() -- Update cursor
			self.clone.source = self.load:getPrevPhoto() -- Get next photo from the loader
			self.clone.opacity = 255
			self.player_data[self.y].opacity = 255
		end
	end

end
