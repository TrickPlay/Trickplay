local BAR_X = 166
local BAR_Y = 873
local CURR_TEMP_X = 74
local CURR_TEMP_Y = 62
local LOCATION_X  = 290
local LOCATION_Y  = 62
local HI_LO_X     = 290
local HI_LO_Y     = 104
local CONDITION_x = 902
local CONDITION_Y = 58
local BAR_SPACE   = 40


local FONT          = "Sans "
local LARGE_TEMP_SZ = "97px"
local LOCATION_SZ   = "32px"
local HI_LO_SZ      = "42px"
local CONDITION_SZ  = "26px"
local DEG           = "°"

local HI_TEMP_COLOR  = {209,209,209}
local LO_TEMP_COLOR  = {117,117,117}
local TEXT_COLOR     = {187,187,187}
local SHADOW_COLOR   = {  0,  0,  0}
local SHADOW_OPACITY =  255   *  .4



function Make_Mini_Bar()
    local bar = Group{
        x = BAR_X,
        y = BAR_Y,
    }
    local bg = Clone{source=imgs.bar.mini}
    local curr_temp = Text{
        name  = "Curr Temp",
        x     = CURR_TEMP_X,
        y     = CURR_TEMP_Y,
        font  = FONT.."97px",
        color = HI_TEMP_COLOR,
        text  = "65"
    }
    local hi_lo_temp = Text{
        name  = "High/Low Temp",
        x     = HI_LO_X,
        y     = HI_LO_Y,
        font  = FONT..HI_LO_SZ,
        color = HI_TEMP_COLOR,
        text  = "65"..DEG.."  43"..DEG
    }
    local location = Text{
        name  = "Location",
        x     = LOCATION_X,
        y     = LOCATION_Y,
        font  = FONT.."97px",
        color = TEXT_COLOR,
        text  = "Palo Alto, CA"
    }
    bar:add(bg,curr_temp,hi_lo_temp,location)
    return bar
end

function Make_Full_Bar(location)
    
end