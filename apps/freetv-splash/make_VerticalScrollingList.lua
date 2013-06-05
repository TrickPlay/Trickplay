local dur = 200
make_windowed_list = function(p)

    local instance      = Group {}
    local clip_contents = Group {}
    local entries = {}

    local sel_i   = 1

    ---------------------------------------------------------------
    for i,v in ipairs(p.items) do
        local entry = p.make_item(i,v)
        entries[i] = entry
        entry.x = i~= 1 and (entries[i-1].x + entries[i-1].w) or 0
    end
    instance:add(clip_contents)
    clip_contents:add(p.hl)
    clip_contents:add(unpack(entries))
    instance.clip={0,0,p.visible_range,math.max(entries[1].h,p.hl.h)}
    ---------------------------------------------------------------
    p.hl.x = entries[sel_i].x+1
    p.hl.w = entries[sel_i].w-2
    --p.hl.h = entries[sel_i].h
    p.hl.opacity = 0
    ---------------------------------------------------------------
    local function move_hl(dir)
        p.hl:stop_animation()
        sel_i = sel_i + dir
        p.hl:animate{
            duration = dur,
            x        = entries[sel_i].x+1,
            w        = entries[sel_i].w-2,
        }
    end
    ---------------------------------------------------------------
    function instance:current() return entries[sel_i] end
    ---------------------------------------------------------------
    function instance:anim_in(f)
        self:stop_animation()
        p.parent:add(self)
        self:animate{
            duration = 200,
            mode = "EASE_OUT_SINE",
            opacity  = 255,
            on_completed = function() return f and f() end,
        }
    end
    function instance:anim_out(f)
        self:stop_animation()
        self:animate{
            duration = 200,
            mode = "EASE_OUT_SINE",
            opacity  =   0,
            on_completed = function()
                self:unparent()
                return f and f()
            end,
        }
    end
    ---------------------------------------------------------------
    function instance:anim_hl_in(f)
        p.hl:stop_animation()
        p.hl:animate{
            duration = 100,
            opacity  = 255,
            on_completed = function() return f and f() end,
        }
    end
    function instance:anim_hl_out(f)
        p.hl:stop_animation()
        p.hl:animate{
            duration = 100,
            opacity  =   0,
            on_completed = function() return f and f() end,
        }
    end
    ---------------------------------------------------------------
    function instance:press_down()

        if sel_i == #entries then return false end

        move_hl(1)

        local dx = entries[sel_i].x + entries[sel_i].w - p.visible_range


        if dx > -clip_contents.x then
            clip_contents:animate{
                duration = dur,
                x        = -dx,
            }
        end
        return true
    end
    function instance:press_up()
        if sel_i == 1 then return false end

        move_hl(-1)

        local dx = entries[sel_i].x

        if dx < -clip_contents.x then
            clip_contents:animate{
                duration = dur,
                x        = -dx,
            }
        end
        return true
    end

    return instance
end
