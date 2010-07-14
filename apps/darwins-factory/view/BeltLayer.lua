BeltLayerConstants = {
    belt_src          = "img/conveyor_belt/conveyor_bgtexture.png",
    belt_shadow_src   = "img/conveyor_belt/conveyor_bottomshadow.png",
    shadow_z = 2
}

BeltLayer = class(BoardLayer, function(self, parent_group, group_properties)

    local BLC = BeltLayerConstants

    assert(parent_group, "no parent group to BeltLayer!")
    assert(group_properties and group_properties.width,
           "no width for beltlayer")
    assert(group_properties and group_properties.height,
           "no height for beltlayer")

    BoardLayer.init(self, BoardLayerConstants.duration)

    self.rotate_timeline_newframe = {
        function(...) self:animateBackground(...) end
    }

    self.image_src = BLC.belt_src
    self.image = Images:load(self.image_src)

    local image_scale = self.image.width / group_properties.width
    self.belt_fudge = 30 * image_scale

    self.image_width  = group_properties.width
    self.image_height = self.image.height * image_scale

    self.num_images = math.ceil(group_properties.height / self.image_height)

    self.shadow_src = BLC.belt_shadow_src

    self.shadow_image_bottom = Images:load(self.shadow_src, group_properties)
    self.shadow_image_bottom.width  = self.image_width-10
    self.shadow_image_bottom.height = self.image_height
    self.shadow_image_bottom.z = BLC.shadow_z
    self.shadow_image_bottom.y = group_properties.height - self.shadow_image_bottom.height + 90

    self.shadow_image_top = Images:load(self.shadow_src, group_properties)
    self.shadow_image_top.width  = self.image_width-10
    self.shadow_image_top.height = self.image_height
    self.shadow_image_top.z = BLC.shadow_z
    self.shadow_image_top.y = - self.shadow_image_top.height + 95

    parent_group:add(self.shadow_image_bottom)
    parent_group:add(self.shadow_image_top)
    
    self.start_index = 0
    self.end_index = self.num_images

    self.images = {}

    assert(parent_group.width > group_properties.width, 
           "parent width must be greater than child width!")

    local properties = {
        --x = (parent_group.width - group_properties.width)/2
    }

    Utils.mixin(properties, group_properties) 
    properties.clip = {0, 0, group_properties.width, group_properties.height}
    self.group = Group(properties)

    -- calculate amount of movement per ms
    local speed = BoardLayerConstants.grid_height/BoardLayerConstants.duration
    self.shift_per_ms = speed


    for i=self.end_index,self.start_index,-1 do
        local image = self:addImage(i)
        self.images[i] = image
    end

    parent_group:add(self.group)
end)

function BeltLayer:calculateY(position)
    local belt_position = position or 0
    return (self.image_height - self.belt_fudge) * (belt_position - 1)
end

function BeltLayer:addImage(belt_position)
    local image = Images:load(self.image_src, {
          width  = self.image_width,
          height = self.image_height,
          y = self:calculateY(belt_position)
     })
     self.group:add(image)
     return image
end

function BeltLayer:animateBackground(timeline, elapsed, progress)

    local images = self.images

    -- add new belts
    local first_image = images[self.start_index]

    if first_image.y >= 0 then
        local image = self:addImage()
        self.start_index = self.start_index - 1
        images[self.start_index] = image
    end

    -- shift all belts down

    local shift_amount = timeline.delta * self.shift_per_ms
    for i=self.start_index, self.end_index do
        local image = images[i]
        image.y = image.y + shift_amount
    end

    -- remove old belts
    local last_image = images[self.end_index]
    if last_image.y >= self.group.height then
        last_image:unparent()
        images[self.end_index] = nil
        self.end_index = self.end_index - 1
    end

end
