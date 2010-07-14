PlayerViewConstants = {
    x = 185,
    y = 830,
    z = 1,

    id_src = { 
     "img/factorylicense/2.0/roboy_license_cropped.png",
     "img/factorylicense/2.0/barney_license_cropped.png",
     "img/factorylicense/2.0/ave_license_cropped.png",
     "img/factorylicense/2.0/e-wall_license_cropped.png"
    },

    dead_id_src = {
     "img/factorylicense/2.0/roboy_license_deceased.png",
     "img/factorylicense/2.0/barney_license_deceased.png",
     "img/factorylicense/2.0/ave_license_deceased.png",
     "img/factorylicense/2.0/e-wall_license_deceased.png"
    },

    id_width  = 380,
    id_height = 240,
    id_padding = 30,

    beat_src = "img/factorylicense/heart_monitor.png",
    beat_dead_src = "img/factorylicense/heart_monitor_dead.png",
    beat_height = 80,
    beat_width = 112,
    beat_x = 245,
    beat_y = 45,

    heart_src = "img/factorylicense/fillheart.png",
    heart_width  =  55,
    heart_height =  65,
    heart_positions = {
        {105, 72}, {143, 72}, {184, 72},
            {123, 110},  {163, 107}
    },

    shield_src = "img/powerups/100x100/powerups_heart_shield.png",

    default_health = 100,
    -- heartbeat specific constants
    -- how long it takes a heartbeat to propagate across window
    heartbeat_duration = 3,
    -- how many frames per second to render heartbeat motion
    heartbeat_fps = 30
}

Heartbeat = class(function(self, player, parent_group)
    self.image_src = PlayerViewConstants.beat_src
    self.image_dead_src = PlayerViewConstants.beat_dead_src
    self.image_width = parent_group.width
    self.image_queue = {}
    self.first_index = 1
    self.last_index  = 0
    self.health = PlayerViewConstants.default_health
    self.group = parent_group
    
    -- overlap heartbeats by 5 to remove little gap due to timer
    self.fudge_distance = 6
end)

--[=[
    Look at `health` property to determine size of heartbeat
--]=]
function Heartbeat:calculateWidth()
    local health_ratio = self.health/PlayerViewConstants.default_health
    local width = self.image_width * math.pow(health_ratio, .2)
    return width
end

function Heartbeat:moveBeats(delta)

    local PVC = PlayerViewConstants

    -- create a new beat
    local last_beat = self.image_queue[self.last_index]
    if not last_beat or (last_beat.x + last_beat.width-self.fudge_distance) <= self.group.width then
        local image_src, width
        -- show flatline when dead
        if self.health == 0 then
            image_src = self.image_dead_src
            width = self.group.width
        else
            image_src = self.image_src
            width = self:calculateWidth()
        end
        local new_beat_image = Images:load(image_src, {
            height = PVC.beat_height,
            x = self.group.width,
            width = width
        })
        self.last_index = self.last_index + 1
        self.image_queue[self.last_index] = new_beat_image
        self.group:add(new_beat_image)
    end

    -- move all beats
    for i=self.first_index,self.last_index do
        local image = self.image_queue[i]
        local difference = delta*(self.group.width/PlayerViewConstants.heartbeat_duration)
        image.x = image.x - difference 
    end

    local first_image = self.image_queue[self.first_index]
    
    -- remove hidden beats
    if first_image.x + first_image.width <= 0 then
        self.image_queue[self.first_index]  = nil
        self.first_index = self.first_index + 1
        self.group:remove(first_image)
    end
    
end

HeartbeatFactory = class(function(self)
    self.heartbeats = {}
    local timer = Timer()
    self.timer =  timer
    timer.interval = 1/PlayerViewConstants.heartbeat_fps
    timer.on_timer = function(timer)
        for i,heartbeat in ipairs(self.heartbeats) do
            heartbeat:moveBeats(timer.interval)
        end
    end
    timer:start()
end)

function HeartbeatFactory:destroy()
    self.timer:stop()
end

function HeartbeatFactory:makeHeartbeat(player, parent_group)
    local player_heartbeat = Heartbeat(player, parent_group)
    self.heartbeats[#self.heartbeats+1] = player_heartbeat
    return player_heartbeat
end

HeartbeatFactory = HeartbeatFactory()

PlayerView=class(function(self, player, player_layer, health_parent_group)
    assert(player, "no player number for PlayerView constructor")
    assert(player, "no player_layer for PlayerView constructor")
    assert(player, "no health_parent_group for PlayerView constructor")

    local PVC = PlayerViewConstants

    self.player = player

    self.group = Group{
        x = PVC.x + (self.player-1) * PVC.id_width + (self.player-1) * PVC.id_padding,
        y = PVC.y,
        z = PVC.z,
        width  = PVC.id_width,
        height = PVC.id_height
    }

    self.beat_group = Group{
        width  = PVC.beat_width,
        height = PVC.beat_height,
        x = PVC.beat_x,
        y = PVC.beat_y,
        z = 1
    }
    
    -- clip heart beat action potential
    self.beat_group.clip = {0, 0, self.beat_group.width, self.beat_group.height}

    self.group:add(self.beat_group)

    self.id_image = Images:load(PVC.id_src[self.player],{
        width  = PVC.id_width,
        height = PVC.id_height
    })

    self.dead_id_image = Images:load(PVC.dead_id_src[self.player], {
        width  = PVC.id_width,
        height = PVC.id_height,
        y_rotation = {180, PVC.id_width/2, 0},
        opacity = 0
    })

    self.group:add(self.id_image)
    self.group:add(self.dead_id_image)

    -- add heart beat
    self.heartbeat = HeartbeatFactory:makeHeartbeat(player, self.beat_group)

    -- add hearts
    self.hearts  = {}
    self.shields = {}
    for i,pos in ipairs(PVC.heart_positions) do

        local properties = {
             width  = PVC.heart_width, 
             height = PVC.heart_height,
             x = pos[1],
             y = pos[2]
        }

        local image = Images:load(PVC.heart_src, properties)
        local shield_image = Images:load(PVC.shield_src, properties)
        self.hearts[i] = image
        self.shields[i] = shield_image
        self.group:add(image)
        self.group:add(shield_image)
        image:hide()
        shield_image:hide()
    end

    self:setHealth(PVC.default_health)
    
    health_parent_group:add(self.group)
end)

function PlayerView:setHealth(health)

    health = Utils.clamp(0, health, PlayerViewConstants.default_health)
    self.heartbeat.health = health
    local num_hearts = math.floor(health/20)

    for i=1,5 do
        if i <= num_hearts then
            self.hearts[i]:show()
        else
            self.hearts[i]:hide()
        end
    end
end

function PlayerView:setShield(number_of_shields)
    for i=1,5 do
        if i <= number_of_shields then
            self.shields[i]:show()
        else
            self.shields[i]:hide()
        end
    end
end

function PlayerView:flipID()
    local flip_duration = 1200

    local group = self.group
    local group_width = group.width

    local timeline = Timeline{
        duration = flip_duration,
        on_new_frame = function (timeline, elapsed, progress)
            self.dead_id_image.opacity = 255*progress
            self.id_image.opacity = 255*(1-progress)
            group.y_rotation =  {180*progress, group_width/2, 0}
        end
    }:start()
end
