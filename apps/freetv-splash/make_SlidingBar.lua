

local make_sliding_bar = function(p)
    local instance = Group()
end
local transition_time = 250
make_sliding_bar__expanded_focus    = function(p)

    local function pre_x(i)  return p.spacing*(i-1)-p.unsel_offset end
    local function sel_x(i)  return p.spacing*(i-1)                end
    local function post_x(i) return p.spacing*(i-1)+p.unsel_offset end

    local instance = Group {}
    local entries = {}
    local curr_index = 2

    local clip_group_outter = Group { name = "clip_outter" }
    local clip_group = Group { name = "clip_inner" }
    local entries_group = Group { name = "entries" }

    clip_group:add(entries_group)
    clip_group_outter:add(clip_group)
    instance:add(clip_group_outter)

    local function focus(number, t)
        instance:stop_animation()
        local entry = entries[number]
        entry:raise_to_top()
        entry:focus(sel_x(number))
        local mode = "EASE_IN_OUT_SINE"
        clip_group_outter:animate{
            duration = t,
            mode = mode,
            x = 400 - sel_x(number)
        }
    end

    local function unfocus(number,direction)
        entries[number]:unfocus(
            direction==1 and pre_x(number) or post_x(number)
        )
    end

    local function transfer_focus(direction,dur)
        local n = #entries

        --if wrapping from left edge to right edge
        if curr_index == 1 and direction == -1 then
            dur = n*50

            for i,entry in ipairs(entries) do
                entry:complete_animation()
                entry.x = pre_x(i)--entry.x - 2*p.unsel_offset--(post_x(1) - pre_x(1))
            end
            clip_group_outter:complete_animation()
            clip_group_outter.x = clip_group_outter.x +
                2*p.unsel_offset--(post_x(1) - pre_x(1))

            unfocus(curr_index,1)

        --if wrapping from right edge to left edge
        elseif curr_index == n and direction == 1 then
            dur = n*50
            for i,entry in ipairs(entries) do
                entry:complete_animation()
                entry.x = post_x(i)--entry.x + 2*p.unsel_offset--(post_x(1) - pre_x(1))
            end
            clip_group_outter:complete_animation()
            clip_group_outter.x = clip_group_outter.x -
                2*p.unsel_offset--(post_x(1) - pre_x(1))

            unfocus(curr_index,-1)
        else
            unfocus(curr_index,direction)
        end
        curr_index = wrap_i(
            curr_index+direction,
            n
        )

        focus( curr_index, dur )
    end

    --local function build_bar()
        --screen:add(instance)
        --instance:hide()
        if p.items == nil then
            error("bad items",2)
        end
        for k,v in pairs(p.items) do
            table.insert(entries,p.make_item(v))
        end
        entries_group:add(unpack(entries))
        for i,v in ipairs(entries) do
            v.x = (
                i == curr_index and sel_x or
                i <  curr_index and pre_x or
                i >  curr_index and post_x)(i)
        end

