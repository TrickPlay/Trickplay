

local bgc = Image{ src = "assets/bg-clouds-1080p.jpg" , scale = { 2 , 2 } }
local bgs = Image{ src = "assets/bg-planet-topleft.png" }

background_layer:add( bgc , bgs )

local function bg_step( seconds )
    -- animate background
end


-------------------------------------------------------------------------------
-- Add invisible walls
-------------------------------------------------------------------------------

local CORNER_BUMPER_X        = 40
local CORNER_BUMPER_Y        = 40
local CORNER_BUMPER_SIZE     = {      CORNER_BUMPER_X * 2 , CORNER_BUMPER_Y * 2 }
local CORNER_BUMPER_ROTATION = { 46 , CORNER_BUMBER_X     , CORNER_BUMPER_Y     }
local STATIC = { type = "static" }

background_layer:add(
    
    --Walls
    
    physics:Body( Group{ size = {  2 , screen_h } , position = { -2 ,        0 } } , STATIC ),
    physics:Body( Group{ size = {  2 , screen_h } , position = { screen_w ,  0 } } , STATIC ),
    physics:Body( Group{ size = { screen_w ,  2 } , position = {  0 ,       -2 } } , STATIC ),
    physics:Body( Group{ size = { screen_w ,  2 } , position = {  0 , screen_h } } , STATIC ),
    
    -- Triangle Corners
    -- These help keep the small spheres from getting stuck in the corners
    
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { - CORNER_BUMPER_X , - CORNER_BUMPER_Y } } , STATIC ),
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { - CORNER_BUMPER_X , screen_h - CORNER_BUMPER_Y } } , STATIC ),
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { screen_w - CORNER_BUMPER_X , - CORNER_BUMPER_Y } } , STATIC ),
    physics:Body( Group{ size = CORNER_BUMPER_SIZE , z_rotation = CORNER_BUMPER_ROTATION , position = { screen_w - CORNER_BUMPER_X , screen_h - CORNER_BUMPER_Y } } , STATIC )
)




