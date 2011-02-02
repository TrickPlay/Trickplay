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
do
    local arm_start = -12
    local arm_end   =  16
    local tail_start = 5
    local tail_end   = -15
    local tail_mid   = (tail_end - tail_start)/2
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
        tbl[2].z_rotation = { arm_start,0,0}
    end
    
    tile_faces[5].duration = {200,200,200,200}
    tile_faces[5].stages = {
        function(self,delta,p)
            self.tbl[1].z_rotation = { tail_start+(-5-tail_start)*p,0,0}
            self.tbl[2].z_rotation = { arm_start+(arm_end-arm_start)*p,0,0}
            self.tbl[4].y = 100 + (80-100)*p
            self.tbl[4].x = 5*p
        end,
        function(self,delta,p)
            self.tbl[1].z_rotation = { tail_mid+(tail_end-tail_mid)*p,0,0}
            self.tbl[4].y = 80 + (30-80)*p
        end,
        function(self,delta,p)
            self.tbl[1].z_rotation = { tail_mid+(tail_end-tail_mid)*(1-p),0,0}
            self.tbl[4].y = 80 + (30-80)*(1-p)
        end,
        function(self,delta,p)
            self.tbl[1].z_rotation = { tail_start+(-5-tail_start)*(1-p),0,0}
            self.tbl[2].z_rotation = { arm_start+(arm_end-arm_start)*(1-p),0,0}
            self.tbl[4].y = 100 + (80-100)*(1-p)
            self.tbl[4].x = 5*(1-p)
        end,
    }
end
do
    local dip = 7
    local angle_max = 3
    tile_faces[6]   = {}
    tile_faces[6].tbl = {
        Image{src="assets/critters/duck_water2.png",y=tile_size-64-20, w=2*tile_size-75, tile={true,false}},
        Image{src="assets/critters/duck.png",y=dip},
        Image{src="assets/critters/duck_water1.png",y=tile_size-64-20, w=2*tile_size-75, tile={true,false} },
        Image{src="assets/critters/duck_water3.png",y=tile_size-64,x=1},
    }
    tile_faces[6].clip = true
    tile_faces[6].reset = function(tbl)
        tbl[2]:move_anchor_point(tbl[2].w/2,tbl[2].h/2)
        tbl[2].z_rotation = {-angle_max,0,0}
    end
    
    tile_faces[6].duration = {2000,2000}
    tile_faces[6].stages = {
        function(self,delta,p)
            self.tbl[1].x = -(self.tbl[1].w-tile_size)*p
            self.tbl[3].x = -(self.tbl[3].w-tile_size)*p
            p = 2*p
            if p < 1 then
                self.tbl[2].y = self.tbl[2].h/2+dip*(1-p)
                self.tbl[2].z_rotation = {-angle_max*(1-p),0,0}
            else
                p = p-1
                self.tbl[2].y = self.tbl[2].h/2+dip*(p)
                self.tbl[2].z_rotation = {angle_max*p,0,0}
            end
            
        end,
        function(self,delta,p)
            self.tbl[1].x = -(self.tbl[1].w-tile_size)*(p)
            self.tbl[3].x = -(self.tbl[3].w-tile_size)*(p)
            p = 2*p
            if p < 1 then
                self.tbl[2].y = self.tbl[2].h/2+dip*(1-p)
                self.tbl[2].z_rotation = {angle_max*(1-p),0,0}
            else
                p = p - 1
                self.tbl[2].y = self.tbl[2].h/2+dip*(p)
                self.tbl[2].z_rotation = {-angle_max*p,0,0}
            end
            
        end,
    }
end
for i = 1,#tile_faces do
    for j = 1,#tile_faces[i].tbl do
        tile_container:add(tile_faces[i].tbl[j])
    end
end