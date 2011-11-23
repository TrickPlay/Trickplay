BoardTimer = Group()
BoardTimer:hide()
BoardTimer.opacity = 0
BoardTimer.position = {600,1080}
screen:add(BoardTimer)

function TimerBoardShow(player_icon)
	local background_image = ui:createTimerBack{position={0,0}}
	local offSpriteProps = {opacity=0}	
	local onSpriteProps = {opacity=255}
	BoardTimer:clear()
	BoardTimer:add(background_image)
	BoardTimer.w = background_image.w
	BoardTimer.h = background_image.h
	BoardTimer.extra.tick = 0
	BoardTimer.extra.sprites = {}
	for i=1,7 do
		offSpriteProps.position = {(i-1) * 100 , 0}
		onSpriteProps.position = offSpriteProps.position
		if player_icon == "X" then
			BoardTimer.extra.sprites[i] = {off=ui:createTimerOffRed(offSpriteProps),on=ui:createTimerOnRed(onSpriteProps)}
		elseif player_icon == "O" then
			BoardTimer.extra.sprites[i] = {off=ui:createTimerOffBlue(offSpriteProps),on=ui:createTimerOnBlue(onSpriteProps)}
		else
			print("DEBUG: Didnt get anything")
		end
		BoardTimer:add(BoardTimer.extra.sprites[i].on , BoardTimer.extra.sprites[i].off)
	end
	BoardTimer:show()
	BoardTimer:animate{ duration=100, position={600,920}, opacity=255}
end

function BoardTimerChangeSprite(position)
	BoardTimer.extra.sprites[position].off:animate{duration=100,opacity = 255}
	BoardTimer.extra.sprites[position].on:animate{duration=100,opacity = 0}
end

function TimerBoardTick()
    mediaplayer:play_sound("audio/Tic Tac Go Timer.mp3")
    local tick = BoardTimer.extra.tick
	if tick == 3 then
		BoardTimerChangeSprite(4)
		return
	elseif tick < 3 then
		BoardTimerChangeSprite(1 + tick)
		BoardTimerChangeSprite(7 - tick)
	end
	BoardTimer.extra.tick = tick + 1
end

function TimerBoardClear()
	BoardTimer:animate{duration=100,position={600,1080}}
end
