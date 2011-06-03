
local FOCUS_KEY         = "focus-key.png"
local FOCUS_SPACE       = "focus-space.png"
local FOCUS_LARGE       = "focus-cancel-submit.png"
local FOCUS_PREV        = "focus-previous.png"
local FOCUS_NEXT        = "focus-next.png"
local FOCUS_SHIFT       = "focus-shift.png"
local FOCUS_BACKSPACE   = "focus-backspace.png"

local RX            = 24
local RY            = 158
local DY            = 51
local DX            = 43
local HX            = 21

return
{
    {
        name = "English QWERTY",
        default =
        {
            image = "typing-layout-qwerty.png",
            first = "q",
            layout =
            {
                {  53 ,  25 ,  90 , 38 , FOCUS_PREV        , "OSK_PREVIOUS"     , "R" },
                { 381 ,  25 ,  90 , 38 , FOCUS_NEXT        , "OSK_NEXT"         , "G" },
                {  53 , 412 ,  90 , 38 , FOCUS_SHIFT       , "OSK_SHIFT"        , "B" },
                { 381 , 412 ,  90 , 38 , FOCUS_BACKSPACE   , "OSK_BACKSPACE"    , "Y" },
                { 112 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_CANCEL"       },
                { 324 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_SUBMIT"       },
                
                { RX+HX+DX*4 , 413  , 200 , 38 , FOCUS_SPACE , " "    },
            
                { RX+DX*0 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "-"      },
                { RX+DX*1 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "/"      },
                { RX+DX*2 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , ":"      },
                { RX+DX*3 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , ";"      },
                { RX+DX*4 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "("      },
                { RX+DX*5 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , ")"      },
                { RX+DX*6 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "$"      },
                { RX+DX*7 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "&"      },
                { RX+DX*8 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "'"      },
                { RX+DX*9 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "\""     },
                
                { RX+DX*0 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "1"      },
                { RX+DX*1 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "2"      },
                { RX+DX*2 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "3"      },
                { RX+DX*3 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "4"      },
                { RX+DX*4 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "5"      },
                { RX+DX*5 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "6"      },
                { RX+DX*6 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "7"      },
                { RX+DX*7 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "8"      },
                { RX+DX*8 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "9"      },
                { RX+DX*9 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "0"      },
                
                { RX+DX*0 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "q"      },
                { RX+DX*1 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "w"      },
                { RX+DX*2 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "e"      },
                { RX+DX*3 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "r"      },
                { RX+DX*4 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "t"      },
                { RX+DX*5 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "y"      },
                { RX+DX*6 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "u"      },
                { RX+DX*7 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "i"      },
                { RX+DX*8 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "o"      },
                { RX+DX*9 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "p"      },
                
                { RX+HX+DX*0 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "a"      },
                { RX+HX+DX*1 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "s"      },
                { RX+HX+DX*2 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "d"      },
                { RX+HX+DX*3 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "f"      },
                { RX+HX+DX*4 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "g"      },
                { RX+HX+DX*5 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "h"      },
                { RX+HX+DX*6 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "j"      },
                { RX+HX+DX*7 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "k"      },
                { RX+HX+DX*8 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "l"      },
            
                { RX+HX+DX*1 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "z"      },
                { RX+HX+DX*2 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "x"      },
                { RX+HX+DX*3 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "c"      },
                { RX+HX+DX*4 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "v"      },
                { RX+HX+DX*5 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "b"      },
                { RX+HX+DX*6 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "n"      },
                { RX+HX+DX*7 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "m"      },
            
                { RX+HX+DX*2 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "."      },
                { RX+HX+DX*3 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , ","      },
                { RX+HX+DX*4 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "?"      },
                { RX+HX+DX*5 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "!"      },
                { RX+HX+DX*6 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "@"      },
            }
        },
        
        shift =
        {
            image = "typing-layout-qwerty-shift.png",
            first = "Q",
            layout =
            {
                {  53 ,  25 ,  90 , 38 , FOCUS_PREV        , "OSK_PREVIOUS"     , "R" },
                { 381 ,  25 ,  90 , 38 , FOCUS_NEXT        , "OSK_NEXT"         , "G" },
                {  53 , 412 ,  90 , 38 , FOCUS_SHIFT       , "OSK_SHIFT"        , "B" },
                { 381 , 412 ,  90 , 38 , FOCUS_BACKSPACE   , "OSK_BACKSPACE"    , "Y" },
                { 112 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_CANCEL"       },
                { 324 , 536 , 200 , 64 , FOCUS_LARGE       , "OSK_SUBMIT"       },
                
                { RX+HX+DX*4 , 413  , 200 , 38 , FOCUS_SPACE , " "    },
            
                { RX+DX*0 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "~"      },
                { RX+DX*1 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "#"      },
                { RX+DX*2 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "%"      },
                { RX+DX*3 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "^"      },
                { RX+DX*4 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "*"      },
                { RX+DX*5 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "_"      },
                { RX+DX*6 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "="      },
                { RX+DX*7 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "+"      },
                { RX+DX*8 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , "<"      },
                { RX+DX*9 , RY+DY*0 ,  30 , 38 , FOCUS_KEY , ">"      },
                
                { RX+DX*0 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "1"      },
                { RX+DX*1 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "2"      },
                { RX+DX*2 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "3"      },
                { RX+DX*3 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "4"      },
                { RX+DX*4 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "5"      },
                { RX+DX*5 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "6"      },
                { RX+DX*6 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "7"      },
                { RX+DX*7 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "8"      },
                { RX+DX*8 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "9"      },
                { RX+DX*9 , RY+DY*1 ,  30 , 38 , FOCUS_KEY , "0"      },
                
                { RX+DX*0 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "Q"      },
                { RX+DX*1 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "W"      },
                { RX+DX*2 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "E"      },
                { RX+DX*3 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "R"      },
                { RX+DX*4 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "T"      },
                { RX+DX*5 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "Y"      },
                { RX+DX*6 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "U"      },
                { RX+DX*7 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "I"      },
                { RX+DX*8 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "O"      },
                { RX+DX*9 , RY+DY*2 ,  30 , 38 , FOCUS_KEY , "P"      },
                
                { RX+HX+DX*0 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "A"      },
                { RX+HX+DX*1 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "S"      },
                { RX+HX+DX*2 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "D"      },
                { RX+HX+DX*3 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "F"      },
                { RX+HX+DX*4 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "G"      },
                { RX+HX+DX*5 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "H"      },
                { RX+HX+DX*6 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "J"      },
                { RX+HX+DX*7 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "K"      },
                { RX+HX+DX*8 , RY+DY*3-1 ,  30 , 38 , FOCUS_KEY , "L"      },
            
                { RX+HX+DX*1 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "Z"      },
                { RX+HX+DX*2 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "X"      },
                { RX+HX+DX*3 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "C"      },
                { RX+HX+DX*4 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "V"      },
                { RX+HX+DX*5 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "B"      },
                { RX+HX+DX*6 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "N"      },
                { RX+HX+DX*7 , RY+DY*4-1 ,  30 , 38 , FOCUS_KEY , "M"      },
            
                { RX+HX+DX*2 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "."      },
                { RX+HX+DX*3 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , ","      },
                { RX+HX+DX*4 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "?"      },
                { RX+HX+DX*5 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "!"      },
                { RX+HX+DX*6 , RY+DY*6+3 ,  30 , 38 , FOCUS_KEY , "@"      },
            }
        }
    },
    
    {
        name = "Some other layout",
        
        default = 
        {
            image = "",
            first = "",
            layout =
            {
            }
        },
        
        shift =
        {
            image = "",
            first = "",
            layout =
            {
            }
        }
    }
}