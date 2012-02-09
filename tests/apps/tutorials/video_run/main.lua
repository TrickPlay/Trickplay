
-- How to Display Video in a TrickPlay Application

--[[ Basic Steps
		(1) Video is loaded via mediaplayer:load()
		(2) In videoLoaded() event handler, display a screen that includes a
		video viewport. This is the meat of the process.
		(3) After the video has run, in videoCompleted() event handler, remove
		the video viewport from the screen and restore the screen's original
		contents.
--]]

-- *********************************************************
-- Constants

-- Define the percentage of screen real estate used by the various regions
HEADER_PERCENT     = 0.12  -- percentage of screen height the header region uses
FOOTER_PERCENT     = HEADER_PERCENT

-- Using percentages above, calculate various coordinates
HEADER_HEIGHT      = (math.floor( screen.height * HEADER_PERCENT ) + 1)
FOOTER_HEIGHT      = (math.floor( screen.height * FOOTER_PERCENT ) + 1)
FOOTER_Y           = (screen.height - FOOTER_HEIGHT)
MAIN_HEIGHT        = (screen.height - HEADER_HEIGHT - FOOTER_HEIGHT)
MAIN_Y             = HEADER_HEIGHT

-- Define sizes of video screen and display areas
VIDSCREEN_WIDTH    = screen.width
VIDSCREEN_HEIGHT   = MAIN_HEIGHT
MAX_DISPLAY_WIDTH  = (VIDSCREEN_WIDTH - 200)
MAX_DISPLAY_HEIGHT = (VIDSCREEN_HEIGHT - 200)

-- Colors used in each region
HEADER_COLOR       = "rgba(46,57,131,255)"
HEADER_TITLE_COLOR = "rgba(255,165,64,255)"
FOOTER_COLOR       = HEADER_COLOR
FOOTER_TITLE_COLOR = HEADER_TITLE_COLOR

-- Fonts used
HEADER_TITLE_FONT  = "FreeSans Bold 75px"
FOOTER_TITLE_FONT  = "FreeSans 50px"

-- Images and videos used
BKGND_IMAGE        = "images/PaperTinted.png"
LOGO_IMAGE         = "images/Logo.jpg"
DEMO_VIDEO         = "images/LogoAnimation.avi"

-- Global variables that will be initialized later
BckImage           = nil
TpLogo             = nil
VidScreen          = nil

-- *********************************************************
function
displayMainScreen()

	--Define a header region, extending the entire screen's actual width
	local headerRect = Rectangle( { name = "headerRegion",
	                                size = { screen.width, HEADER_HEIGHT },
	                                position = { 0, 0 },
	                                color = HEADER_COLOR,
	} )
	screen:add( headerRect )

	-- Place app's title in header region
	local headerTitle = Text( { text = "TrickPlay Video Demo",
	                            font = HEADER_TITLE_FONT,
	                            color = HEADER_TITLE_COLOR,
	                            position = { 570, 15 },
	} )
	screen:add( headerTitle )
	
	-- Define a footer region
	local footerRect = Rectangle( { name = "footerRegion",
	                                size = { screen.width, FOOTER_HEIGHT },
	                                position = { 0, FOOTER_Y },
	                                color = FOOTER_COLOR,
	} )
	screen:add( footerRect )
	
	-- Place user instructions in footer region
	local footerTitle = Text( { text = "Press any key to display video",
	                            font = FOOTER_TITLE_FONT,
	                            color = FOOTER_TITLE_COLOR,
	                            position = { 620, FOOTER_Y + 30 },
	} )
	screen:add( footerTitle )

	-- Define remainder of screen as background region
	-- This must be a global variable because it will be hidden before
	-- displaying the video.
	BckImage = Image( { name = "bckgndTexture",
	                    src  = BKGND_IMAGE,
	                    position = { 0, MAIN_Y },
	                    size = { screen.width, MAIN_HEIGHT },
	                    tile = { true, true },
	} )
	if( BckImage.loaded )then
		screen:add( BckImage )
	end
	
	-- Display the TrickPlay 3D Logo in the main region
	-- This must be a global variable because it will be hidden before
	-- displaying the video.
	TpLogo = Image( { name = "TrickPlayLogo",
	                  src = LOGO_IMAGE,
	} )
	if( TpLogo.loaded )then
		-- Position image in the center of the main region
		TpLogo.position = { (screen.width - TpLogo.base_size[ 1 ]) / 2,
		                    ((MAIN_HEIGHT - TpLogo.base_size[ 2 ]) / 2) + MAIN_Y }
		screen:add( TpLogo )
	end
	
end  -- displayMainScreen()