---[[
    clip_group_outter.clip = {
        -205, 0,
        205+entries[#entries].x+entries[#entries].w,
        entries_group.h
    }
--]]

        focus(curr_index,10)
    function instance:press_left()
        transfer_focus(-1,transition_time)
        if  p.press_left then
            p.press_left(instance)
        end
        return true
    end
    function instance:press_right()
        transfer_focus(1,transition_time)
        if  p.press_right then
            p.press_right(instance)
        end
        return true
    end
    function instance:fade_out(f)
        instance:animate{
            duration = 100,
            opacity  = 0,
            on_completed = f,
        }
    end
    function instance:fade_in(f)
        instance:animate{
            duration = 100,
            opacity  = 255,
            on_completed = f,
        }
    end
    function instance:anim_in(f)
        clip_group:stop_animation()
        instance:show()
        clip_group:animate{
            duration = 250,
            y = 0,
            mode = "EASE_OUT_SINE",
            on_completed = f,
        }
    end
    function instance:anim_out(f)
        clip_group:stop_animation()
        clip_group:animate({
            duration = 250,
            y = clip_group.h,
            mode = "EASE_OUT_SINE",
            on_completed =function()
                instance:hide()
                return f and f()
            end,
        })
    end
    clip_group.y = clip_group.h

    instance.press_ok   = p.press_ok
    instance.press_up   = p.press_up
    instance.press_down = p.press_down

    function instance:curr()
        return entries[curr_index]
    end
    return instance
end


--===========================================================--

--===========================================================--

--===========================================================--

local function make_stub(w,h,put_edges)
    local stub = Group { name = "stub" }

    if put_edges then
        stub:add( Sprite { sheet=ui_sprites, h=h,id = "channelbar/channel-bar.png", name = "bg-unfocus", w = w }
                    )
    else
        stub:add( Rectangle { h=h,name = "edge", color = "#2d414e", size = { 1, bar_height } },
                    Sprite { sheet=ui_sprites, h=h,id = "channelbar/channel-bar.png", name = "bg-unfocus", x = 1, w = w - 2 },
                    Rectangle { h=h,name = "edge", color = "#2d414e", size = { 1, bar_height }, x = w - 1 }
                )
    end
    return stub
end

make_sliding_bar__highlighted_focus = function(p)

    local instance = Group {}

    local bg_unfocus = Sprite {
        sheet = ui_sprites,
        id    = "channelbar/channel-bar.png",
        name  = "bg-unfocus",
        w     = screen_w,
    }

    local entries = {}
    local curr_index = 2

    local clip_group_outter = Group { name = "clip_outter" }
    instance:add(clip_group_outter)
    local clip_group = Group { name = "clip_inner" }
    clip_group_outter:add(bg_unfocus,clip_group)

    local shows_group = Group { name = "tv_shows" }
    clip_group:add(shows_group)
    local curr_offset = 0


    local function focus(number, t)
        instance:stop_animation()
        local the_show = entries[number]
        the_show:focus()
        clip_group:animate{
            duration = t,
            mode = "EASE_IN_OUT_SINE",
            x = 200 - the_show.x
        }

    end

    local function unfocus(number,direction)
        entries[number]:unfocus()
    end




    if p.space_on_sub_tables then
        for i,t in ipairs(p.items) do
            for j,v in ipairs(t) do
                local entry = p.make_item(v,channel_bar,channel_bar_focus)
                entry.x = curr_offset
                curr_offset = curr_offset + entry.w
                --table.insert(entries,entry)
                table.insert(entries,entry)
                entry.orig_data = v
            end
            if i ~= #p.items then
                curr_offset = curr_offset+50
            end
        end
    else
        for k,v in ipairs(p.items) do
            local entry = p.make_item(v,channel_bar,channel_bar_focus)
            entry.x = curr_offset
            curr_offset = curr_offset + entry.w
            --table.insert(entries,entry)
            entries[k] = entry
            entry.orig_data = v
        end
    end
    shows_group:add(unpack(entries))
    bg_unfocus.h = shows_group.h

    clip_group_outter.clip = {
        0,
        0,
        clip_group_outter.w,
        shows_group.h
    }






    focus(curr_index,10)
    function instance:current()
        return curr_index
    end
    function instance:curr_entry()
        return entries[curr_index].orig_data
    end
    function instance:entries()
        return entries
    end
    function instance:remove_focus()
        unfocus(curr_index)
    end
    function instance:focus()
        entries[curr_index]:focus()
    end
    function instance:anim_in(f)
        clip_group:stop_animation()
        instance:show()
        clip_group:animate({
            duration = 250,
            y = 0,
            mode = "EASE_OUT_SINE",
            on_completed = function()
                return f and f()
            end
        })
        bg_unfocus:animate({
            duration = 250,
            y = 0,
            mode = "EASE_OUT_SINE",
        })
    end
    function instance:anim_out(f)
        clip_group:stop_animation()
        clip_group:animate({
            duration = 250, y = clip_group.h,
            mode = "EASE_OUT_SINE",
            on_completed = function()
                instance:unparent()
                return f and f()
            end
        })
        bg_unfocus:animate({
            duration = 250,
            y = clip_group.h,
            mode = "EASE_OUT_SINE",
        })
    end
    function instance:press_left()
        unfocus(curr_index)
        curr_index = ((curr_index - 2) % #entries) + 1
        local transition_time = 250
        if( curr_index == #entries ) then
            transition_time = #entries*50
        end

        focus(curr_index, transition_time)
        return true
    end
    function instance:press_right()
        unfocus(curr_index)

        local transition_time = 250
            curr_index = (curr_index % #entries) + 1
            if( curr_index == 1 ) then
                transition_time = #entries*50 end
            focus(curr_index, transition_time)
        return true
    end
    function instance:warp_to( i )
        unfocus(curr_index)
        curr_index = i
        clip_group:stop_animation()
        clip_group.x = 200-entries[curr_index].x
        return true
    end

    instance.press_ok   = p.press_ok
    instance.press_up   = p.press_up
    instance.press_down = p.press_down

    function instance:curr()
        return entries[curr_index]
    end
    bg_unfocus.y = clip_group.h
    clip_group.y = clip_group.h
    instance:warp_to(2)
    instance:focus()
    return instance
end
