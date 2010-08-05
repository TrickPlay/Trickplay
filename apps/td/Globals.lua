-- Loaded Game Variables


-- All Global Variables


FULL = 0
EMPTY = 1
WALKABLE = 2


SP = 120
SPW = SP
SPH = SP
SQUARE_PIXEL_WIDTH = SP
SQUARE_PIXEL_HEIGHT = SP

WAIT_TIME = 10
FIRST_WAIT = 10
WAIT = 3

BOARD_WIDTH  = 1920/SP
BOARD_HEIGHT = 1080/SP
BW = 1920/SP
BH = 1080/SP

CREEP_START = {4, 1}
CREEP_END = {4, BW}

CREEP_WAVE_LENGTH = 30

seconds_elapsed = Stopwatch()
creep_spawn_timer = 0

wave_counter = 0

resumed = false
round = 1
tnum = 1

savedTowerType = {}
savedTowerOwner = {}
savedTowerPos = {}
savedTowerUpgrades = {}


level = 1

--image_to_load = {"normal","mediumRobot"}

--creep_image_table = {}


creepGold = {}
spawnCreep = {}
creepnum = 1
wavePartCounter = 1
creeppartnum = 1

countdowntimer = Text { font = "Sans 30px", text = "", x = 900, y = 1015, z=3, color = "000000", opacity=0}
phasetext = Text { font = "Sans 30px", text = "Build Phase!", x =1200, y = 1015, z=3, color = "000000", opacity=0}
livestext = Text { font = "Sans 30px", text = "", x =1570, y = 1015, z=3, color = "000000"}
playertext = Text {font = "Sans 30px", text = "", x =1300, y = 1015, z=3, color = "000000"}
goldtext = Text {font = "Sans 30px", text = "", x =1800, y = 1015, z=3, color = "000000" }

-- global functions

--convert from grid coord to pixel coord

function GTP (x)
	return (x-1)*SP
end

function PTG (x)
	return math.floor(x/SP)+1
end


-- ASSETS
bloodGroup = Group{z = 1, opacity = 155}


bulletImage = Rectangle { color = "FF0000", x = -100, y = -100, z = 2, width = 15, height = 15}
healthbar = Rectangle {color = "00FF00", width = SP, height = 10, y=-100}
healthbarblack = Rectangle {color = {34,139,34}, width = SP, height = 10, y=-100}
shootAnimation = Rectangle {color = {200,200,0}, x = -100, y = -100, width = 10, height = 10}
 

