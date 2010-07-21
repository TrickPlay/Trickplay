-- All Global Variables


FULL = 0
EMPTY = 1
WALKABLE = 2


SP = 120
SPW = SP
SPH = SP
SQUARE_PIXEL_WIDTH = SP
SQUARE_PIXEL_HEIGHT = SP



BOARD_WIDTH  = 1920/SP
BOARD_HEIGHT = 1080/SP
BW = 1920/SP
BH = 1080/SP


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
	return (x-1)*SP
end

function PTG (x)
	return math.floor(x/SP)+1
end


-- ASSETS


bulletImage = Rectangle { color = "FF0000", x = -100, y = -100, z = 2, width = 15, height = 15}
healthbar = Rectangle {color = "00FF00", width = SP, height = 10}

creepGold = {}

for i = 1, CREEP_WAVE_LENGTH do
	creepGold[i] = 0
end
 
screen:add(bulletImage, healthbar)
