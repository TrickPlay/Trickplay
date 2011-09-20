local imgs = {
    billboards = {
        "assets/billboards/billboard1a.png",
        "assets/billboards/billboard2a.png",
        "assets/billboards/billboard3a.png",
        "assets/billboards/billboard4a.png",
    },
    pole = "assets/billboards/pole.png",
    lg = {
        "assets/signs/sign-lg-frame-2.png",
        "assets/signs/sign-lg-2.png",
    },
    sm = {
        "assets/signs/sign-sm-2.png",
        "assets/signs/sign-sm-light-2.png",
    },
    speed = {
        "assets/signs/sign-spd-2.png",
        "assets/signs/sign-spd-light-2.png",
    },
    post = "assets/signs/sign-sm-post-2.png",
    plants = {},
}
local contents = app.contents
for i = 1 , # contents do
    if string.match(  contents[ i ] , "^assets/fauna/" ) then
        table.insert(imgs.plants, contents[ i ] )
    end
end

local Doodads = {listing={}}

local group_upval,clone_upval, dist, dist_from_center
local add_funcs={
--add_billboard =
function(pos)
    
    dist_from_center = -3000
    
    group_upval = Group{x_rotation = {-90,0,0}}
    group_upval.x = pos[1]+dist_from_center*cos(-pos[3])
    group_upval.y = pos[2]+dist_from_center*sin(-pos[3])
    
    clone_upval = Clone{name="pole"}
    clone_upval.scale={3,3}
    clone_upval.source =
        Assets:source_from_src(
            imgs.pole
        )
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    
    
    clone_upval = Clone{name="board",y=-clone_upval.h*clone_upval.scale[2]+20}
    clone_upval.scale={5,5}
    clone_upval.source =
        Assets:source_from_src(
            imgs.billboards[
                math.random(
                    1,
                    #imgs.billboards
                )
            ]
        )
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    
    
    
    group_upval.delete = function(self)
        self:unparent()
        --Idle_Loop:remove_function(self.check)
        Doodads.listing[self] = nil
    end
    
    group_upval.check = function(self)
        dist = self.y - self.parent.anchor_point[2]
        if dist > 0 then
            self:delete()
            Idle_Loop:remove_function(self.check)
        elseif dist > -800 then
            dist = self.x - self.parent.anchor_point[1]
            if math.abs(dist) < 180 then
                Doodads.user_car_ref.v_x = 0
                Doodads.user_car_ref.v_y = 0
                Game_State:change_state_to(STATES.CRASH)
            end
        end
    end
    
    Doodads.listing[group_upval] = group_upval.check
    return group_upval
end,
--add_lg_sign =
function(pos)
    
    dist_from_center = 1500
    group_upval = Group{x_rotation = {-90,0,0}}
    group_upval.x = pos[1]+dist_from_center*cos(-pos[3])
    group_upval.y = pos[2]+dist_from_center*sin(-pos[3])
    
    clone_upval = Clone{name="pole"}
    clone_upval.scale={3,3}
    clone_upval.source =
        Assets:source_from_src(
            imgs.pole
        )
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    group_upval:add(clone_upval)
    
    
    
    clone_upval = Clone{name="board",y=-clone_upval.h*clone_upval.scale[2]+20}
    clone_upval.scale={4,4}
    clone_upval.source =
        Assets:source_from_src(
            imgs.lg[2]
        )
    clone_upval.anchor_point = {282,15}
    group_upval:add(clone_upval)
    
    clone_upval = Clone{name="frame",x=75,y=clone_upval.y+40,z=-10000}
    clone_upval.scale={4,4}
    clone_upval.source =
        Assets:source_from_src(
            imgs.lg[1]
        )
    clone_upval.anchor_point = {282,15}
    group_upval:add(clone_upval)
    clone_upval:lower_to_bottom()
    
    clone_upval = Text{
        font  = "DejaVu Sans Bold 20px",
        text  = "Las Vegas\nThis Way",
        alignment = "CENTER",
        color = "ffffff",
        scale = {4,4},
        x     = -group_upval:find_child("board").w*group_upval:find_child("board").scale[1] + 200,
        y     = group_upval:find_child("board").y   
    }
    group_upval:add(clone_upval)
    
    group_upval.delete = function(self)
        self:unparent()
        --Idle_Loop:remove_function(self.check)
        Doodads.listing[self] = nil
    end
    
    group_upval.check = function(self)
        dist = self.y - self.parent.anchor_point[2]
        if dist > 0 then
            self:delete()
            Idle_Loop:remove_function(self.check)
        elseif dist > -800 then
            dist = self.x - self.parent.anchor_point[1]
            if math.abs(dist) < 180 then
                Doodads.user_car_ref.v_x = 0
                Doodads.user_car_ref.v_y = 0
                Game_State:change_state_to(STATES.CRASH)
            end
        end
    end
    
    Doodads.listing[group_upval] = group_upval.check
    return group_upval
end,
--add_sm_sign =
function(pos)
    
    dist_from_center = 2000
    
    group_upval = Group{x_rotation = {-90,0,0}}
    group_upval.x = pos[1]+dist_from_center*cos(-pos[3])
    group_upval.y = pos[2]+dist_from_center*sin(-pos[3])
    group_upval.delete = function(self)
        self:unparent()
        --Idle_Loop:remove_function(self.check)
        Doodads.listing[self] = nil
    end
    
    
    clone_upval = Clone{name="left pole"}
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.post)
    clone_upval.anchor_point = {clone_upval.source.w/2+60,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    clone_upval = Clone{name="right pole"}
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.post)
    clone_upval.anchor_point = {clone_upval.source.w/2-60,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    clone_upval = Clone{name="dark",y = -clone_upval.h*clone_upval.scale[2]+20 }
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.sm[1])
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    clone_upval = Clone{name="light",y = clone_upval.y}
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.sm[2])
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    clone_upval.opacity=0
    
    group_upval:add(clone_upval)
    
    clone_upval = Text{
        font  = "DejaVu Sans Bold 30px",
        text  = "Las Vegas\nThis Way",
        alignment = "CENTER",
        color = "ffffff",
        scale = {4,4},
        x     = -clone_upval.w*clone_upval.scale[1]/2 + 50,
        y     = clone_upval.y-clone_upval.h*clone_upval.scale[2]   + 30
    }
    
    group_upval:add(clone_upval)
    
    group_upval.check = function(self)
        dist = self.y - self.parent.anchor_point[2]
        if dist > 0 then
            self:delete()
            Idle_Loop:remove_function(self.check)
        elseif dist > -800 then
            self:find_child("light").opacity = 0
            dist = self.x - self.parent.anchor_point[1]
            if math.abs(dist) < 350 then
                Doodads.user_car_ref.v_x = 0
                Doodads.user_car_ref.v_y = 0
                Game_State:change_state_to(STATES.CRASH)
            end
        elseif dist > -20000 then
            self:find_child("light").opacity = 255*(20000+dist)/20000
        end
    end
    Doodads.listing[group_upval] = group_upval.check
    return group_upval
