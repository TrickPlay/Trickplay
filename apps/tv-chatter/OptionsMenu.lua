scroll_speed = 30
local scroll_speed_selected = 3
local scroll_speed_i =3
local scroll_speed_g = Group{x=485+1}
local scroll_listing_h = 69
local scroll_speed_up, scroll_speed_dn, scroll_speed_set,get_speed
do
    local border_w = 1
	local y = 200
    local x = 60
	local title= Text{
		text="Scroll Speed",
		font="DejaVu Sans Bold 36px",
		color="#FFFFFF",
		y = 5,
		x=20
	}
	local sub_title= Text{
		text="Change the scrolling speed of the tweets:",
		font=Show_Time_Font,
		color=Show_Time_Color,
		y = title.y+title.h+5,
		x=20
	}
	local top_rule    = Image{src="assets/sp_top_rule.png",
        x = 15, y=sub_title.y+sub_title.h+5}
	scroll_speed_g:add(title,sub_title,top_rule)
	y=top_rule.y+5
	local speed = {
		Text{
			text="Slowest",
			font="DejaVu Sans Bold 26px",
			color="#FFFFFF",
			y = .5*scroll_listing_h+y,
			x=x
		},
		Text{
			text="Slow",
			font="DejaVu Sans Bold 26px",
			color="#FFFFFF",
			y = 1.5*scroll_listing_h+y,
			x=x
		},
		Text{
			text="Medium",
			font="DejaVu Sans Bold 26px",
			color="#FFFFFF",
			y = 2.5*scroll_listing_h+y,
			x=x
		},
		Text{
			text="Fast",
			font="DejaVu Sans Bold 26px",
			color="#FFFFFF",
			y = 3.5*scroll_listing_h+y,
			x=x
		},
		Text{
			text="Fastest",
			font="DejaVu Sans Bold 26px",
			color="#FFFFFF",
			y = 4.5*scroll_listing_h+y,
			x=x
		}
	}
	local star_black = Image{
		src="assets/star_black.png",
		x=20,
		y=(scroll_speed_i-.5)*scroll_listing_h+y
	}
	star_black.anchor_point={0,star_black.h/2}
	local star_white = Image{
		src="assets/star_white.png",
		opacity=0,
		x=20,
		y=(scroll_speed_i-.5)*scroll_listing_h+y
	}
	star_white.anchor_point={0,star_white.h/2}
	for _,v in ipairs(speed) do
		v.anchor_point = {0,v.h/2}
	end

    local bg = Image{src="assets/object_options_background.png"}
	
    local focus_o = Clone{source = focus_strip,scale={485,1},y = (scroll_speed_i-1)*scroll_listing_h+y}
	--[[
		  Canvas{size={1,scroll_listing_h}, scale={485,1}}
          focus_o:begin_painting()
          focus_o:move_to(0,0)
          focus_o:line_to(focus_o.w, 0)
          focus_o:line_to(focus_o.w, focus_o.h)
          focus_o:line_to(0,         focus_o.h)
          focus_o:line_to(0,0)
          focus_o:set_source_linear_pattern(
            focus_o.w/2,0,
            focus_o.w/2,focus_o.h
          )
          focus_o:add_source_pattern_color_stop( 0 , "8D8D8D" )
          focus_o:add_source_pattern_color_stop( 1 , "727272" )
	      focus_o:fill( true )
          focus_o:finish_painting()
		  focus_o.y = (scroll_speed_i-1)*scroll_listing_h+y
		  --]]
		  --local focus_o = Rectangle{size={485,scroll_listing_h}}
    local focus_n = Clone{source = focus_strip,scale={485,1},opacity=0}--Clone{source=menu_focus,opacity=0}
    
    scroll_speed_g:add(focus_o,focus_n)
	scroll_speed_g:add(unpack(speed))
	scroll_speed_g:add(star_black,star_white)
	local highlight_timeline = nil
    local move_highlight_to=function(old_i,new_i)
        focus_n.y = (new_i-1)*scroll_listing_h+y
        focus_n.opacity = 0
        if highlight_timeline ~= nil then
            highlight_timeline:stop()
            highlight_timeline:on_completed()
        end
        highlight_timeline = Timeline{
            loop     = false,
            duration = 100
        }
        
        local to_zero = 255
        local to_max  = 0
        local to_a6   = 166
        function highlight_timeline:on_new_frame(msecs,prog)
            to_max  = 255*(prog)
            to_zero = 255*(1-prog)
            to_a6   = 166*(prog)
            speed[new_i].color  = {to_zero,to_zero,to_zero}
            speed[old_i].color  = {to_max,to_max,to_max}
			if new_i == scroll_speed_selected then
				star_black.opacity = to_max
				star_white.opacity = to_zero
			elseif old_i == scroll_speed_selected then
				star_black.opacity = to_zero
				star_white.opacity = to_max
			end
            focus_n.opacity = to_max
            focus_o.opacity = to_zero
        end
        function highlight_timeline:on_completed()
            focus_n.opacity = 0
            focus_o.opacity = 255
            focus_o.y = focus_n.y
			if new_i == scroll_speed_selected then
				star_black.opacity = 255
				star_white.opacity = 0
			elseif old_i == scroll_speed_selected then
				star_black.opacity = 0
				star_white.opacity = 255
			end
            speed[new_i].color  = {0,0,0}
            speed[old_i].color  = {255,255,255}
            highlight_timeline = nil
        end
        highlight_timeline:start()
        scroll_speed_i = new_i
    end
	local px_p_sec = {5,15,30,45,60}
	scroll_speed_up = function()
		if scroll_speed_i - 1 >= 1 then
			
			scroll_speed = px_p_sec[scroll_speed_i-1]
			move_highlight_to(scroll_speed_i,scroll_speed_i-1)
			
		end
	end
	scroll_speed_dn = function()
		if scroll_speed_i + 1 <= 5 then
			
			scroll_speed = px_p_sec[scroll_speed_i+1]
			move_highlight_to(scroll_speed_i,scroll_speed_i+1)
			
		end
	end
	
	scroll_speed_set = function()
		scroll_speed_selected = scroll_speed_i
		star_black.y = (scroll_speed_selected-.5)*scroll_listing_h+y
		star_black.opacity=255
		star_white.y = (scroll_speed_selected-.5)*scroll_listing_h+y
		star_white.opacity=0
		
		return speed[scroll_speed_i].text
	end
	get_speed = function()
		return speed[scroll_speed_selected].text
	end
