ItemSelectionController = Class(Controller, function(self, view, ...)
    self._base.init(self, view, Components.ITEM_SELECTION)

    local MenuItemCallbacks = {}
    for row,row_table in ipairs(view.menu_items) do
        MenuItemCallbacks[row] = {}
        for col, col_table in ipairs(view.menu_items[row]) do
            MenuItemCallbacks[row][col] = function(self)
                print("item ",row,col," selected")
            end
        end
    end
    local num_rows = #MenuItemCallbacks
    local num_cols = #MenuItemCallbacks[1]
    
    -- the default selected index
    local selected = {row = 1,col = 1 }

    local ItemSelectionKeyTable = {
        [keys.Up]    = function(self) self:move_selector(Directions.UP) end,
        [keys.Down]  = function(self) self:move_selector(Directions.DOWN) end,
        [keys.Left]  = function(self) self:move_selector(Directions.LEFT) end,
        [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
        [keys.Return] =
        function(self)
            -- compromise so that there's not a full-on lua panic,
            -- but the error message still displays on screen
            local success, error_msg = pcall(MenuItemCallbacks[selected], self)
            if not success then print(error_msg) end
        end
    }

    function self:on_key_down(k)
        if  ItemSelectionKeyTable[k] then
            ItemSelectionKeyTable[k](self)
        end
    end

    function self:get_selected_index()
        return selected
    end

    function self:move_selector(dir)
       
        local new_selected = {row = selected.row + dir[2],
                              col = selected.col + dir[1]}
        --[[
        if 1 <= new_selected.row and new_selected.row <= num_rows then
             selected.row = new_selected.row
        end
        if 1 <= new_selected.col and new_selected.col <= num_cols then
             selected.col = new_selected.col
        end
        --]]
        if MenuItemCallbacks[new_selected.row]                   ~= nil and
           MenuItemCallbacks[new_selected.row][new_selected.col] ~= nil then
             selected.row = new_selected.row
             selected.col = new_selected.col
        end
        print("Move to",selected.row,selected.col)
        self:get_model():notify()
    end

end)
