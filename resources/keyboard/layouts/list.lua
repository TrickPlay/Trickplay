
local FOCUS_LARGE       = "focus-cancel-submit.png"
local FOCUS_PREV        = "focus-previous.png"
local FOCUS_NEXT        = "focus-next.png"

return
{
    name = "List",
    default =
    {
        image = "list-layout.png",
        first = "OSK_NEXT",
        layout =
        {
            {  53 ,  25 ,  90 , 38 , FOCUS_PREV        , "OSK_PREVIOUS"     , "R" },
            { 381 ,  25 ,  90 , 38 , FOCUS_NEXT        , "OSK_NEXT"         , "G" },
            { 112 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_CANCEL"       },
            { 324 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_SUBMIT"       }
        }
    }
    
}