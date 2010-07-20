-- All Global Variables

BOARD_WIDTH  = 32
BOARD_HEIGHT = 18

FULL = 0
EMPTY = 1
WALKABLE = 2

SQUARE_PIXEL_WIDTH = 60
SQUARE_PIXEL_HEIGHT = 60
SPW = 60
SPH = 60

CREEP_WAVE_LENGTH = 30

seconds_elapsed = 0

wave_counter = 0

creep_image_table = {}

countdowntimer = Text { font = "Sans 30px", text = ""..seconds_elapsed, x = 1400, y = 50, z=3, color = "FFFFFF"}
phasetext = Text { font = "Sans 30px", text = "Build Phase!", x =1000, y = 50, z=3, color = "FFFFFF"}
playertext = Text {font = "Sans 30px", text = "", x =700, y = 950, z=3, color = "FFFFFF"}
goldtext = Text {font = "Sans 30px", text = "", x =600, y = 950, z=3, color = "FFFFFF" }
screen:add(countdowntimer, phasetext, playertext, goldtext)


-- global functions

--convert from grid coord to pixel coord

function GTP (x)
	return (x-1)*60
end

function PTG (x)
	return math.floor(x/60)+1
end


-- ASSETS


bulletImage = Rectangle { color = "FF0000", x = -100, y = -100, z = 2, width = 15, height = 15}
healthbar = Rectangle {color = "00FF00", width = 60, height = 10}
 
 
screen:add(bulletImage, healthbar)
