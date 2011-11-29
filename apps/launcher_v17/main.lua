--[[

screen:show()

function mediaplayer:on_loaded()
    
    mediaplayer:set_viewport_geometry(
        100,100,500,500
    )
    
    mediaplayer:play()
    
end

function mediaplayer:on_end_of_stream()
    
    mediaplayer:seek(0)
    
    mediaplayer:play()
    
end

mediaplayer:load("glee-1.mp4")

--]]

screen:show()

r = Rectangle{color="550000",size = screen.size}

screen:add(r)

do
    
    local l = dofile("localized:strings.lua")
    
    function _L(s) return l[s] or s end
    
end


function make_frame(p)
    
    --text for the title
    local t = Text{text = p.t,font=p.f}
    
    local c = Canvas(p.w+2*p.b,p.r+1+3*p.b+t.h)
    
    c.op = "SOURCE"
    
    --background
    c:round_rectangle(0,0,c.w,c.h,p.r)
    
    c:set_source_color("#ffffff")
    
    c:fill()
    
    --title
    c:move_to(p.r/2,p.b)
    
    c:text_element_path(t)
    
    c:set_source_color("#000000")
    
    c:fill()
    
    --punch a hole
    c:round_rectangle( p.b, 2*p.b + t.h, p.w, p.r+1, p.r )
    
    c:set_source_color("#00000000")
    
    c:fill()
    
    local b = c:Bitmap()
    
    
    --get top piece
    c = Canvas(p.w+2*p.b, 2*p.b + t.h+10)
    
    c:set_source_bitmap(b)
    
    c:paint()
    
    local top = c:Image{name="Frame - Top & Caption"}
    
    
    --get middle slice
    c = Canvas(p.w+2*p.b,1)
    
    c:set_source_bitmap(b,0,-top.h)
    
    c:paint()
    
    local mid = c:Image{name="Frame - Middle Slice"}
    
    
    --get bottom piece
    c = Canvas(p.w+2*p.b, p.b + 10)
    
    c:set_source_bitmap(b,0,-b.h+c.h)
    
    c:paint()
    
    local btm = c:Image{name="Frame - Bottom"}
    
    return top,mid,btm
    
end

local shrunken_h = 100
local expanded_h = 800

function make_video_tile(p)
    
    local top, mid, btm = make_frame{
        w = 430, --inner width
        b = 3,   --border width
        r = 20,  --corner radius
        t = p.t,
        f = "Sans 30px",
    }
    
    mid.y = top.h
    mid.h = shrunken_h
    btm.y = mid.y + mid.h
    
    local contents = Group{
        name = "Clipped Contents",
        y    = top.h - btm.h,
        clip = {3,0,430,shrunken_h+2*btm.h-3},
    }
    
    local r = Rectangle{color="009900",size = screen.size}
    
    contents:add(r)
    
    local g  = Group{
        name = "Video Tile: '"..p.t.."'",
        x = p.x,
        y = p.y,
    }
    
    g:add(contents,top,mid,btm)
    
    return g
    
end


tiles = {}

for i = 1, 4 do
    
    tiles[i] = make_video_tile{
        t = "Caption "..i,
    }
    
end

local spacing = (screen.w - 436*4)/5


for i = 1, 4 do
    
    tiles[i].x = (spacing+436)*(i-1) + spacing
    tiles[i].y =  spacing
end

screen:add(unpack(tiles))






























