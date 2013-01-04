--
-- TrickPlay OEM Plug-in Test Program
--
-- Calls function in the Noise plug-in
--
-- ****************************************************************************
-- Constants

backgroundColor	= "gray50"
rectColor		= "gray80"

labelFont    	= "FreeSans 60px"
labelColor   	= "gray22"
linearLabelX 	= 50
linearLabelY	= 20
noiseLabelX  	= linearLabelX
noiseLabelY		= ((screen.height / 2) + 30)

-- Global variables promote good health
noNoise       	= nil		-- linear-animated rectangle
noNoiseSize   	= 100
noNoiseStartX 	= (0 - noNoiseSize)
noNoiseStartY 	= (screen.height / 4) - (noNoiseSize / 2)
noNoiseEndX   	= screen.width
noNoiseEndY   	= noNoiseStartY
noNoisePath   	= Interval( noNoiseStartX, noNoiseEndX )

noise         	= nil       -- noise-animated rectangle
noiseSize     	= noNoiseSize
noiseStartX   	= (0 - noiseSize)
noiseStartY   	= ((screen.height / 4) * 3) - (noiseSize / 2)
noiseEndX     	= screen.width
noiseEndY     	= noiseStartY
noisePath     	= Interval( noiseStartX, noiseEndX )
noiseFactorX  	= 10
noiseFactorY  	= 10
noiseOffset   	= 0.0

animationTL   	= nil

-- ****************************************************************************
function
displayMainScreen()

	-- Define a screen background
	local scrBackground = Rectangle( { name = "scrBackground",
	                                   size = { screen.width, screen.height },
	                                   position = { 0, 0, 0 },
	                                   color = backgroundColor,
	} )
	screen:add( scrBackground )

	-- Divide the screen vertically in half
	local dividerHeight = 10
	local divider = Rectangle( { name = "scrDivider",
	                             size = { screen.width, dividerHeight },
	                             position = { 0, (screen.height + dividerHeight) / 2 },
	                             color = labelColor,
	} )
	screen:add( divider )

	-- Add descriptive footers
	local controlLabel = Text( { text = "Linear",
	                             font = labelFont,
	                             color = labelColor,
	                             position = { linearLabelX, linearLabelY, 0 },
	} )
	screen:add( controlLabel )

	local noiseLabel = Text( { text = "Noise (calls Noise plug-in)",
	                           font = labelFont,
	                           color = labelColor,
	                           position = { noiseLabelX, noiseLabelY, 0 },
	} )
	screen:add( noiseLabel )

end -- displayMainScreen()

-- ****************************************************************************
function
animationHandler( timeline, msecs, progress )

	-- Advance the linear-controlled rectangle
	noNoise.x = noNoisePath:get_value( progress )

	-- Apply noise factor to noise-adjusted rectangle's path
	local prog = noisePath:get_value( progress )  -- get current X coordinate

	-- Call the Noise plug-in to get a noise value
	local noiseValue = getPerlinNoise( prog, noiseStartY, 0.0 ) * noiseFactorY

	noiseOffset = noiseOffset + noiseValue   -- accumulate noiseValue for animation cycle
	noise.x     = prog                       -- set unmodified X coordinate
	noise.y     = noiseStartY + noiseOffset  -- adjust Y coordinate with accumulated noiseValue

end -- animationHandler()

-- ****************************************************************************
function
completionHandler( timeline )

	-- Reset noiseOffset accumulator
	noiseOffset = 0.0

end -- completionHandler()

-- ****************************************************************************
function
setupAnimation()

	-- Define the two rectangles to animate
	noNoise = Rectangle( { name = "controlRect",
	                       size = { noNoiseSize, noNoiseSize },
	                       color = rectColor,
	                       position = { noNoiseStartX, noNoiseStartY, 0 },
	} )
	screen:add( noNoise )

	noise = Rectangle( { name = "noisyRect",
	                     size = { noiseSize, noiseSize },
	                     color = rectColor,
	                     position = { noiseStartX, noiseStartY, 0 },
	} )
	screen:add( noise )

	-- Setup the Timeline
	animationTL = Timeline( { duration = 2000,
	                          loop = true,
	                          on_new_frame = animationHandler,
	                          on_completed = completionHandler,
	} )

end -- setupAnimation()

-- ****************************************************************************
-- Main program entry point

	-- Setup the screen and show it
	displayMainScreen()
	setupAnimation()
	screen:show()

	-- Start the animation
	animationTL:start()

-- ****************************************************************************

