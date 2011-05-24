--animation durations
TRANS_DUR = 800

--I f*cking hate radians
function sin(val) return math.sin(math.pi/180*val) end
function cos(val) return math.cos(math.pi/180*val) end
function tan(val) return math.tan(math.pi/180*val) end

screen_w = screen.w
screen_h = screen.h

main_screen = Group{}

ENUM             = dofile("Utils.lua")

GLOBAL_STATE     = ENUM({"TRANSITIONING","BOTTLES","LEFT_BUTTONS","RIGHT_BUTTONS","VIDEO"})

KEY_HANDLER      = dofile("User_Input.lua")

VIDEO            = dofile("Videos.lua")

BOTTLE_DOCK      = dofile("Bottle_Dock.lua")

LEFT_BAR         = dofile("Left_Bar.lua")

RIGHT_BAR        = dofile("Right_Bar.lua")

PAGE_CONSTRUCTOR = dofile("Page.lua")

CAROUSEL         = dofile("Carousel.lua")



screen.on_key_down = KEY_HANDLER.on_key_down

GLOBAL_STATE:change_state_to("BOTTLES")

screen:show()


main_screen:add(
	Rectangle{color="#000000",w=screen_w,h=screen_h},
	CAROUSEL,
	RIGHT_BAR,
	LEFT_BAR
)

screen:add(
	VIDEO,
	main_screen
)
