BoardViewConstants = {
    focus_src  = "img/grid_button_bluefocus.png",
    top_src    = "img/topstatus/top_bg.png",
    win_status_src = "img/topstatus/top_left_winstatus.png",

-- clock settings
    clock_tick_src = "img/topstatus/timer/empty_timer.png",  
    clock_tock_src = "img/topstatus/timer/full_timer.png",  
    clock_num_ticks = 10   
}


WinStatus = class(function(self, parent_group)
    self.group = Group()
    self.bg = Images:load(BoardViewConstants.win_status_src)
    self.group:add(self.bg)

    parent_group:add(self.group)
end)

Clock = class(function(self, parent_group)
    self.ticks = {}
    self.tick_img = Images:load(BoardViewConstants.clock_tick_src)
    
    self.tocks = {}
    self.tock_img = Images:load(BoardViewConstants.clock_tock_src)

    --self.num_ticks = math.floor(parent_group.width/self.tock.width)
    self.num_ticks = BoardViewConstants.clock_num_ticks

    for i=1,self.num_ticks do

        local image_property = {
            x = (i-1) * self.tock_img.width
        }

        self.ticks[i] = Images:load(BoardViewConstants.clock_tick_src, image_property)
        
        image_property.z = 2
        self.tocks[i] = Images:load(BoardViewConstants.clock_tock_src, image_property)

        self.tocks[i]:hide()

        parent_group:add(self.ticks[i])
        parent_group:add(self.tocks[i])
    end

    self.tock_count = 0
end)

function Clock:tock()
    self.tock_count = self.tock_count + 1
    self.tocks[self.tock_count]:show()
end

function Clock:clear()
    self.tock_count = 0
    for i,v in ipairs(self.tocks) do
        v:hide()
    end
end

function Clock:start(duration)
    local timer = Timer()
    timer.interval = duration/(self.num_ticks+1)
    local clock = self
    timer.on_timer = function(timer)
        if self.tock_count == self.num_ticks then
            timer:stop()
            clock:clear()
        else
            clock:tock()
        end
    end
    timer:start()
end

BoardLayer = class(function(self, table_properties, child_properties)
    self.child_properties = child_properties 
    self.table_properties = table_properties
    self.group = Group()
    Utils.mixin(self.group, table_properties)
end)

--[=[
    Generic insertion of an image on or above a key on to the board at `row`,
    `col` with `properties`
--]=]

function BoardLayer:calculateXY(src, row, col, properties)
    properties = Utils.mixin({}, properties)
    properties = Utils.mixin(properties, self.child_properties)
    local image = Images:load(src, properties)
    local x = col * (image.width + 4)
    local y = row * (image.height + 4)
    return x, y, image 
end

function BoardLayer:insert(src, row, col, properties)
    local x,y,image = self:calculateXY(src, row, col, properties)
    image.x = x
    image.y = y
    self.group:add(image)
    return image
end

SelectLayer = class(BoardLayer, function(self, ...)
    self._base.init(self, ...) -- call base class constructor
    self._select_src = "img/grid_button_bluefocus_80.png"
end)

function SelectLayer:make_selection(cord_table, ...)
    assert(cord_table, "passing nil to cord_table")

    for i,v in ipairs(cord_table) do
        self:insert(self._select_src, v[1], v[2], ...)
    end
    
end

