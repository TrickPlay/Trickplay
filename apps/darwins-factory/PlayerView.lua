PlayerViewConstants = {
    player_src = {
     "img/player_1.png",
     "img/player_2.png",
     "img/player_3.png",
     "img/player_4.png"
    },
    player_height = 100,
    player_width  = 100,
    health_src = { 
     "img/playerstatus/player1_crop.png",
     "img/playerstatus/player2_crop.png",
     "img/playerstatus/player3_crop.png",
     "img/playerstatus/player4_crop.png"
    },

    heart_src  = { 
     "img/playerstatus/player1_heartmonitor_alive.png",
     "img/playerstatus/player2_heartmonitor_alive.png",
     "img/playerstatus/player3_heartmonitor_alive.png",
     "img/playerstatus/player4_heartmonitor_alive.png"
    },

    heart_dead_src  = { 
     "img/playerstatus/player1_heartmonitor_dead.png",
     "img/playerstatus/player2_heartmonitor_dead.png",
     "img/playerstatus/player3_heartmonitor_dead.png",
     "img/playerstatus/player4_heartmonitor_dead.png"
    },

    health_bubble = {
     "img/gradient/new/player1_health_bubble.png",
     "img/gradient/new/player2_health_bubble.png",
     "img/gradient/new/player3_health_bubble.png",
     "img/gradient/new/player4_health_bubble.png"
    },

    health_gradient = {
     "img/gradient/player1_grad_crop.png",
     "img/gradient/player2_grad_crop.png",
     "img/gradient/player3_grad_crop.png",
     "img/gradient/player4_grad_crop.png"
    },

    window_width  = 350,
    window_height = 270,
    window_padding = 75,
    gradient_width = 450,

    default_health = 100
}

Heartbeat = class(function(self, player, parent_group)
    self.image_src = PlayerViewConstants.heart_src[player]
    self.image_dead_src = PlayerViewConstants.heart_dead_src[player]
    self.image_queue = {}
    self.health = PlayerViewConstants.default_health
    self.group = parent_group
    self.beat_countdown = 0
end)

--[=[
    Look at `health` property to determine size of heartbeat
--]=]
function Heartbeat:calculateWidth()
    local width = self.group.width/(PlayerViewConstants.default_health/self.health)
    return width
end