end


local view_opt_tl = nil
local view_option  = function(groups,w)
    if view_opt_tl ~= nil then
        view_opt_tl:stop()
        view_opt_tl:on_completed()
    end
    view_opt_tl = Timeline{duration = 500}
    local ani_mode = Alpha{timeline=view_opt_tl,mode="EASE_OUT_CIRC"}
    local orig_xs = {}
    for i = 1,#groups do
        orig_xs[i] = groups[i].x
    end
    function view_opt_tl:on_new_frame(msecs)
        local prog = ani_mode.alpha
        for i = 1,#groups do
            groups[i].x = orig_xs[i]-w*prog
        end
    end
    function view_opt_tl:on_completed(msecs,prog)
        for i = 1,#groups do
            groups[i].x = orig_xs[i]-w
        end
    end
    view_opt_tl:start()
end
local close_option = function(groups,w)
    if view_opt_tl ~= nil then
        view_opt_tl:stop()
        view_opt_tl:on_completed()
    end
    view_opt_tl = Timeline{duration = 500}
    local ani_mode = Alpha{timeline=view_opt_tl,mode="EASE_OUT_CIRC"}
    local orig_xs = {}
    for i = 1,#groups do
        orig_xs[i] = groups[i].x
    end
    function view_opt_tl:on_new_frame(msecs)
        local prog = ani_mode.alpha
        for i = 1,#groups do
            groups[i].x = orig_xs[i]+w*(prog)
        end
    end
    function view_opt_tl:on_completed(msecs,prog)
        for i = 1,#groups do
            groups[i].x = orig_xs[i]+w
        end
		--groups[#groups]:unparent()
    end
    view_opt_tl:start()
end


Options = Class(function(self,x,y,parent,...)

    local listing_h           = 68
    
    local group = Group
    {
        x = x,--screen_w,
        y = y,--bottom_containers_y
    }
    local title    = Image{src="assets/options_tit.png"}
   
    local bg,big_focus = make_bg(485,595,   0,title.h+10,true)
    --local big_focus = Image{src="assets/focus-options.png",opacity=0,x=bg.x-20,y=bg.y-20}
    local border_w = 1
    local anim_menu_tl = nil
    local viewing = false
    --[[
    local rules = Canvas{size={bg.w,bg.h-23*2},x=0,y=bg.y+23}
          rules:begin_painting()
          rules:move_to(0,0)--border_w,         border_w)
          rules:line_to(rules.w-border_w, border_w)
          rules:move_to(border_w,         rules.h-border_w)
          rules:line_to(rules.w-border_w, rules.h-border_w)
          rules:set_source_color( "505050" )
          rules:set_line_width(   border_w )
          rules:stroke( true )
          rules:finish_painting()
    local grey_rect = Canvas{size={bg.w,listing_h},opacity=0}
          grey_rect:begin_painting()
          grey_rect:move_to(border_w,0)--border_w,         border_w)
          grey_rect:line_to(grey_rect.w-border_w, 0)
          grey_rect:line_to(grey_rect.w-border_w, grey_rect.h-border_w)
          grey_rect:line_to(border_w,             grey_rect.h-border_w)
          grey_rect:line_to(border_w,0)
          grey_rect:set_source_color( "181818" )
	      grey_rect:fill( true )
          grey_rect:set_source_color( "2D2D2D" )
          grey_rect:set_line_width(   border_w )
	      grey_rect:stroke( true )
          grey_rect:finish_painting()
		  --]]
	--local grey_rect = Clone{source = base_grey_rect, scale={bg.w,1},opacity=0}
	--local grey_rect = Rectangle{size={bg.w,listing_h},opacity=0}
    --screen:add(grey_rect)
    --[[
    local focus_o = Canvas{size={485,listing_h},opacity=0}
          focus_o:begin_painting()
          focus_o:move_to(0,0)--border_w,         border_w)
          focus_o:line_to(focus_o.w-border_w, border_w)
          focus_o:line_to(focus_o.w-border_w, focus_o.h-border_w)
          focus_o:line_to(border_w,           focus_o.h-border_w)
          focus_o:line_to(0,0)
          focus_o:set_source_linear_pattern(
            focus_o.w/2,0,
            focus_o.w/2,focus_o.h
          )
          focus_o:add_source_pattern_color_stop( 0 , "8D8D8D" )
          focus_o:add_source_pattern_color_stop( 1 , "727272" )
	      focus_o:fill( true )
          focus_o:finish_painting()
		  --]]
	local focus_o = Clone{source = focus_strip,scale={485,1},opacity=0}
	--local focus_o = Rectangle{size={485,listing_h},opacity=0}
	local focus_n = Clone{source = focus_strip,scale={485,1},opacity=0}
    --local focus_n = Clone{source=focus_o,opacity=0}
    
    local Option_Name_Font  = "DejaVu Sans 24px"
    local Option_Name_Color = "#a6a6a6"
    local Option_Sel_Font   = "DejaVu Sans bold 26px"
    local Option_Sel_Color  = "#FFFFFF"

    local listings = {}
    local listings_clip = Group
    {
        y    = bg.y+23,
        clip = { 1, 0,  bg.w-2, bg.h-23*2}
    }
    local listings_g = Group{}
    local listings_bg = Group{}
    listings_clip:add(listings_bg,listings_g)
    listings_g:add(focus_o,focus_n)
    local arrow_dn = Image{src="assets/arrow.png",x=bg.w/2,y=bg.y+bg.h-12,opacity=0}
    arrow_dn.anchor_point={arrow_dn.w/2,arrow_dn.h/2}
    local arrow_up = Clone
    {
        source       = arrow_dn,
        z_rotation   = {180,0,0},
        anchor_point = {arrow_dn.w/2,arrow_dn.h/2},
        opacity=0,
        x=bg.w/2,y=bg.y+12
    }
    group:add(
        --bg_unsel,
        big_focus,
        bg,
        title,
        listings_clip,
        arrow_dn,
        arrow_up
        --rules
    )
    
    if parent == sp then
        sp_group:add(group)
    else
        fp_group:add(group)
    end
    ----------------------------------------------------------------------------
    
    local list_i = 1
    local vis_loc = 1
    local max_on_screen = 8
    function self:add(option)
        local index = #listings + 1
        local opt_name = Text
                {
                    text  = option.name,
                    font  = Option_Name_Font,
                    color = Option_Name_Color,
                    x     = 15,
                    y     = listing_h*(index-.5)
                }
                opt_name.anchor_point={
                    0,--show_name.w/2,
                    opt_name.h/2
                }
        local opt_selection = Text
                {
                    text  = option.selection,
                    font  = Option_Sel_Font,
                    color = Option_Sel_Color,
                    x     = bg.x+bg.w-15,
                    y     = listing_h*(index-.5)
                }
                opt_selection.anchor_point={
                    opt_selection.w,
                    opt_selection.h/2
                }
		
        
            listings_bg:add(Clone{source=base_grey_rect,scale={bg.w,1},y=listing_h*(index-1)})
        
        table.insert(listings,
            {
                opt        = option,
                name  = opt_name,
                opt_selection  = opt_selection,
            }
        )
        
        listings_g:add(opt_name, opt_selection)
        --listings_clip:add(option.group)
        if #listings > max_on_screen then
            arrow_dn.opacity=255
        end
    end
    
    self:add({
			name="Scroll Speed",
			selection="Medium",
			group = scroll_speed_g,
			on_up=function() scroll_speed_up() end,
			on_dn=function() scroll_speed_dn() end,
			on_enter=function() return scroll_speed_set() end,
			update = function() return get_speed() end
		}
	)
    self:add({name="Filter Tweets",   selection="Celebrities"})
    self:add({name="Zip Code",        selection="94109"})
    self:add({name="Cable Provider",  selection="Cox"})
    self:add({name="Twitter Account", selection="JohnnyApples"})
    local prev   = nil
    local prev_f = nil
    
    
    function self:receive_focus(p,f)
        prev = p
        prev_f = f
        --bg_sel.opacity   = 255
        --bg_unsel.opacity = 0
        if #listings > 0 then
            focus_o.opacity=255
            listings[list_i].name.color  = "#000000"
            listings[list_i].opt_selection.color  = "#000000"
			for _,v in ipairs(listings) do
				if v.opt.update then
					v.opt_selection.text = v.opt.update()
					v.opt_selection.anchor_point={
					    v.opt_selection.w,
					    v.opt_selection.h/2
					}
				end
			end
        end
        --fp.listings_container:move_x_by(-(bg.w+50))
        --fp.tweetstream:move_x_by(-(bg.w+50))
        --group.x = group.x - (bg.w+50)
        
        if anim_menu_tl ~= nil then
            anim_menu_tl:stop()
            anim_menu_tl:on_completed()
        end
        if parent == sp then
            anim_menu_tl = Timeline{duration = 1000}
            local prev_x = group.x
            function anim_menu_tl:on_new_frame(msecs,prog)
                
                if msecs < 500 then
                    parent.options_anim((bg.h+100)*prog*2)
                else
                    parent.options_anim((bg.h+100))
                    big_focus.opacity=255*(2*prog-1)
                    group.x = prev_x - (bg.w+50)*(2*prog-1)
                end
            end
            function anim_menu_tl:on_completed(msecs,prog)
                big_focus.opacity=255
                group.x = prev_x - (bg.w+50)
                parent.options_anim((bg.h+100))
            end
            anim_menu_tl:start()
        else
            anim_menu_tl = Timeline{duration = 500}
            local ani_mode = Alpha{timeline=anim_menu_tl,mode="EASE_IN_CIRC"}
            local prev_x = group.x
            function anim_menu_tl:on_new_frame(msecs)
                local prog = ani_mode.alpha
                big_focus.opacity=255*prog
                group.x = prev_x - (bg.w+50)*prog
                parent.options_anim(-(bg.w+50)*prog)
            end
            function anim_menu_tl:on_completed(msecs,prog)
                big_focus.opacity=255
                group.x = prev_x - (bg.w+50)
                parent.options_anim(-(bg.w+50))
            end
            anim_menu_tl:start()
        end
        --fp.tweetstream:display(listings[list_i].obj)
    end
    function self:lose_focus()
        --bg_sel.opacity   = 0
        --bg_unsel.opacity = 255
        if #listings > 0 then
            focus_o.opacity=0
            listings[list_i].name.color          = Option_Name_Color
            listings[list_i].opt_selection.color = Option_Sel_Color
        end
        --fp.listings_container:move_x_by((bg.w+50))
        --fp.tweetstream:move_x_by((bg.w+50))
        --group.x = group.x + (bg.w+50)
        
        if anim_menu_tl ~= nil then
            anim_menu_tl:stop()
            anim_menu_tl:on_completed()
        end
        if parent == sp then
        
            anim_menu_tl = Timeline{duration = 1000}
            local prev_x = group.x
            function anim_menu_tl:on_new_frame(msecs,prog)
                if msecs >= 500 then
                    parent.options_anim((bg.h+100)*(2-prog*2))
                    big_focus.opacity=0
                    group.x = prev_x + (bg.w+50)
                else
                    big_focus.opacity=255*(1-2*prog)
                    group.x = prev_x + (bg.w+50)*(2*prog)
                end
            end
            function anim_menu_tl:on_completed(msecs,prog)
                big_focus.opacity=0
                group.x = prev_x + (bg.w+50)
                parent.options_anim(0)
            end
            anim_menu_tl:start()
        else
            anim_menu_tl = Timeline{duration = 500}
            local ani_mode = Alpha{timeline=anim_menu_tl,mode="EASE_OUT_CIRC"}
            local prev_x = group.x
            function anim_menu_tl:on_new_frame(msecs)
                local prog = ani_mode.alpha
                big_focus.opacity=255*(1-prog)
                group.x = prev_x + (bg.w+50)*prog
                parent.options_anim(-(bg.w+50)*(1-prog))
            end
            function anim_menu_tl:on_completed(msecs,prog)
                big_focus.opacity=0
                group.x = prev_x + (bg.w+50)
                parent.options_anim(0)
            end
            anim_menu_tl:start()
        end
    end
    
    local highlight_timeline = nil
    function self:move_highlight_to(old_i,new_i)
        focus_n.y = (new_i-1)*listing_h
        focus_n.opacity = 0
        if highlight_timeline ~= nil then
            highlight_timeline:stop()
            highlight_timeline:on_completed()
        end
        highlight_timeline = Timeline{
            loop     = false,
            duration = 100
        }
        
        local to_zero = 255
        local to_max  = 0
        local to_a6   = 166
        function highlight_timeline:on_new_frame(msecs,prog)
            to_max  = 255*(prog)
            to_zero = 255*(1-prog)
            to_a6   = 166*(prog)
            listings[new_i].name.color  = {to_zero,to_zero,to_zero}
            listings[new_i].opt_selection.color  = {to_zero,to_zero,to_zero}
            listings[old_i].name.color  = {to_a6,to_a6,to_a6}
            listings[old_i].opt_selection.color  = {to_max,to_max,to_max}
            focus_n.opacity = to_max
            focus_o.opacity = to_zero
        end
        function highlight_timeline:on_completed()
            focus_n.opacity = 0
            focus_o.opacity = 255
            focus_o.y = focus_n.y
            listings[new_i].name.color  = {0,0,0}
            listings[new_i].opt_selection.color  = {0,0,0}
            listings[old_i].name.color  = {166,166,166}
            listings[old_i].opt_selection.color  = {255,255,255}
            highlight_timeline = nil
        end
        highlight_timeline:start()
        list_i = new_i
    end
    local move_timeline = nil
    function self:move_list(new_loc)
        --local delta = new_loc - listings_bg.y
        local old_loc = listings_bg.y
        if move_timeline ~= nil then
            move_timeline:stop()
            move_timeline:on_completed()
        end
        move_timeline = Timeline{
            loop     = false,
            duration = 100
        }
        function move_timeline:on_new_frame(msecs,prog)
            listings_bg.y = old_loc + (new_loc - old_loc)*prog
            listings_g.y  = old_loc + (new_loc - old_loc)*prog
        end
        function move_timeline:on_completed()
            listings_bg.y = new_loc
            listings_g.y  = new_loc
            move_timeline = nil
        end
        move_timeline:start()
    end
    
    function self:up()
		if viewing then
			listings[list_i].opt.on_up()
		else
			if list_i - 1 >= 1 then
				self:move_highlight_to(list_i,list_i - 1)
				if vis_loc == 1 then
					self:move_list(-(list_i -1)*(grey_rect.h))
					arrow_dn.opacity=255
					if list_i == 1 then
						arrow_up.opacity=0
					end
				else
					vis_loc = vis_loc - 1
					
					if vis_loc == 1 then
						self:move_list(-(list_i -1)*(listing_h))
					end
				end
			else
			--[[
				if highlight_timeline ~= nil then
					highlight_timeline:stop()
					highlight_timeline:on_completed()
				end
				if move_timeline ~= nil then
					move_timeline:stop()
					move_timeline:on_completed()
				end
				fp.focus = "TITLECARDS"
				self:lose_focus()
				fp.title_card_bar:receive_focus()
				--]]
			end
		end
    end
    
    function self:down()
		if viewing then
			listings[list_i].opt.on_dn()
		else
			if list_i + 1 <= #listings then
			    self:move_highlight_to(list_i,list_i + 1)
			    if vis_loc == max_on_screen then
			        self:move_list(-(list_i -max_on_screen)*(listing_h))
			        arrow_up.opacity=255
			        if list_i == #listings then
			            arrow_dn.opacity=0
			        end
			    else
			        vis_loc = vis_loc + 1
			        
			        if vis_loc == max_on_screen then
			            self:move_list(-(list_i -max_on_screen)*(listing_h))
			        end
			    end
			end
		end
    end
    function self:return_to_prev()
        self:lose_focus()
        prev:receive_focus()
        if parent == fp then
            fp.focus = prev_f
        else
            sp.focus = prev_f
        end
    end
    
---[[
    function self:enter()
        if viewing then
			listings[list_i].opt_selection.text = listings[list_i].opt.on_enter()
			listings[list_i].opt_selection.anchor_point={
                    listings[list_i].opt_selection.w,
                    listings[list_i].opt_selection.h/2
                }
            close_option({listings_bg,listings_g,listings[list_i].opt.group},listings_clip.clip[3]+1)
            viewing = false
        elseif list_i == 1 then
			if listings[list_i].opt.group.parent ~= nil then
				listings[list_i].opt.group:unparent()
			end
			listings_clip:add(listings[list_i].opt.group)
            view_option({listings_bg,listings_g,listings[list_i].opt.group},listings_clip.clip[3]+1)
            viewing = true
        end
    end
    --]]
end)