SelectLayerConstants = {
    focus_src = "img/focus/selector_roboy.png"
}

SelectLayer = class(GridLayer, function(self, ...)

    -- call base class constructor
    GridLayer.init(self, BoardLayerConstants.duration,
                         BoardLayerConstants.grid_width, 
                         BoardLayerConstants.grid_height,
                         BarneyConstants.rows, 
                         BarneyConstants.cols, ...) 

    self._class_name = "SelectLayer"
	self.image_src =  SelectLayerConstants.focus_src
	self.prev_row, self.prev_col = nil, nil
    self.image = nil
end)

function SelectLayer:selectPosition(row, col)
	local prev_row, prev_col = self.prev_row, self.prev_col
	assert((not prev_row and not prev_col) or (prev_row or prev_col), 
           "setting previous row, col wrong in SelectLayer")
	if not self.prev_row then
		self:insert(self.image_src, row, col)
	else
		self:animate({
			duration = 35,
		}, prev_row, prev_col, row, col)
	end
	self.prev_row, self.prev_col = row, col
end

function SelectLayer:clearSelection()
    --assert(self.prev_row and self.prev_col, 
    --       self._class_name ..":clearSelection - expects a previous row and col to exist")
    if self.prev_row and self.prev_col then
        self:remove(self.prev_row, self.prev_col)
	    self.prev_row, self.prev_col = nil, nil
    end
end
