-- Functions regarding the main playfield
PlayField = Group()
PlayField.x = 600
PlayField.y = -900
PlayField.opacity = 0
PlayField.extra.miniBoards = {}

screen:add(PlayField)

function NewPlayField()
	local background_image = ui:createFieldLg{x=0,y=0}
	local enterButtonPosition = {240,720}
	PlayField:clear()
	PlayField.h = background_image.h
	PlayField.w = background_image.w
	PlayField:add(ui:createFieldLg{x=0,y=0})
	PlayField:animate{duration=500,y=60,opacity=255}
end

function FuckPlayField()
	PlayField:animate{duration=500,y=-900,opacity=0,on_completed = function() 		        NewPlayField()
        		StatusText:pressToMove() end}
end

function ClearPlayField()
	PlayField:animate{duration=500,y=-900,opacity=0}
end

function SavePlayField (board,winspots,number_of_wins,gamenumber)
	local number_of_wins =tonumber(number_of_wins)
	local miniboard_background = ui:createFieldSm()
	local MiniBoard    = Group()
	local GameSavePos  = {}
	local GameSavePosX = { {300,120},{300,420},{300,720},{60,120},{60,420},{60,720} }
	local GameSavePosO = { {1440,120},{1440,420},{1440,720},{1680,120},{1680,420},{1680,720} }
	MiniBoard:add(ui:createFieldSm{x=0,y=0})
	MiniBoard.w = miniboard_background.w
	MiniBoard.h = miniboard_background.h
	local boardText = Text{text="Game " .. gamenumber}
	boardText.position = {42,192}
	-- boardText.anchor_point = {boardText.w/2,boardText.h/2}
	boardText.color="FFFFFF"
	boardText.font = "DejaVu Sans 26px"
	MiniBoard:add(boardText)
	ui:createTextShadow(boardText)
	for index, value in ipairs(board) do
		local col,row = Utils.index_to_column_row(index)
		local MiniPiece = nil
    	if winspots[1] == index or winspots[2] == index or winspots[3] == index then
    		if value == "X" then
	    		MiniPiece = ui:createPieceSmXC()
	    		GameSavePos = GameSavePosX[number_of_wins]
    		elseif value == "O" then
    			MiniPiece = ui:createPieceSmOC()
    			GameSavePos = GameSavePosO[number_of_wins]
    		end
     	elseif value == "X" then
      		MiniPiece = ui:createPieceSmXG()
     	elseif value == "O" then
     		MiniPiece = ui:createPieceSmOG()
     	end
     	
     	if MiniPiece ~= nil then
	     	MiniPiece.position = calcPosition(MiniBoard.w/3,MiniPiece.w,col,row)
	     	MiniBoard.position = GameSavePos
	     	MiniBoard:add(MiniPiece)
     	end
    end
    table.insert(PlayField.extra.miniBoards, MiniBoard)

    screen:add(MiniBoard)
end

function ClearMiniBoards()
	for index, miniboard in ipairs(PlayField.extra.miniBoards) do
		PlayField.extra.miniBoards[index] = nil
		screen:remove(miniboard)
    end
end

function PlayFieldAddPiece (player_icon,col,row)
	local current_piece
	if player_icon == "X" then
		current_piece = ui:createPieceLgXC()
	elseif player_icon == "O" then 
		current_piece = ui:createPieceLgOC()
		end
	current_piece.extra.is_moving=true
	current_piece.position = calcPosition(PlayField.w/3, current_piece.w, col, row)
	PlayField:add(current_piece)
	return current_piece
end

function PlayFieldMovePiece(piece,col,row)
	if piece.extra.is_moving then
		local newposition = calcPosition(PlayField.w/3, piece.w, col, row)
		piece:animate{duration=160,position=newposition}
		piece:show()
		piece.opacity = 128
	end
end

function PlayFieldFixPiece(piece) 
	piece.extra.is_moving=false
	piece.opacity=255
end

function calcPosition(squareWidth,pieceWidth,col,row)
	local margins = ( squareWidth - pieceWidth ) / 2
	local xpos    = margins + ((col-1)*squareWidth)
	local ypos    = margins + ((row-1)*squareWidth)
	return { xpos, ypos }
end

--timer=Timer() timer.interval=5 function timer.on_timer(timer)	EnterButtonPressed() end timer:start()



