tile_faces = {}
local tile_container = Group{}
screen:add(tile_container)
tile_container:hide()



tile_faces[1]     = {}
tile_faces[1].tbl = {
        Image{src="assets/critters/monkey_tail.png",x=110,y=20},
        Image{src="assets/critters/monkey_body.png",x=10,y=50},
        Image{src="assets/critters/monkey_feet.png",x=50,y=160},
}
tile_faces[1].reset = function(tbl)
    --tbl[2].x = 50
    tbl[1]:move_anchor_point(0,tbl[1].h)
    tbl[2]:move_anchor_point(tbl[2].w/2,tbl[2].h+50)
    tbl[3]:move_anchor_point(tbl[3].w/2,0)
    tbl[2].z_rotation = {( 5),0,0}
    tbl[1].z_rotation = {(-15),0,0}
end

tile_faces[1].duration = {500,500}
tile_faces[1].stages = {
    function(self,delta,p)
        self.tbl[2].z_rotation = {(-5)*(2*p-1),0,0}
        self.tbl[1].z_rotation = {(-15)*(1-p),0,0}
    end,
    function(self,delta,p)
        self.tbl[2].z_rotation = {( 5)*(2*p-1),0,0}
        self.tbl[1].z_rotation = {(-15)*(p),0,0}
    end,
}



tile_faces[2]   = {}
tile_faces[2].tbl = {
        Image{src="assets/critters/butterfly_wing.png",x=35,y=25, scale={.75,.75}},
        Image{src="assets/critters/butterfly_body.png",x=60,y=120},
        Image{src="assets/critters/butterfly_wing.png",x=20,y=85},
        Image{src="assets/critters/butterfly_head.png",x=110,y=40},
        
}
tile_faces[2].reset = function(tbl)
--[[
    tbl[2].x = 50
    tbl[2].y = 0
    --]]
    tbl[3]:raise_to_top()
    tbl[3]:move_anchor_point(tbl[2].w-10,tbl[2].h/2)
    tbl[1]:move_anchor_point(tbl[1].w,tbl[1].h/2)
    tbl[3].z_rotation = {20,0,0}
    tbl[1].z_rotation = {20,0,0}
end

tile_faces[2].duration = {750,750}
tile_faces[2].stages = {
    function(self,delta,p)
        self.tbl[3].y_rotation = {(-120)*p,0,0}
        self.tbl[1].y_rotation = {( 120)*p,0,0}
        self.g.y = -15*p
    end,
    function(self,delta,p)
        self.tbl[3].y_rotation = {-120*(1-p),0,0}
        self.tbl[1].y_rotation = { 120*(1-p),0,0}
        self.g.y = -15*(1-p)
    end,
}



tile_faces[3]   = {}
tile_faces[3].tbl = {
        Image{src="assets/critters/toucan_body.png", x= 50,y=10},
        Image{src="assets/critters/toucan_beak1.png",x=110,y=80},
        Image{src="assets/critters/toucan_beak2.png",x=130,y=70},
}
tile_faces[3].reset = function(tbl)
    tbl[2]:move_anchor_point(tbl[2].w/2,0)
end

tile_faces[3].duration = {250,250,250,250,1000}
tile_faces[3].stages = {
    function(self,delta,p)
        self.tbl[2].z_rotation = {( 5)*p,0,0}
        self.tbl[3].z_rotation = {(-5)*p,0,0}
    end,
    function(self,delta,p)
        self.tbl[2].z_rotation = { 5*(1-p),0,0}
        self.tbl[3].z_rotation = {-5*(1-p),0,0}
    end,
    function(self,delta,p)
        self.tbl[2].z_rotation = {( 5)*p,0,0}
        self.tbl[3].z_rotation = {(-5)*p,0,0}
    end,
    function(self,delta,p)
        self.tbl[2].z_rotation = { 5*(1-p),0,0}
        self.tbl[3].z_rotation = {-5*(1-p),0,0}
    end,
    function(self,delta,p)
    end,
}

tile_faces[4]   = {}
tile_faces[4].tbl = {
        Image{src="assets/critters/mouse_body.png", x= 60,y=120},
        Image{src="assets/critters/mouse_arm.png",  x=50,y=140},
        Image{src="assets/critters/mouse_head.png", x=20,y=20},
}
tile_faces[4].reset = function(tbl)
    --tbl[3].y = 20
    --tbl[3].x = 20
    tbl[2]:move_anchor_point(20,17)
    --tbl[3]:move_anchor_point(tbl[3].w/2,tbl[3].h-10)

end

tile_faces[4].duration = {200,200,200,200,200,200,2000}
tile_faces[4].stages = {
    function(self,delta,p)
        self.tbl[2].z_rotation = {( -26)*p,0,0}
    end,
    function(self,delta,p)
        self.tbl[2].z_rotation = {-26-(31 -26)*p,0,0}
    end,                    
    function(self,delta,p)  
        self.tbl[2].z_rotation = {-26-(31 -26)*(1-p),0,0}
    end,                    
    function(self,delta,p)  
        self.tbl[2].z_rotation = {-26-(31 -26)*p,0,0}
    end,                    
    function(self,delta,p)  
        self.tbl[2].z_rotation = {-26-(31 -26)*(1-p),0,0}
    end,
    function(self,delta,p)
        self.tbl[2].z_rotation = {( -26)*(1-p),0,0}
    end,
    function(self,delta,p)
    end,
}

tile_faces[5]   = {}
tile_faces[5].tbl = {
        Image{src="assets/critters/squirrel_tail.png", x= 120,y=20},
        Image{src="assets/critters/squirrel_arm.png", x=30,y=130},
        Image{src="assets/critters/squirrel_body.png",  x=30,y=30},
        
        Image{src="assets/critters/squirrel_nut.png", x=0,y=100},
}
tile_faces[5].reset = function(tbl)
    --tbl[3].y = 20
    --tbl[3].x = 20
    tbl[1]:move_anchor_point(0,tbl[1].h)
    tbl[2]:move_anchor_point(65,35)
    tbl[1].z_rotation = { 5,0,0}
    tbl[2].z_rotation = { -12,0,0}
    --tbl[3]:move_anchor_point(tbl[3].w/2,tbl[3].h-10)

end

tile_faces[5].duration = {200,200,200,200}
tile_faces[5].stages = {
    function(self,delta,p)
       self.tbl[1].z_rotation = { 5+(-5-5)*p,0,0}
       self.tbl[2].z_rotation = { -12+(16+12)*p,0,0}
       self.tbl[4].y = 100 + (80-100)*p
       self.tbl[4].x = 5*p
    end,
    function(self,delta,p)
        self.tbl[1].z_rotation = { -5+(-15+5)*p,0,0}
       self.tbl[4].y = 80 + (30-80)*p
    end,
    function(self,delta,p)
        self.tbl[1].z_rotation = { -5+(-15+5)*(1-p),0,0}
       self.tbl[4].y = 80 + (30-80)*(1-p)
    end,
    function(self,delta,p)
        self.tbl[1].z_rotation = { 5+(-5-5)*(1-p),0,0}
       self.tbl[2].z_rotation = { -12+(16+12)*(1-p),0,0}
       self.tbl[4].y = 100 + (80-100)*(1-p)
       self.tbl[4].x = 5*(1-p)
    end,
}
--[[
tile_faces[4]   = {}
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
    tbl[2].x = 75
    tbl[2].y = 0
    tbl[3].y = 75
    tbl[3].x = 0
end
--]]

for i = 1,#tile_faces do
    for j = 1,#tile_faces[i].tbl do
        tile_container:add(tile_faces[i].tbl[j])
    end
end