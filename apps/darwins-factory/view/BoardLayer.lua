BoardLayerConstants = {
    duration = 200,
    grid_width  = 100,
    grid_height = 100
}

BoardLayer = class(function(self, rotation_duration)
    assert(rotation_duration > 1, "BoardLayer requires duration, " .. rotation_duration .. " too small")
    self._rotation_duration = rotation_duration
    self.num_rotations = 0

    self._rotate_timeline = Timeline{
        duration = self._rotation_duration
    }

    self.rotate_timeline_start = {}
    self.rotate_timeline_newframe = {}
    self.rotate_timeline_callbacks = {}

end)

function BoardLayer:rotateRows(...)
    local passed_args = {...}
    local has_args = #passed_args ~= 0
    self.num_rotations = self.num_rotations + 1

    --- on start
    for i,v in pairs(self.rotate_timeline_start) do
        if has_args then
            v(unpack(passed_args))
        else v() end
    end

    -- while rotating
    self._rotate_timeline.on_new_frame = function(timeline, elapsed, progress)
        for i,v in pairs(self.rotate_timeline_newframe) do
            if has_args then
                v(timeline, elapsed, progress, unpack(passed_args))
            else
                v(timeline, elapsed, progress)
            end
        end
    end

    -- on complete
    self._rotate_timeline.on_completed = function(timeline)
        for i,v in pairs(self.rotate_timeline_callbacks) do
            if has_args then
                v(timeline, unpack(passed_args))
            else v(timeline) end
        end
    end

    self._rotate_timeline:start()
end
