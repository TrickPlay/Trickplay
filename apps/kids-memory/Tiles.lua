tile_faces = {}
local tile_container = Group{}
screen:add(tile_container)
tile_container:hide()
for i = 1,4 do
    tile_faces[i]   = {}
end


tile_faces[1].tbl = {
        Rectangle{w=150,h=150,color="FF0000"},
        Rectangle{w=50,h=10,color="0000FF",x=50}
}
tile_faces[1].reset = function(tbl)
    tbl[2].x = 50
end
tile_faces[1].on_new_frame = function(tbl,prog)
    prog = prog*3
    if prog < 1 then
        tbl[2].x = 50*(1-prog)
    elseif prog < 2 then
        tbl[2].x = 50*(prog-1)
    else
        tbl[2].x = 50*(3-prog)
    end
end
tile_faces[1].on_completed = function(tbl)
    dumptable(tbl)
    tbl[2].x = 0
end


tile_faces[2].tbl = {
        Rectangle{w=150,h=150,color="AF00AF"},
        Rectangle{w=100,h=100,color="0000FF",x=50}
}
tile_faces[2].reset = function(tbl)
    tbl[2].x = 50
    tbl[2].y = 0
end
tile_faces[2].on_new_frame = function(tbl,prog)
    prog = prog*4
    if prog < 1 then
        tbl[2].x = 50*(1-prog)
    elseif prog < 2 then
        tbl[2].x = 0
        tbl[2].y = 50*(prog-1)
    elseif prog < 3 then
        tbl[2].x = 50*(prog-2)
        tbl[2].y = 50
    else
        tbl[2].x = 50*(4-prog)
        tbl[2].y = 50
    end
end
tile_faces[2].on_completed = function(tbl)
    dumptable(tbl)
    tbl[2].x = 0
end



tile_faces[3].tbl = {
        Rectangle{w=150,h=150,color="0F0F0F"},
        Rectangle{w=75,h=75,color="0000FF",x=75},
        Rectangle{w=75,h=75,color="0000FF",y=75}
}
tile_faces[3].reset = function(tbl)
    tbl[2].x = 75
    tbl[2].y = 0
    tbl[3].y = 75
    tbl[3].x = 0
end
tile_faces[3].on_new_frame = function(tbl,prog)
    prog = prog*4
    if prog < 1 then
        tbl[2].x = 75*(1-prog)
        tbl[3].x = 75*(prog)
    elseif prog < 2 then
        tbl[2].x = 75*(prog-1)
        tbl[3].x = 75*(2-prog)
    elseif prog < 3 then
        tbl[2].x = 75*(3-prog)
        tbl[3].x = 75*(prog-2)
    else
        tbl[2].x = 75*(prog-3)
        tbl[3].x = 75*(4-prog)
    end
end
tile_faces[3].on_completed = function(tbl)
    dumptable(tbl)
    tbl[2].x = 75
    tbl[2].y = 0
    tbl[3].y = 75
    tbl[3].x = 0
end



tile_faces[4].tbl = {
        Rectangle{w=150,h=150,color="0AFA0A"},
        Rectangle{w=75,h=75,color="0000FF",x=75},
        Rectangle{w=75,h=75,color="0000FF",y=75}
}
tile_faces[4].reset = function(tbl)
    tbl[2].x = 75
    tbl[2].y = 0
    tbl[3].y = 75
    tbl[3].x = 0
end
tile_faces[4].on_new_frame = function(tbl,prog)
    prog = prog*4
    if prog < 1 then
        tbl[2].y = 75*(prog)
        tbl[3].y = 75*(1-prog)
    elseif prog < 2 then
        tbl[2].y = 75*(2-prog)
        tbl[3].y = 75*(prog-1)
    elseif prog < 3 then
        tbl[2].y = 75*(prog-2)
        tbl[3].y = 75*(3-prog)
    else
        tbl[2].y = 75*(4-prog)
        tbl[3].y = 75*(prog-3)
    end
end
tile_faces[4].on_completed = function(tbl)
    dumptable(tbl)
    tbl[2].x = 75
    tbl[2].y = 0
    tbl[3].y = 75
    tbl[3].x = 0
end


for i = 1,4 do
    for j = 1,#tile_faces[i].tbl do
        tile_container:add(tile_faces[i].tbl[j])
    end
end