    local image_list = {
        "David_Urbanke_Flickr-64.jpg",
        "DrGulas_Flickr-64.jpg",
        "HeyRocker_Flickr-64.jpg",
        "Matthew_Tosh_Flickr-64.jpg",
        "Morgan_Solar_Flickr-64.jpg",
        "Tambako_the_Jaguar_2_Flickr-64.jpg",
        "Tambako_the_Jaguar_Flickr-64.jpg",
        "[cypher]_Flickr-64.jpg",
        "David_Urbanke_Flickr-77.jpg",
        "David_Urbanke_Flickr-77.png",
        "DrGulas_Flickr-77.jpg",
        "DrGulas_Flickr-77.png",
        "HeyRocker_Flickr-77.jpg",
        "HeyRocker_Flickr-77.png",
        "Matthew_Tosh_Flickr-77.jpg",
        "Matthew_Tosh_Flickr-77.png",
        "Morgan_Solar_Flickr-77.jpg",
        "Morgan_Solar_Flickr-77.png",
        "Tambako_the_Jaguar_2_Flickr-77.jpg",
        "Tambako_the_Jaguar_2_Flickr-77.png",
        "Tambako_the_Jaguar_Flickr-77.jpg",
        "Tambako_the_Jaguar_Flickr-77.png",
        "[cypher]_Flickr-77.jpg",
        "[cypher]_Flickr-77.png",
        "David_Urbanke_Flickr-128.jpg",
        "DrGulas_Flickr-128.jpg",
        "HeyRocker_Flickr-128.jpg",
        "Matthew_Tosh_Flickr-128.jpg",
        "Morgan_Solar_Flickr-128.jpg",
        "Tambako_the_Jaguar_2_Flickr-128.jpg",
        "Tambako_the_Jaguar_Flickr-128.jpg",
        "[cypher]_Flickr-128.jpg",
        "David_Urbanke_Flickr-320.png",
        "DrGulas_Flickr-320.png",
        "HeyRocker_Flickr-320.png",
        "Matthew_Tosh_Flickr-320.png",
        "Morgan_Solar_Flickr-320.png",
        "Tambako_the_Jaguar_2_Flickr-320.png",
        "Tambako_the_Jaguar_Flickr-320.png",
        "[cypher]_Flickr-320.png",
        "David_Urbanke_Flickr-320.jpg",
        "DrGulas_Flickr-320.jpg",
        "HeyRocker_Flickr-320.jpg",
        "Matthew_Tosh_Flickr-320.jpg",
        "Morgan_Solar_Flickr-320.jpg",
        "Tambako_the_Jaguar_2_Flickr-320.jpg",
        "Tambako_the_Jaguar_Flickr-320.jpg",
        "[cypher]_Flickr-320.jpg",
        "David_Urbanke_Flickr-640.jpg",
        "DrGulas_Flickr-640.jpg",
        "HeyRocker_Flickr-640.jpg",
        "HeyRocker_Flickr-orig.jpg",
        "Matthew_Tosh_Flickr-640.jpg",
        "Morgan_Solar_Flickr-640.jpg",
        "Tambako_the_Jaguar_2_Flickr-640.jpg",
        "Tambako_the_Jaguar_Flickr-640.jpg",
        "[cypher]_Flickr-640.jpg",
        "DrGulas_Flickr-orig.jpg",
        "David_Urbanke_Flickr-orig.jpg",
        "Morgan_Solar_Flickr-orig.jpg",
}
local big_images = { -- these are bigger than 1920x1080 by quite a bit in some cases
        "Matthew_Tosh_Flickr-orig.jpg", -- 2000x1264
        "[cypher]_Flickr-orig.jpg", -- 2144x1435
        "Tambako_the_Jaguar_Flickr-orig.jpg", -- 2274x3424
        "Tambako_the_Jaguar_2_Flickr-orig.jpg", -- 4166x2767
    }

local function load_images()
    local overall_time = Stopwatch()
    local individual_time = Stopwatch()
    print("Loading image\twallclock\tcputime\twidth\theight")
    overall_time:start()
    local individual_cpu_start,individual_cpu_stop,overall_cpu_stop
    local overall_cpu_start = os.clock()
    for _,image in pairs(image_list) do
        individual_time:start()
        individual_cpu_start = os.clock()
        local img = Image{src="assets/"..image}
        individual_cpu_stop = os.clock()
        individual_time:stop()
        print(image,individual_time.elapsed,(individual_cpu_stop-individual_cpu_start)*1000,img.w,img.h)
    end
    overall_cpu_stop = os.clock()
    overall_time:stop()
    print("Total time:",overall_time.elapsed,(overall_cpu_stop-overall_cpu_start)*1000)
end

local tv = ( trickplay and trickplay.version ) or "< 0.0.12"

print( "" )
print( "PLEASE NOTE the clutter version (/ver) and whether profiling is enabled (/prof)" )
print( "TRICKPLAY VERSION  : "..tv )
print( "LOTSOFLOADS VERSION  : "..md5( readfile( "main.lua" ) ) )
print( "" )

dolater(load_images)