function Heartbeat:beat()
    local image = self.health == 0 and self.image_dead_src or self.image_src
    if self.beat_countdown <= 0 then
        local width = self.health == 0 and self.group.width or self:calculateWidth() 
        local new_beat_image = Images:load(image, {
            x = self.group.width,
            width = width
        })
        self.image_queue[#self.image_queue+1] = new_beat_image
        self.group:add(new_beat_image)
        self.beat_countdown = new_beat_image.width
    end
    return self.beat_countdown
end

function Heartbeat:moveBeats(delta)
    for i,image in ipairs(self.image_queue) do
        image.x = image.x - delta
        if image.x <= 0 then
            self.image_queue[i]  = nil
            self.group:remove(image)
        end
    end
    self.beat_countdown = self.beat_countdown - delta
end

HeartbeatFactory = class(function(self)
    self.heartbeats = {}
    self.consumer = Timeline{
        duration = 10,
        loop = true,
        on_new_frame = function(timeline, elapsed, progress) self:heartConsumer(timeline, elapsed, progress) end
    }
    self.producer = Timer{
        interval = 1,
        on_timer = function(timer) self:heartProducer() end
    }
    self.consumer:start()
    self.producer:start()
end)

function HeartbeatFactory:destroy()
    self.consumer:stop()
    self.producer:stop()
end

function HeartbeatFactory:makeHeartbeat(player, parent_group)
    local player_heartbeat = Heartbeat(player, parent_group)
    self.heartbeats[#self.heartbeats+1] = player_heartbeat
    return player_heartbeat
end

function HeartbeatFactory:heartProducer()
    print("PRODUCING HEARTS")
    local min_duration = 1
    for i,heartbeat in ipairs(self.heartbeats) do
        min_duration = math.min(heartbeat:beat(), min_duration)
    end 
    self.producer.interval = min_duration
end

function HeartbeatFactory:heartConsumer(timeline, elapsed, progress)
    local delta = timeline.delta
    for i,heartbeat in ipairs(self.heartbeats) do
        heartbeat:moveBeats(delta)
    end
end

HeartbeatFactory = HeartbeatFactory()

PlayerView=class(function(self, player, player_layer, health_parent_group)
    assert(player, "no player number for PlayerView constructor")
    assert(player, "no player_layer for PlayerView constructor")
    assert(player, "no health_parent_group for PlayerView constructor")

    self.player = player

    -- add player image and keyboard
    self.player_src = PlayerViewConstants.player_src[self.player]

    -- deal with heartbeat / health status
    self.player_layer = player_layer

    self.health_group = Group()

    self.health_group.width  = PlayerViewConstants.window_width
    self.health_group.height = PlayerViewConstants.window_height

    -- clip heart beat action potential
    self.health_group.clip = {20, 20, self.health_group.width-53, self.health_group.height}

    health_parent_group:add(self.health_group)

    -- attempt to center health windows, but provide spacing

    self.health_group.x = (self.player-1)*self.health_group.width 
                        + (self.player-1)*PlayerViewConstants.window_padding

    self.health_image = Images:load(PlayerViewConstants.health_src[self.player])

    self.health_group:add(self.health_image)

    -- add heart beat
    self.heartbeat = HeartbeatFactory:makeHeartbeat(player, self.health_group)

    self.health_bubble = 
                    Images:load(PlayerViewConstants.health_bubble[self.player])
    self.health_group:add(self.health_bubble)

    -- add health gradient
    self.health_gradient =
                    Images:load(PlayerViewConstants.health_gradient[self.player])
    self.health_gradient.y = self.health_image.height
    self.health_gradient.x = 30
    self.health_gradient.width = PlayerViewConstants.gradient_width
    self.health_group:add(self.health_gradient)

    self.health_bubble.y = self.health_image.height

    -- add health text
    self.health_text = Text{ font = "Sans 28px", color = "FFFFFF", text = "100%" }
    self.health_text_shadow = Text{ font = "Sans 29px", color = "000000", text = "100%" }

    local shadow_distance = 1
    local text_offset = (self.health_bubble.width - self.health_text.width)/2

    self.health_text.x = text_offset
    self.health_text_shadow.x = shadow_distance + text_offset

    self.health_text_shadow.z = 2
    self.health_text.z = 3

    self.health_text.y = self.health_image.height + 2
    self.health_text_shadow.y = self.health_image.height + shadow_distance + 2

    self.health_group:add(self.health_text)
    self.health_group:add(self.health_text_shadow)

    self:setHealth(PlayerViewConstants.default_health)
   
end)

function PlayerView:setHealth(health)
    health = Utils.clamp(0, health, PlayerViewConstants.default_health)
    self.heartbeat.health = health

    local gradient_width = health * (PlayerViewConstants.gradient_width/PlayerViewConstants.default_health)
    self.health_gradient.width = gradient_width
    local health_percent = math.ceil(100*health / PlayerViewConstants.default_health)
       
    self.health_text.text = health_percent .. "%"
    self.health_text_shadow.text = health_percent .. "%"
end

function PlayerView:drawPlayer(row, col)
    if self.player_image then
        self.player_layer.group:remove(self.player_image)
    else
        self.player_image = self.player_layer:insert(self.player_src, row, col, {
            width  = BoardViewConstants.player_width,
            height = BoardViewConstants.player_height
        })
    end
end

function PlayerView:movePlayer(old_row, old_col, new_row, new_col)
    if self.player_image then
        -- clear previous guy
        self.player_layer.group:remove(self.player_image)
    end
    self.player_image = self.player_layer:insert(self.player_src, new_row, new_col)
--[=[
    local from_x, from_y, from_image = self.player_layer:calculateXY(self.player_src, old_row, old_col)
    local to_x, to_y, to_image = self.player_layer:calculateXY(self.player_src, old_row, old_col)
--]=]
end
