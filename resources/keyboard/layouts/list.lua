
local FOCUS_LARGE       = "focus-cancel-submit.png"
local FOCUS_PREV        = "focus-previous.png"
local FOCUS_NEXT        = "focus-next.png"
local FOCUS_LIST        = "focus-list-wide.png"
local FLASH_PREV        = "button-previous-r-pressed.png"
local FLASH_NEXT        = "button-next-g-pressed.png"

local H  = 20
local LX = 33

return
{
    name = "List",
    default =
    {
        image = "list-layout.png",
        first = "OSK_NEXT",
        layout =
        {
            {  53 ,  25 ,  90 , 38 , FOCUS_PREV        , "OSK_PREVIOUS"     , "R" , FLASH_PREV },
            { 381 ,  25 ,  90 , 38 , FOCUS_NEXT        , "OSK_NEXT"         , "G" , FLASH_NEXT },
            { 112 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_CANCEL"       },
            { 324 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_SUBMIT"       },
            
            { 217 , 105+LX*0  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*1  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*2  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*3  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*4  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*5  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*6  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*7  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*8  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*9  , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*10 , 415 , H , FOCUS_LIST        , "item" },
            { 217 , 105+LX*11 , 415 , H , FOCUS_LIST        , "item" },

        }
    }
    
}