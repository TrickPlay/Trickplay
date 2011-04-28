local NUM_CLOUDS = 8
local CLOUD_SPACING = 400
local opacity_interval = Interval(200,0)

local cloud_img = Image { src = "cloud10.png" }
screen:add(cloud_img)
cloud_img:hide()

local make_cloud_layer = function()
    local cloud_group = Group{  }
    local NUM_CLOUDS = 6*math.ceil(screen.w/cloud_img.w)
    for i=1,NUM_CLOUDS do
        local cloud = Clone { source = cloud_img }
        cloud.anchor_point = { cloud.w/2, cloud.h/2 }
        cloud.z_rotation = { math.random(0,360), 0, 0 }
        cloud.y_rotation = { math.random(-30,30), 0, 0 }
        cloud.x = math.random(i*(screen.w*2)/NUM_CLOUDS - screen.w/2 - cloud.w/2, i*(screen.w*2)/NUM_CLOUDS + - screen.w/2 - cloud.w/2)
        local my_random=0
        while(my_random<=0) do my_random = math.random() end
        my_random = -math.log10(my_random)/math.log10(100)
        cloud.y = cloud.h/2 * my_random * (math.random(0,1)-0.5)*2
        cloud.z = math.random(-CLOUD_SPACING/3,CLOUD_SPACING/3)

        cloud_group:add(cloud)
    end
    return cloud_group
end


local all_clouds = Group {position = { 0, 3*screen.h/4 }}
local cloud_track = {}
for i=0,NUM_CLOUDS do
    local new_clouds = make_cloud_layer()
    new_clouds.z = 2.5-i * CLOUD_SPACING
    new_clouds.opacity = opacity_interval:get_value(i/NUM_CLOUDS)
    table.insert(cloud_track,new_clouds)
    all_clouds:add(new_clouds)
    new_clouds:lower_to_bottom()
end

screen:add(Rectangle{size={screen.w,screen.h},color="3090C7"})
screen:add(all_clouds)
screen:show()

local t = Timeline {
                    duration = 1000,
                    loop = true,
                    }
function t:on_new_frame(elapsed, progress)
    for i=0, NUM_CLOUDS do
        cloud_track[i+1].z = (2+progress-i) * CLOUD_SPACING
        if(0 == i) then
            cloud_track[i+1].opacity = opacity_interval:get_value(progress)
        else
            cloud_track[i+1].opacity = opacity_interval:get_value((i-progress)/NUM_CLOUDS)
        end
    end
end

function t:on_completed()
    -- Move cloud from the front to the back of the array
    table.insert(cloud_track, table.remove(cloud_track,1))
    cloud_track[NUM_CLOUDS]:lower_to_bottom()

    -- and reshuffle them
    cloud_track[NUM_CLOUDS]:foreach_child(
                function(cloud)
                    cloud.z_rotation = { math.random(0,360), 0, 0 }
                    local my_random=0
                    while(my_random<=0) do my_random = math.random() end
                    my_random = -math.log10(my_random)/math.log10(100)
                    cloud.y = cloud.h/2 * my_random * (math.random(0,1)-0.5)*2
                    cloud.z = math.random(-CLOUD_SPACING/3,CLOUD_SPACING/3)
                end)
end

t:start()

local target_x,target_y = all_clouds.x, all_clouds.y
local key_handler = function(self,key)
    if(keys.Down == key) then
        target_y = target_y+100
    elseif(keys.Up == key) then
        target_y = target_y-100
    elseif(keys.Left == key) then
        target_x = target_x+100
    elseif(keys.Right == key) then
        target_x = target_x-100
    end
    if(target_x > screen.w/2) then target_x = screen.w/2 end
    if(target_x < -screen.w/2) then target_x = -screen.w/2 end
    if(target_y > 3*screen.h/4) then target_y = 3*screen.h/4 end
    if(target_y < screen.h/4) then target_y = screen.h/4 end
    all_clouds:animate({
                duration=1000,
                x=target_x,
                y=target_y,
                mode="EASE_OUT_SINE"
            })
end
screen.on_key_down = key_handler

local fly_interval = Interval(-250,250)
function controllers:on_controller_connected(controller)
    if(controller.has_accelerometer) then
    	function controller:on_accelerometer(x, y, z)
            target_x = target_x-fly_interval:get_value((x+1)/2)
            target_y = target_y-fly_interval:get_value((y+1)/2)
            if(target_x > screen.w) then target_x = screen.w end
            if(target_x < -screen.w) then target_x = -screen.w end
            if(target_y > 3*screen.h/4) then target_y = 3*screen.h/4 end
            if(target_y < screen.h/4) then target_y = screen.h/4 end

            all_clouds:animate({
                        duration=1000/4,
                        x=target_x,
                        y=target_y,
                    })
    	end

        screen.on_key_down = nil
    	controller:start_accelerometer("L",1/5)
    end

    function controller:on_disconnected()
        target_x=0
        target_y=4*screen.h/5
        all_clouds:animate({
                    duration=4000,
                    x=target_x,
                    y=target_y,
                    mode="EASE_OUT_SINE"
                })
        screen.on_key_down = key_handler
    end
end

local controller
for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end