end,
--add_speed_sign =
function(pos)
    
    dist_from_center = 1500
    
    group_upval = Group{x_rotation = {-90,0,0}}
    group_upval.x = pos[1]+dist_from_center*cos(-pos[3])
    group_upval.y = pos[2]+dist_from_center*sin(-pos[3])
    group_upval.delete = function(self)
        self:unparent()
        --Idle_Loop:remove_function(self.check)
        Doodads.listing[self] = nil
    end
    
    
    clone_upval = Clone{name="pole"}
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.post)
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    clone_upval = Clone{name="dark",y = -clone_upval.h*clone_upval.scale[2]+100 }
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.speed[1])
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    
    group_upval:add(clone_upval)
    
    clone_upval = Clone{name="light",y = clone_upval.y}
    clone_upval.scale={4,4}
    clone_upval.source = Assets:source_from_src(imgs.speed[2])
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    clone_upval.opacity=0
    
    group_upval:add(clone_upval)
    
    
    group_upval.check = function(self)
        dist = self.y - self.parent.anchor_point[2]
        if dist > 0 then
            self:delete()
            Idle_Loop:remove_function(self.check)
        elseif  dist > -800 then
            self:find_child("light").opacity = 0
            dist = self.x - self.parent.anchor_point[1]
            if math.abs(dist) < 150 then
                Doodads.user_car_ref.v_x = 0
                Doodads.user_car_ref.v_y = 0
                Game_State:change_state_to(STATES.CRASH)
            end
        elseif dist > -20000 then
            self:find_child("light").opacity = 255*(20000+dist)/20000
        end
    end
    Doodads.listing[group_upval] = group_upval.check
    return group_upval
end
}

Doodads.random = function(self,pos)
    return add_funcs[math.random(1,#add_funcs)](pos)
end

Doodads.random_plant = function(self,pos)
    
    dist_from_center = (1500+5000*math.random())*(2*math.random(1,2)-3)
    
    group_upval = Group{x_rotation = {-90,0,0}}
    group_upval.x = pos[1]+dist_from_center*cos(-pos[3])
    group_upval.y = pos[2]+dist_from_center*sin(-pos[3])
    group_upval.delete = function(self)
        self:unparent()
        --Idle_Loop:remove_function(self.check)
        print("deleting",self)
        Doodads.listing[self] = nil
    end
    
    clone_upval = Clone{name="plant"}
    clone_upval.scale={2,2}

    clone_upval.source =
        Assets:source_from_src(
            imgs.plants[
                math.random(
                    1,
                    #imgs.plants
                )
            ]
        )
    
    clone_upval.anchor_point = {clone_upval.source.w/2,clone_upval.source.h}
    
    group_upval.check = function(self)
        if self.parent == nil then
            print(self)
        end
        dist = self.y - self.parent.anchor_point[2]
        if dist > 0 then
            self:delete()
            Idle_Loop:remove_function(self.check)
        elseif  dist > -800 then
            dist = self.x - self.parent.anchor_point[1]
            if math.abs(dist) < 150 then
                Doodads.user_car_ref.v_x = 0
                Doodads.user_car_ref.v_y = 0
                print("dd")
                Game_State:change_state_to(STATES.CRASH)
            end
        end
    end
    group_upval:add(clone_upval)
    Doodads.listing[group_upval] = group_upval.check
    return group_upval
end

Game_State:add_state_change_function(
    function(old_state,new_state)
        for doodad,_ in pairs(Doodads.listing) do
            doodad:delete()
        end
    end,
    STATES.CRASH,
    STATES.PLAYING
)
Game_State:add_state_change_function(
    function(old_state,new_state)
        for doodad,doodad_c in pairs(Doodads.listing) do
            print("removed func",doodad)
            Idle_Loop:remove_function(doodad_c)
        end
    end,
    STATES.PLAYING,
    STATES.CRASH
)
return Doodads