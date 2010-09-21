function screen.on_key_down(screen,keyval)
	key_actions = {
		[keys.Right] =  function()
			if pointerAtCol >= totalNumberOfCols then
				return
			else
				on_track_blur(pointerAtCol,pointerAtRow)
				pointerAtCol = pointerAtCol + 1
				on_track_focus(pointerAtCol,pointerAtRow)
			end
		end,
		
		[keys.Left] = function()
			if pointerAtCol == 0 then
				return
			else
				on_track_blur(pointerAtCol,pointerAtRow)
				pointerAtCol = pointerAtCol - 1
				on_track_focus(pointerAtCol,pointerAtRow)
			end
		end,
		
		[keys.Up] = function()
			if pointerAtRow == 0 then
				return
			else
				on_track_blur(pointerAtCol,pointerAtRow)
				pointerAtRow = pointerAtRow - 1
				on_track_focus(pointerAtCol,pointerAtRow)
			end
		end,
		
		[keys.Down] = function()
			if pointerAtRow >= totalNumberOfRows then
				return
			else
				on_track_blur(pointerAtCol,pointerAtRow)
				pointerAtRow = pointerAtRow + 1
				on_track_focus(pointerAtCol,pointerAtRow)
			end
		end,
		[keys.space] = function()
			on_track_select(pointerAtCol,pointerAtRow)
		end,
	}
	
	if key_actions[keyval] then
		key_actions[keyval]()
	else
		print("KEY: "..keyval)
	end
end