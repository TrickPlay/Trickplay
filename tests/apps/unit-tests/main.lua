-- Unit Test Framework
dofile( "unit_test.lua" )

-- Unit Tests
--dofile( "urlRequest2.lua" )  -- Failing because can't fail url request due to URL redirect.
--dofile( "Alpha1.lua" )  -- Failing because of bug 713.
--dofile( "profile1.lua" ) -- Failing. Need to investigate how to set profile property.


dofile( "xmlParser1.lua" ) 
dofile( "xmlParser2.lua" )
dofile( "timer1.lua")
dofile( "urlRequest1.lua" )
dofile( "UIElement1.lua" )
dofile( "UIElement2.lua" )
dofile( "UIElement3.lua" )
dofile( "UIElement4.lua" )
dofile( "UIElement6.lua" )
dofile( "UIElement5.lua" )
dofile( "UIElement7.lua" )
dofile( "UIElement8.lua" )
dofile( "UIElement9.lua" )
dofile( "UIElement10.lua" )
dofile( "Container1.lua" )
dofile( "Container2.lua" )
dofile( "Container3.lua" )
dofile( "Container4.lua" )
dofile( "screen1.lua" )
dofile( "clone1.lua" )
dofile( "image1.lua")
dofile( "image2.lua")
dofile( "Rectangle1.lua")
dofile( "text1.lua" )
dofile( "text2.lua" )
dofile( "Timeline1.lua" )
dofile( "Timeline2.lua" )
dofile( "Timeline3.lua" )
dofile( "Timeline4.lua" )
dofile( "Timeline5.lua" )
dofile( "Timeline6.lua" )
dofile( "Interval1.lua" )
dofile( "Path1.lua" )
dofile( "Path2.lua" )
-- dofile( "Alpha2.lua" )  ** 03/25/2011: pvdhagen - unit test bug. Need to investigate.
dofile( "app1.lua" )
dofile( "load_file1.lua" )
dofile( "readfile1.lua" )
dofile( "choose1.lua" )
dofile( "serialize1.lua" )
dofile( "encoding_encrypting1.lua" )
dofile( "global_misc1.lua" )
dofile( "json1.lua" ) 
dofile( "trickplay1.lua" )
dofile( "settings1.lua" )
dofile( "system1.lua" )
dofile( "uri1.lua" )
dofile( "stopwatch1.lua" )
dofile( "mediaplayer1.lua" ) 
dofile( "bitmap1.lua") 
dofile( "canvas1.lua" ) 

-- Timer to give sometime for any tests to complete before calling unit_test
local total = 0

function idle.on_idle( idle , seconds )
      total = total + seconds
      if total >= 3 then
        local results = unit_test()   --run unit_test
        idle.on_idle = nil
	exit ()
      end
end





