
local    my_turn = {}
local their_turn = {}
local  old_games = {}


--------------------------------------------------------------------------------
-- The Object                                                                 --
--------------------------------------------------------------------------------
local MML = Group{name = "Main Menu List", x = 400, y = 750}


--------------------------------------------------------------------------------
-- Attributes                                                                 --
--------------------------------------------------------------------------------

--passed in init
local make_entry, img_srcs, game_server,guess_word,make_word,create_game_state,main_menu

--setup in init
local vis_range, mid_align, frame, clip, no_sessions_text, clip_table

--list indexing
local curr_i, top_vis_i = 1, 1


--helper functions
local function make_frame(w,h)
    local c = Canvas( box_w, box_h )
    c:set_source_color( "#ffffffff" )
    c.line_width = 2
    c:round_rectangle( 1, 1, w-2, h-2, 8 )
    c:stroke()
    return c:Image()
end

local list_len = function()
    
    return # my_turn + # their_turn + # old_games
    
end

--------------------------------------------------------------------------------
-- Methods                                                                    --
--------------------------------------------------------------------------------

function MML:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    img_srcs      = t.img_srcs    or error( "must pass img_srcs",      2 )
    make_entry    = t.make_entry  or error( "must pass make_entry",    2 )
    game_server   = t.game_server or error( "must pass game_server",   2 )
    guess_word    = t.guess_word  or error( "must pass guess_word",    2 )
    make_word     = t.make_word   or error( "must pass make_word",     2 )
    main_menu     = t.main_menu   or error( "must pass main_menu",     2 )
    create_game_state = t.create_game_state or error( "must pass create_game_state",      2 )
    score_limit   = t.score_limit or 3
    box_w         = t.box_w       or 750
    box_h         = t.box_h       or 275
    entry_h       = t.entry_h     or  48
    
    vis_range = math.floor(box_h/entry_h)
    
    mid_align = (box_h - vis_range*entry_h)/2
    
    frame = make_frame(box_w,box_h)
    hl    = Clone{ source = img_srcs.mm_focus, x = 2, opacity = 0}
    clip  = Group{name = "Clip",clip = { 2,2,box_w - 4,box_h - 4}}
    
    no_sessions_text = Text{
        text    = "Getting User Profile",
        font    = g_font .. " 30px",
        color   = "aaaaaa",
        x       = frame.w/2,
        y       = 50,
    }
    no_sessions_text.anchor_point = {
        no_sessions_text.w/2, 0
    }
    
    clip.focus_anim = AnimationState{
        duration = 300,
        transitions = {
            {
                source = "*", target = "UNFOCUSED", duration = 300,
                keys = { {hl, "opacity",   0} }
            },
            {
                source = "*", target = "FOCUSED",  duration = 300,
                keys = { {hl, "opacity", 255} }
            }
        }
    }
    
    
    clip_table = { 2,false,box_w - 4,box_h - 4}
    
    clip:add(hl,no_sessions_text)
    MML:add(frame,clip)
    
end

local color
local color_t = {}

local loading_animation = Timeline{
    duration     = 2000,
    loop         = true,
    on_new_frame = function(tl,ms,p)
        
        color = 150 + 100*math.sin(math.pi*2*p)
        
        color_t[1] = color
        color_t[2] = color
        color_t[3] = color
        
        no_sessions_text.color = color_t
        
    end
}
    


function MML:center_text(t)
    no_sessions_text.text = t
    no_sessions_text.anchor_point = {
        no_sessions_text.w/2, 0
    }
end
function MML:load_animation()
    
    loading_animation:start()
    
end
function MML:init_sessions()
    
    self:center_text("Loading Active Sessions")
    
    game_server:get_list_of_sessions(function(sessions)
        
        loading_animation:stop()
        
        dumptable(sessions)
        
        
        main_menu:loaded()
        
        main_menu:gain_focus()
        
        if # sessions == 0 then
            
            self:center_text("No Active Sessions")
            
            return
            
        end
        
        no_sessions_text.opacity = 0
        
        for i,sesh in pairs(sessions) do
            
            --make a session object
            sesh = create_game_state(sesh)
            print(i,sesh)
            self:add_entry(sesh)
            
        end
        
        self:update_y_s()
        
        
    end)
    
end

function MML:add_entry(session)
    
    if list_len() == 0 then
        
        no_sessions_text.opacity = 0
        
    end
    
    local entry = make_entry{
        sesh        = session,
        mml         = self,
        box_w       = box_w,
        entry_h     = entry_h,
        score_limit = score_limit,
    }
    
    clip:add(entry)
    
    self:update_y_s()
    
end

function MML:remove_from_list(entry)
    
    for i, obj in ipairs(my_turn) do
        
        if obj == entry then
            
            table.remove(my_turn,i)
            
            return true
            
        end
        
    end
    
    for i, obj in ipairs(their_turn) do
        
        if obj == entry then
            
            table.remove(their_turn,i)
            
            return true
            
        end
        
    end
    
    return false
    
