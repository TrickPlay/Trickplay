CharacterSelectionController = Class(Controller,function(self, view, ...)
   self._base.init(self, view, Components.CHARACTER_SELECTION)

   local controller = self
   model = view:get_model()

   local CharacterSelectionGroups = {
      TOP = 1,
      BOTTOM = 2,
   }
   local SubGroups = {
      LEFT = 1,
      LEFT_MIDDLE = 2,
      MIDDLE = 3,
      RIGHT_MIDDLE = 4,
      RIGHT = 5,
   }

   local HELP = SubGroups.LEFT_MIDDLE
   local START = SubGroups.MIDDLE
   local EXIT = SubGroups.RIGHT_MIDDLE

   local GroupSize = 0
   for k, v in pairs(CharacterSelectionGroups) do
      GroupSize = GroupSize + 1
   end
   local SubSize = 0
   for k,v in pairs(SubGroups) do
      SubSize = SubSize + 1
   end

   -- the default selected index
   local selected = CharacterSelectionGroups.BOTTOM
   local subselection = SubGroups.LEFT
   assert(selected)
   assert(subselection)
   --the number of the current player selecting a seat
   self.playerCounter = 0

   local function start_a_game()
      -- add table text
      --local table_text = AssetLoader:getImage("TableText",{name="TableText", position = {664, 435}, opacity = 0})
      local table_text = AssetLoader:getImage("TableText",{name="TableText", position = {674, 445}, opacity = 0})
      ttt = table_text
      screen:add( table_text )
      table_text:animate{opacity=255, duration=300, mode = "EASE_OUT_QUAD"}
      
      -- reset the CharacterSelectionView for the next game
      for i,t in ipairs(view.items) do
          for j,item in ipairs(t) do
              if item.group then item.group.opacity = 255 else item.opacity = 255 end
              if view.seats_chosen[i][j].group then
                  view.seats_chosen[i][j].group.opacity = 0
              end
          end
      end
      view.start_button.group.opacity = 0
   
      -- make sure last dog selected does not continue to glow
      for _,v in ipairs(DOG_GLOW) do
         v.opacity = 0
      end
      model:set_active_component(Components.GAME)
      game:initialize_game{
         sb=SMALL_BLIND,
         bb=BIG_BLIND,
         endowment=INITIAL_ENDOWMENT,
         randomness=RANDOMNESS,
         players=model.players
      }
      model:notify()
      old_on_key_down = nil
   end

   local CharacterSelectionCallbacks = {
      [CharacterSelectionGroups.TOP] = {},
      [CharacterSelectionGroups.BOTTOM] = {
         [START] = function()
            if self.playerCounter >= 2 then
               start_a_game()
            end
         end,
         [EXIT] = function() exit() return end,
         [HELP] = function()
            print("starting tutorial")
            model:set_active_component(Components.TUTORIAL)
            model:notify()
         end
      },
   }

   function self:getPosition(i, j)
      
      local sel = selected
      local subsel = subselection
      if i and j then
          sel = i
          subsel = j
      end
      
      local num
      
      if sel == 2 and subsel == 1 then
         num = 1
      elseif sel == 1 then
         num = 1 + subsel
      elseif sel == 2 and subsel == 5 then
         num = 6
      elseif sel == 2 and subsel == 2 then
         return "HELP_MENU"
      elseif sel == 2 and subsel == 3 then
         return "START"
      elseif sel == 2 and subsel == 4 then
         return "EXIT_MENU"
      else
         error("error selecting position", 2)
      end

      return num
      
   end

   -- called after a character is selected to rotate to the next available
   --character
   function self:new_position()

      if selected == 2 and subselection == 1 then
          selected = 1
      elseif selected == 1 then
         if subselection < 4 then
            subselection = subselection + 1
         else
            subselection = 5
            selected = 2
         end
      end
   end

   local function setCharacterSeat()

      --instantiate the player
      local pos = self:getPosition()
      if(model.positions[pos]) then return end
      local isHuman = false
      if(self.playerCounter == 0) then
         isHuman = true
         mediaplayer:play_sound(FIRST_PLAYER_MP3)
      end
      self.playerCounter = self.playerCounter + 1
      
      local args = {
         isHuman = isHuman,
         number = self.playerCounter,
         table_position = pos,
         position = model.default_player_locations[ self:getPosition() ],
         chipPosition = model.default_bet_locations[ self:getPosition() ],
         endowment = INITIAL_ENDOWMENT
      }

      -- insertion point
      local i = 1
      while i <= #model.players do
         if pos < model.players[i].table_position then
            break
         end
         i = i+1
      end
      table.insert(model.players, i, Player(args))
      model.positions[pos] = true
      model.currentPlayer = self.playerCounter

      if(self.playerCounter >= 2) then
         view.items[2][3].opacity = 255
      end
      model:notify()
      self:new_position()
      view:update()
   end

   local CharacterSelectionKeyTable = {
      [keys.Up] = function(self) self:move_selector(Directions.UP) end,
      [keys.Down] = function(self) self:move_selector(Directions.DOWN) end,
      [keys.Left] = function(self) self:move_selector(Directions.LEFT) end,
      [keys.Right] = function(self) self:move_selector(Directions.RIGHT) end,
      [keys.Return] =
         function(self)
            if(CharacterSelectionCallbacks[selected][subselection]) then
               CharacterSelectionCallbacks[selected][subselection]()
            else
               setCharacterSeat()
               if(self.playerCounter >= 6) then
                  start_a_game()
               end
            end
         end
   }
   CharacterSelectionKeyTable[keys.OK] = CharacterSelectionKeyTable[keys.Return]

   function self:on_key_down(k)
      if CharacterSelectionKeyTable[k] then
         CharacterSelectionKeyTable[k](self)
      end
   end

   function self:get_selected_index()
      return selected
   end

   function self:get_subselection_index()
      return subselection
   end

   local function check_for_valid(dir)
      if (CharacterSelectionGroups.TOP == selected) and
         (SubGroups.RIGHT == subselection) then
            subselection = SubGroups.RIGHT_MIDDLE 
      elseif CharacterSelectionGroups.BOTTOM == selected then
         if(0 ~= dir[2]) then
            if(subselection >= SubGroups.MIDDLE) then
               subselection = subselection + 1
            end
         elseif (0 ~= dir[1]) and (self.playerCounter < 2) and
            (subselection == SubGroups.MIDDLE) then
               subselection = subselection + dir[1]
         end
      end
   end

   function self:move_selector(dir)
      screen:grab_key_focus()
      if 0 ~= dir[1] then
         local new_selected = subselection + dir[1]
         if 1 <= new_selected and SubSize >= new_selected then
            subselection = new_selected
            check_for_valid(dir)
         end
      elseif 0 ~= dir[2] then
         if dir[2] == -1 and selected == CharacterSelectionGroups.BOTTOM and subselection == SubGroups.RIGHT_MIDDLE then
            selected = CharacterSelectionGroups.TOP
            subselection = SubGroups.MIDDLE
         else
            local new_selected = selected + dir[2]
            if 1 <= new_selected and GroupSize >= new_selected then
               selected = new_selected
               check_for_valid(dir)
            end
         end
      end
      model:notify()
   end

   function self:reset()
      self.playerCounter = 0
      selected = 2
      subselection = 1
      model.players = {}
      for i=1,6 do
         model.positions[i] = false
      end

      view:reset()
   end
end)