-- *********************************************************
function
videoLoaded()

	-- Video has been loaded.
	-- Verify that we have loaded a video
	if( mediaplayer.has_video == false )then
		-- Something went wrong here
		print( "Loaded file is not a video" )
		return
	end
	
	-- Arrange the screen to show the video
	
	-- Need to create a videoScreen with a blank, transparent "hole" where the
	-- video will display.
	local videoScreen = Canvas( VIDSCREEN_WIDTH, VIDSCREEN_HEIGHT )
	
	-- Load the background image into a Bitmap object
	local bg = Bitmap( BKGND_IMAGE )
	if( bg.loaded == false )then
		print( "Failed to load the background image:", BKGND_IMAGE )
		return
	end
	
	-- Paint the entire videoScreen with the background image
	videoScreen:set_source_bitmap( bg )
	videoScreen.extend = "REPEAT"  -- tile the image to fill the entire area
	videoScreen:paint()
	
	-- Retrieve the actual resolution of the video
	local videoWidth  = mediaplayer.video_size[ 1 ]
	local videoHeight = mediaplayer.video_size[ 2 ]
	--print( "Original Video Resolution:", videoWidth, ",", videoHeight )
	
	-- Has the screen been scaled?
	if( screen.is_scaled )then
		-- Yes, then scale the video size, too
		-- Note: This scales only the amount of screen space the video will
		-- require; it does not scale the video, itself.
		videoWidth  = videoWidth  / screen.scale[ 1 ]
		videoHeight = videoHeight / screen.scale[ 2 ]
	end

	-- Is the video larger than our videoScreen?
	-- Note: These adjustments affect only the display area created for the
	-- video; they have no effect on the size of the video itself. It is not
	-- possible for a TrickPlay application to scale a video. The underlying
	-- system *may* scale a video in an attempt to make it fit, but each system
	-- handles this situation in its own manner. By reducing the display 
	-- area, as we are doing here, we pretty much guarantee that some portion
	-- of the video will be clipped. We perform these adjustments anyway so that
	-- we don't try to create a display area larger than our maximum display
	-- size.
	-- Check video width
	if( videoWidth > MAX_DISPLAY_WIDTH )then
		-- Scale video area, maintaining aspect ratio
		local scaleFactor = MAX_DISPLAY_WIDTH / videoWidth
		videoHeight = math.floor( videoHeight * scaleFactor )
		videoWidth = MAX_DISPLAY_WIDTH
	end
	
	-- Is the video's height too large for the videoScreen?
	if( videoHeight > MAX_DISPLAY_HEIGHT )then
		-- Scale video area, maintaining aspect ratio
		local scaleFactor = MAX_DISPLAY_HEIGHT / videoHeight
		videoWidth = math.floor( videoWidth * scaleFactor )
		videoHeight = MAX_DISPLAY_HEIGHT
	end
	--print( "Calculated Video Area Size:", videoWidth, ",", videoHeight )

	-- Position video area in the center of the videoScreen
	local displayAreaX = (VIDSCREEN_WIDTH  - videoWidth)  / 2
	local displayAreaY = (VIDSCREEN_HEIGHT - videoHeight) / 2
	
	-- The video viewport is always behind the screen. To see the video, a
	-- hole must be cut in the videoScreen to make the viewport behind it
	-- visible.
	
	-- Create a rectangle that's the size of the video area
	videoScreen:rectangle( displayAreaX, displayAreaY, videoWidth, videoHeight )
	videoScreen.line_width = 0
	
	-- Set the compositing operator so the rectangle will create a transparent
	-- hole in the videoScreen.
	videoScreen.op = "CLEAR"
	
	-- Create the transparent hole in the videoScreen
	videoScreen:fill()
	
	-- Convert the Canvas to an Image for displaying. Note: The VidScreen is
	-- positioned in front of the BckImage and TpLogo objects.
	-- The VidScreen must be global so we can hide it after the video is finished.
	VidScreen = videoScreen:Image( { name = "videoScreen",
	                                 position = { 0, MAIN_Y },
	} )
	
	-- Put VidScreen on the screen. This covers the BckImage and TpLogo objects,
	-- except for any portions that are exposed through the video hole.
	screen:add( VidScreen )
	
	-- Set the video viewport location so it matches the position of the video hole.
	-- Note: The viewport X/Y are calculated by multiplying the screen X/Y
	-- by the screen width/height scale factors.
	local viewportX = displayAreaX * screen.scale[ 1 ]
	local viewportY = (displayAreaY + MAIN_Y) * screen.scale[ 2 ]
	mediaplayer:set_viewport_geometry( viewportX, viewportY,
	                                   mediaplayer.video_size[ 1 ],
	                                   mediaplayer.video_size[ 2 ] )

	-- Hide the portions of the original screen that are exposed through the
	-- video hole. There is now an empty hole through the screen where the
	-- video can be viewed.
	BckImage:hide()
	TpLogo:hide()
	
	-- Finally, play the video.
	-- When finished, the videoCompleted() handler will be invoked, and we can
	-- restore the original screen contents.
	mediaplayer:play()

end  -- videoLoaded()

-- *********************************************************
function
videoError()

	-- Could not load or play the video
	print( "Error loading or playing the video" )
	
end  -- videoError()

-- *********************************************************
function
videoCompleted()

	-- The video has finished playing
	
	-- Restore the original screen contents
	BckImage:show()
	TpLogo:show()
	
	-- Hide and delete the VidScreen
	VidScreen:hide()
	VidScreen = nil  -- this will be recreated every time a video is played

end  -- videoCompleted()

-- *********************************************************
function
playVideo()

	-- Initialize video event handlers
	mediaplayer.on_loaded        = videoLoaded     -- invoked upon successful loading
	mediaplayer.on_error         = videoError      -- invoked upon load failure
	mediaplayer.on_end_of_stream = videoCompleted  -- invoked when video finishes playing
	
	-- Try to load the video
	mediaplayer:load( DEMO_VIDEO )

end  -- playVideo()

-- *********************************************************
-- Program entry point

-- Initialize screen (color regions, title, etc.)
displayMainScreen()

-- On any keypress, play a video
screen.on_key_down = playVideo

-- Show the screen
screen:show()