end

function MML:move_to_my_turn(entry)
    
    print("MML:move_to_my_turn")
    
    MML:remove_from_list(entry)
    
    table.insert(my_turn,1,entry)
    
end

function MML:move_to_their_turn(entry)
    
    print("MML:move_to_their_turn")
    
    MML:remove_from_list(entry)
    
    table.insert(their_turn,1,entry)
    
end

function MML:move_to_old_games(entry)
    
    print("MML:move_to_their_turn")
    
    MML:remove_from_list(entry)
    
    table.insert(old_games,1,entry)
    
end

function MML:update_y_s()
    
    print("MML:update_y_s ", #my_turn, #their_turn)
    
    for i, obj in ipairs(my_turn) do
        
        obj.y = entry_h*( i - 1 )
        
    end
    
    for i, obj in ipairs(their_turn) do
        
        obj.y = entry_h*( i - 1 + # my_turn )
        
    end
    
    for i, obj in ipairs(old_games) do
        
        obj.y = entry_h*( i - 1 + # my_turn + # their_turn )
        
    end
    
end

function MML:set_state(new_state)
    
    if new_state == "FOCUSED" then
        
        if list_len() == 0 then
            
            return false
            
        else
            
            clip.focus_anim.state = "FOCUSED"
            
            clip:grab_key_focus()
            
        end
        
    elseif new_state == "UNFOCUSED" then
        
        clip.focus_anim.state = "UNFOCUSED"
        
    else
        
        error("received invalid state",2)
        
    end
    
end

--------------------------------------------------------------------------------
-- List Traversal Animations                                                  --
--------------------------------------------------------------------------------

local animating = false

local clip_y = Interval(0,0)
local hl_y   = Interval(0,0)

local on_new_frame_hl_only = function(self,ms,p)
    
    hl.y      =     hl_y:get_value(p)
    
end

local on_new_frame_all = function(self,ms,p)
    
    clip_table[2] = -clip_y:get_value(p)+2+ frame.y
    
    clip.y    = clip_y:get_value(p) 
    clip.clip = clip_table 
    hl.y      = hl_y:get_value(p)
    
end

local move_hl = Timeline{
    
    duration = 300,
    
    on_completed = function() animating = false end
    
}




--------------------------------------------------------------------------------
-- Key Events                                                                 --
--------------------------------------------------------------------------------


local key_events = {
    [keys.Up] = function()
        
        if curr_i <= 1 or animating then return end
        
        animating = true
        
        
        if top_vis_i == curr_i then
            
            top_vis_i = top_vis_i - 1
            
            move_hl.on_new_frame = on_new_frame_all
            
            clip_y.from = clip.y
            clip_y.to   = 750-entry_h*(top_vis_i-1)--clip.y + entry_h
            
            if top_vis_i == 1 then
            elseif (top_vis_i + vis_range - 1) == list_len() then
                print("here1")
                clip_y.to = clip_y.to + mid_align*2
            else
                print("here2")
                clip_y.to = clip_y.to + mid_align
            end
            
        else
            
            move_hl.on_new_frame = on_new_frame_hl_only
            
        end
        
        curr_i = curr_i - 1
        
        hl_y.from = hl.y
        hl_y.to   = entry_h*(curr_i-1)
        
        move_hl:start()
        
    end,
    [keys.Down] = function()
        
        if curr_i >= list_len() or animating then return end
        
        animating = true
        
        
        if top_vis_i+vis_range - 1 == curr_i then
            
            top_vis_i = top_vis_i + 1
            
            move_hl.on_new_frame = on_new_frame_all
            
            clip_y.from = clip.y
            clip_y.to   = 750-entry_h*(top_vis_i-1)--clip.y - entry_h
            
            if top_vis_i == 1 then
            elseif (top_vis_i + vis_range - 1) == list_len() then
                print("here1")
                clip_y.to = clip_y.to + mid_align*2
            else
                print("here2")
                clip_y.to = clip_y.to + mid_align
            end
            print(clip_y.from,clip_y.to)
            
        else
            
            move_hl.on_new_frame = on_new_frame_hl_only
            
        end
        
        curr_i = curr_i +1
        
        hl_y.from = hl.y
        hl_y.to   = entry_h*(curr_i-1)
        
        move_hl:start()
        
    end,
    [keys.OK] = function()
        
        if curr_i > # my_turn or animating then return end
        
        if my_turn[curr_i]:get_session().phase == "MAKING" then
            
            make_word:set_session(my_turn[curr_i]:get_session())
            
            app_state.state = "MAKE_WORD"
            
        else
            guess_word:reset()
            guess_word:guess_word(my_turn[curr_i]:get_session())
            ls:reset()
            
            app_state.state = "GUESS_WORD"
        end
    end,
    
}
function MML:on_key_down(k)
    
    if key_events[k] then key_events[k]() end
    
end




return MML