BoardView = class(function(self)
    local button_src = "img/grid_button.png"
    local bg_src = "img/game_bg.png"

    local key_src = {}
    key_src.top    = "img/incomming/grid_coming_top.png"
    key_src.right  = "img/incomming/grid_coming_right.png"
    key_src.bottom = "img/incomming/grid_coming_bottom.png"
    key_src.left   = "img/incomming/grid_coming_left.png"

    local bg = Images:load(bg_src)

    self.rows = BarneyConstants.rows
    self.cols = BarneyConstants.cols

    self.board = Group()

    self.board.height = BarneyConstants.board_height
    self.board.width  = BarneyConstants.board_width

    -- add top status bar (timer/score)
    
    self.top_board = Group()
    self.top_board.z = 1
    local top_tray = Images:load(BoardViewConstants.top_src)
    -- center the top tray
    self.top_board.x = (self.board.width - top_tray.width) / 2
    self.top_board:add(top_tray)

    self.win_status = WinStatus(self.top_board)

    self.clock_group = Group()
    self.clock_group.width = self.top_board.width - self.win_status.group.width
    self.clock_group.x = self.win_status.group.width

    self.clock = Clock(self.clock_group)
    self.clock_group.y = 30

    self.top_board:add(self.clock_group)
    self.board:add(self.top_board)

    -- add skew board

    self.skew_board = Group()
    self.skew_board.z = 1

    self.skew_board.height = BarneyConstants.board_height
    self.skew_board.width  = BarneyConstants.board_width

    self.skew_board.x_rotation = {15, 0, 0}
    self.skew_board.x = 130
    self.skew_board.y = self.top_board.height - 70

    self.skew_layers = {} 

    -- add background keyboard
    self.skew_layers.key_layer     = BoardLayer( {z=1})
    -- add hints to player for next effect
    self.skew_layers.pre_key_layer = BoardLayer( {z=1} )

    local pre_key_layers = {}
    pre_key_layers.top    = BoardLayer()
    pre_key_layers.right  = BoardLayer()
    pre_key_layers.bottom = BoardLayer()
    pre_key_layers.left   = BoardLayer()

    for k,v in pairs(pre_key_layers) do
        self.skew_layers.pre_key_layer.group:add(v.group)
    end

    -- add dynamic layers
    self.skew_layers.effect_layer = BoardLayer( {z=2})
    self.skew_layers.select_layer = SelectLayer({z=3})
    self.skew_layers.focus_layer  = BoardLayer( {z=4})
    self.skew_layers.player_layer = BoardLayer( {z=5})

    -- add all the layers attached to the skew board
    for k,v in pairs(self.skew_layers) do
        self.skew_board:add(v.group)
    end

    -- add pre_keys
    for i=1,self.cols do
        pre_key_layers.top:insert(key_src.top, 0, i)
        pre_key_layers.bottom:insert(key_src.bottom, self.rows+1, i)
    end

    for i=1,self.rows do
        pre_key_layers.left:insert(key_src.left, i, 0)
        pre_key_layers.right:insert(key_src.right, i, self.cols+1)
    end
    
    -- add the keys
    for i=1,self.rows do
        for j=1,self.cols do
            self.skew_layers.key_layer:insert(button_src, i, j)
        end
    end

    self.board:add(self.skew_board)
    self.board:add(bg)

    -- add player health on bottom
    self.bottom_board = Group()
    self.bottom_board.z = 1

    self.player_view = {}
    for i=1,BarneyConstants.players do
        self.player_view[i] = PlayerView(i, self.skew_layers.player_layer, self.bottom_board)
    end
    
    -- center bottom board
    self.bottom_board.y =  BarneyConstants.board_height - self.bottom_board.height
    self.bottom_board.x = (BarneyConstants.board_width - self.bottom_board.width)/2
    self.board:add(self.bottom_board)

    screen:add(self.board)
    screen:show()
end)

function BoardView:update_board(old_board, new_row)

    self.skew_layers.effect_layer.group:clear()

    -- add first row
    for i,v in ipairs(new_row) do
        if v ~= 0 then 
            self.skew_layers.effect_layer:insert(v.imageSrc, 1, i)
        end
    end

    -- add subsequent rows
    for i=1,BarneyConstants.rows-1 do
        for j=1,BarneyConstants.cols do
            local effect = old_board:getEffectAt(i, j)
            if 0 ~= effect then
                self.skew_layers.effect_layer:insert(effect.imageSrc, i+1, j)
            end
        end
    end
end

--[=[
    Display a grid with center row `r`, column `c` and radius `range` for
    possible future moves
--]=]
function BoardView:make_selection(r, c, range)
    assert(r, "no rows in BoardView:make_selection")
    assert(c, "no cols in BoardView:make_selection")
    assert(range > 0, "invalid range to BoardView:make_selection")

    self.skew_layers.focus_layer:insert(BoardViewConstants.focus_src, r, c)

    local valid_positions = {}
    for i=r-range,r+range do
        for j=c-range,c+range do
            if  i >= 1 and i <= BarneyConstants.rows 
            and j >= 1 and j <= BarneyConstants.cols then
                valid_positions[#valid_positions+1] = {i, j}
            end
        end
    end
    self.skew_layers.select_layer:make_selection(valid_positions)
end

--[=[
    Clear the board of the selection for the future move
--]=]
function BoardView:clear_selection()
    self.skew_layers.select_layer.group:clear()
    self.skew_layers.focus_layer.group:clear()
end

--[=[
    Mark a grid in the list of available grids displayed from
    `BoardView:make_selection` to be the players next selection
--]=]
function BoardView:set_focus(r, c)
    -- clear previous marker and elect new
    self.skew_layers.focus_layer.group:clear()
    self.skew_layers.focus_layer:insert(BoardViewConstants.focus_src, r, c)
end

function BoardView:setPlayerHealth(player, health)
    return self.player_view[player]:setHealth(health)
end

function BoardView:movePlayer(player, old_row, old_col, new_row, new_col)
    return self.player_view[player]:movePlayer(old_row, old_col, new_row, new_col)
end

function BoardView:startClock(duration)
    self.clock:start(duration)
end

function BoardView:draw()
    screen:show()
end

function BoardView:clear()
    screen:remove(self.board)   
end
