
local function load_images()

    local total_decode_time = 0
    local total_upload_time = 0

    local individual_time = Stopwatch()
    
    local results = {}
    
    local update_time = Stopwatch()
    
    print( "Working...this can take a few minutes..." )
    
    for _,image in ipairs( app.contents ) do
    
        if update_time.elapsed_seconds >= 30 then
            print( "Still working..." )
            update_time:start()
        end
    
        if string.find( image , "assets" ) then
        
            individual_time:start()
            local bmp = Bitmap( image )
            individual_time:stop()
            
            local decode_time = individual_time.elapsed 
            
            individual_time:start()
            local img = bmp:Image()
            individual_time:stop()
            
            local upload_time = individual_time.elapsed 
            
            table.insert( results , { bmp.w , bmp.h , decode_time , upload_time , string.sub( image , 8 ) } )
            
            total_decode_time = total_decode_time + decode_time
            total_upload_time = total_upload_time + upload_time
            
            img = nil
            bmp = nil

            collectgarbage("collect")
        end
    end
    
    table.sort( results , function( a , b ) return a[1]*a[2] < b[1]*b[2] end )
    
    print( "" )
    print( "TRICKPLAY VERSION    : "..trickplay.version )
    print( "LOTSOFLOADS VERSION  : "..md5( readfile( "main.lua" ) ) )
    print( "" )
    
    print( "#   \twidth\theight\tdecode\tupload" )
    
    for i , result in ipairs( results ) do
        print( string.format( "%-4d\t%5d\t%5d\t%5.0f\t%5.0f\t%s" , 
            i,
            result[1],
            result[2],
            result[3],
            result[4],
            result[5] ) )
    end
    
    print( "-------------------------------------------------------------------------" )
    print( string.format( "%-4d  \t    \t    \t%5.0f\t%5.0f\t%5.0f" , 
        # results , 
        total_decode_time , 
        total_upload_time , 
        total_decode_time + total_upload_time ) )
        
    exit()        
end

if not trickplay.check_version or not trickplay:check_version( "1.16" ) then
    print( "PLEASE RUN WITH TRICKPLAY 1.16 OR LATER" )
else    
    dolater(load_images)
end   
