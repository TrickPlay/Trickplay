
return
{
    
    {
        title       = "Burberry",
        dropdown    = "showcase/burberry/dropdown.png",
        enter       = function( ui ) apps:launch( "com.trickplay.burberry" ) end
    }
    ,
    {
        title       = "J.Y. Park 박진영",
        dropdown    = "showcase/jyp/dropdown.png",
        enter       = function( ui ) return dofile( "showcase/jyp/showcase.lua" )( ui ) end
    }
    ,
    {
        title       = "Mountain Dew",
        dropdown    = "showcase/mountain-dew/dropdown.png",
        enter       = function( ui ) return dofile( "showcase/mountain-dew/showcase.lua" )( ui ) end
    }
}