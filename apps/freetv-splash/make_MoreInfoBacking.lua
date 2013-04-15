make_MoreInfoBacking = function(p)

local backing = Group()


local set_incoming_show, set_current_show, hide_current_show

do
    local r = Rectangle{color="black",w=screen.w,opacity=155}
    backing:add(r)
    backing.extra.anim = AnimationState {
                            duration = 250,
                            mode = "EASE_OUT_SINE",
                            transitions = {
                                {
                                    source = "*",
                                    target = "hidden",
                                    keys = {
                                        { r, "y", p.expanded_h },
                                        { r, "h",            0 },
                                    },
                                },
                                {
                                    source = "*",
                                    target = "full",
                                    keys = {
                                        { r, "y",            0 },
                                        { r, "h", p.expanded_h },
                                    },
                                },
                            },
    }---[[
    function backing.extra.anim.timeline.on_started()
        if backing.extra.anim.state ~= "full" then
            backing:hide_current()
        end
    end
    function backing.extra.anim.timeline.on_completed()
        if backing.extra.anim.state == "full" then
            backing:set_incoming(
                p.get_current(),
                "right"
            )
        end
    end
    --]]
end

do
    local duration = 200
    --[[
    local text_w = 800
    local duration = 200
    local max_airings = 5
    --]]
    local setup_info = function()--g)
        local g = p.create_more_info()

        local curr_meta
        function g:get_meta()
            return curr_meta
        end
        function g:set_meta(meta)
            if meta == nil then error("Received nil",2) end

            curr_meta = meta

            p.populate(g,meta)
        end
        return g
    end

    local   incoming = setup_info()-- Group{ name=   "incoming_show", opacity = 0 } )
    local displaying = setup_info()-- Group{ name= "displaying_show", opacity = 0,
        --x = 200 } )
    incoming.opacity = 0
    displaying.opacity = 0
    displaying.x = p.info_x

    local next_incoming_data
    local animating = false

    function backing:set_incoming(incoming_data,direction)

        if incoming_data == nil then error("nil show",2) end

        if animating then
            next_incoming_data = {incoming_data,direction}
            return
        end
        animating = true

        incoming:set_meta(incoming_data)

        if direction == "left" then
            incoming.x = displaying.x - screen_w
            displaying:animate{
                duration = duration,
                x        = displaying.x + screen.w,
                opacity  = 0,
            }
        elseif direction == "right" then
            incoming.x = displaying.x + screen_w
            displaying:animate{
                duration = duration,
                x        = displaying.x - screen_w,
                opacity  = 0,
            }
        else
            error("Direction must equal 'left' or 'right' . Received "..
                tostring(direction),2)
        end
        incoming:animate{
            duration = duration,
            x = displaying.x,
            opacity = 255,
            on_completed = function()
                incoming.opacity = 0
                displaying:stop_animation()
                displaying.x = incoming.x
                displaying:set_meta(incoming:get_meta() or p.empty_info)
                displaying.opacity = 255
                animating = false
            end
        }
    end

    function backing:hide_current()

        displaying:animate{
            duration=200,
            opacity=0,
            y=displaying.y+p.expanded_h,
            on_completed = function()
                displaying.y = displaying.y -p.expanded_h
            end
        }
    end
    function backing:set_current(curr)
        displaying:set_meta(curr)
    end
    backing:add(displaying,incoming)

end
return backing
end
