local dur = 200
make_windowed_list = function(p)

    local dim_pos, dim_size
    if p.orientation == "vertical" then
        dim_pos  = "y"
        dim_size = "h"
    else
        dim_pos  = "x"
        dim_size = "w"
    end

    local instance      = Group {}
    local clip_contents = Group {}
    local entries = {}

    local sel_i   = 1

    instance:add(clip_contents)
    ---------------------------------------------------------------
    if p.bg_is_separate then
        local txt_g = Group()
        local  bg_g = Group()
        clip_contents:add(bg_g,p.hl,txt_g)
        for i,v in ipairs(p.items) do
            local entry_bg,entry_txt = p.make_item(i,v)
            entries[i] = entry_bg
            entry_bg[dim_pos] = i~= 1 and
                (entries[i-1][dim_pos] + entries[i-1][dim_size]) or 0
            entry_txt[dim_pos] = entry_bg[dim_pos]
            bg_g:add(entry_bg)
            txt_g:add(entry_txt)
        end
    else
        clip_contents:add(p.hl)
        for i,v in ipairs(p.items) do
            local entry = p.make_item(i,v)
            entries[i] = entry
            entry[dim_pos] = i~= 1 and
                (entries[i-1][dim_pos] + entries[i-1][dim_size]) or 0
            clip_contents:add(entry)
        end
    end

    if p.orientation == "vertical" then
        instance.clip={0,0,math.max(entries[1].w,p.hl.w),p.visible_range}
    else
        instance.clip={0,0,p.visible_range,math.max(entries[1].h,p.hl.h)}
    end
    ---------------------------------------------------------------
    p.hl[dim_pos]  = entries[sel_i][dim_pos]  +1
    p.hl[dim_size] = entries[sel_i][dim_size] -2
    --p.hl.h = entries[sel_i].h
    p.hl.opacity = p.passive_focus or 0
    ---------------------------------------------------------------
    local function move_hl(dir)
        p.hl:stop_animation()
        sel_i = sel_i + dir
        p.hl:animate{
            duration   = dur,
            [dim_pos]  = entries[sel_i][dim_pos]  +1,
            [dim_size] = entries[sel_i][dim_size] -2,
        }
    end
    ---------------------------------------------------------------
    function instance:current() return  entries[sel_i] end
    function instance:len()     return #entries        end
    ---------------------------------------------------------------
    function instance:warp_focus_to_end(i)
        sel_i = #entries
        p.hl:set{
            [dim_pos]  = entries[sel_i][dim_pos]  +1,
            [dim_size] = entries[sel_i][dim_size] -2,
        }
        delta =
            entries[sel_i][dim_pos]  +
            entries[sel_i][dim_size] - p.visible_range
        if delta > -clip_contents[dim_pos] then
            clip_contents[dim_pos] = -delta
        end

    end
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
            opacity  = p.passive_focus or 0,
            on_completed = function() return f and f() end,
        }
    end
    ---------------------------------------------------------------
    function instance:press_forward()

        if sel_i == #entries then return false end

        move_hl(1)

        local delta = entries[sel_i][dim_pos] + entries[sel_i][dim_size] - p.visible_range


        if delta > -clip_contents[dim_pos] then
            clip_contents:stop_animation()
            clip_contents:animate{
                duration  = dur,
                [dim_pos] = -delta,
            }
        end
        return true
    end
    function instance:press_backward()
        if sel_i == 1 then return false end

        move_hl(-1)

        local delta = entries[sel_i][dim_pos]

        if delta < -clip_contents[dim_pos] then
            clip_contents:stop_animation()
            clip_contents:animate{
                duration  = dur,
                [dim_pos] = -delta,
            }
        end
        return true
    end

    return instance
end
