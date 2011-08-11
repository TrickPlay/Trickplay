--Card Object Class
local font   = "DejaVu Sans Condensed normal"
local font_b = "DejaVu Sans Condensed Bold normal"
local title_padding = 23
local white_text = "f4fce9"
local black_text = "333333"


local function empty() end

local function throb(self,msecs,p)
	if self:find_child("GLOW") then
		
		self:find_child("GLOW").opacity=255* (.5+.5*cos(360*p))
		
	end
end

--turns list tags into an outline
local dot = "•"
local function gen_highlight(s)
	local ret_val = ""
	local i,j,k = 1,1,1
	while i ~= nil do
		i,j = string.find(s,"<li>",k)
		if i == nil then
			return ret_val
		end
		i,k = string.find(s,"</li>",j)
		
		ret_val = ret_val..dot..string.sub(s,j+1,i-1).."\n"
	end
	return ret_val
end

local function decode(s)
	
	s = string.gsub(s,"&apos;","'")
    s = string.gsub(s,"&quot;","\"")
    s = string.gsub(s,"&lt;","<")
    s = string.gsub(s,"&gt;",">")
    s = string.gsub(s,"&amp;","&")
	s = string.gsub(s,"<[^<>]*>","")
	
	return s
end

local days, hours, mins
local convert_seconds_up = function(s)
	--print(s)
	days = math.floor(s/(60*60*24))
	
	s = s%(60*60*24)
	
	hours = math.floor(s/(60*60))
	
	s = s%(60*60)
	
	mins = math.floor(s/60)
	
	return days,hours,mins,s%60
	
end

local delta = {}
local src = assets.hourglass[11]
local update_time = function(self,curr_time)
	
	--os.date("!*t") 
	
	delta.day, delta.hour, delta.min, delta.sec =
	convert_seconds_up(
		os.difftime(
			self.exp_secs,
			os.time(curr_time)
		)
	)
	--dumptable(self.exp)
	--dumptable(delta)
	
	--print(diff)
	
	--for _,c in ipairs(cards) do
		
	--delta.year  = self.exp.year  - curr_time.year
	--delta.month = self.exp.month - curr_time.month
	--delta.day   = self.exp.day   - curr_time.day
	--delta.hour  = self.exp.hour  - curr_time.hour --+ self.tz
	--delta.min   = self.exp.min   - curr_time.min
	--delta.sec   = self.exp.sec   - curr_time.sec
	--[[
	if delta.sec < 0 then
		delta.sec = delta.sec + 60
		delta.min = delta.min - 1
		
	end
	if delta.min < 0 then
		delta.min  = delta.min + 60
		delta.hour = delta.hour - 1
		if delta.min < 1 then
			src = assets.hourglass[11]
		elseif delta.min < 31 then
			src = assets.hourglass[10]
		else
			src = assets.hourglass[9]
		end
	end
	if delta.hour < 0 then
		delta.hour = delta.hour + 24
		delta.day  = delta.day - 1
		if delta.hour < 1 then
			src = assets.hourglass[9]
		elseif delta.hour < 7 then
			src = assets.hourglass[8]
		elseif delta.hour < 13 then
			src = assets.hourglass[7]
		elseif delta.hour < 20 then
			src = assets.hourglass[6]
		else
			src = assets.hourglass[5]
		end
	end
	if delta.day < 0 then
		delta.day   = delta.day + 30
		delta.month = delta.month - 1
		if delta.day < 1 then
			src = assets.hourglass[5]
		elseif delta.day < 2 then
			src = assets.hourglass[4]
		elseif delta.day < 3 then
			src = assets.hourglass[3]
		elseif delta.day < 4 then
			src = assets.hourglass[2]
		else
			src = assets.hourglass[1]
		end
	end
	if delta.month < 0 then
		delta.month = delta.month + 12
		delta.year  = delta.year - 1
	end
	--]]
	if delta.day < 1 then
		if delta.hour < 1 then
			if delta.min < 1 then
				src = assets.hourglass[11]
			elseif delta.min < 31 then
				src = assets.hourglass[10]
			else
				src = assets.hourglass[9]
			end
		elseif delta.hour < 7 then
			src = assets.hourglass[8]
		elseif delta.hour < 13 then
			src = assets.hourglass[7]
		elseif delta.hour < 20 then
			src = assets.hourglass[6]
		else
			src = assets.hourglass[5]
		end
	elseif delta.day < 2 then
		src = assets.hourglass[4]
	elseif delta.day < 3 then
		src = assets.hourglass[3]
	elseif delta.day < 4 then
		src = assets.hourglass[2]
	else
		src = assets.hourglass[1]
	end
	
	if delta.day < 0 then
		self:find_child("TIME").text="EXPIRED"
		src = assets.hourglass[12]
		
		self:not_available()
	else
		
		--local day = (30*delta.month+delta.day)
		
		local str = ""
		
		if delta.day > 1 then
			str = str..delta.day.." days "
		elseif delta.day == 1 then
			str = str..delta.day.." day "
		elseif delta.day ~= 0 then
			dumptable(self.exp)
			dumptable(curr_time)
			dumptable(delta)
			error("IMPOSSSIBLE!?!?!?!?!?!?!?!")
		end
		
		str = str..string.format("%d",delta.hour)..
			":"..string.format("%02d",delta.min)..
			":"..string.format("%02d",delta.sec)
		
		self:find_child("TIME").text = str
		--self:find_child("TIME").anchor_point = {self:find_child("TIME").w/2,0}
	end
	
	self.hourglass.source = src
end
local txt_to_canvas = function(c,t)
	c:new_path()
	c:move_to(
		t.x - t.anchor_point[1],
		t.y - t.anchor_point[2]
	)
	c:text_element_path(t)
	c:set_source_color(t.color)
	c:fill(true)
end
local img_on_loaded = function(b,failed)
	
	b.on_loaded = nil
	
	if failed then
		
		print("Failed to load from the internat. ")
		
		return
		
	end
	
	
	local c = b.targ_canvas
	local g = b.group
	
	g.deal_img = nil
	
	c:new_path()
    c:move_to(301,    56)
	c:line_to(301+439,56)
	c:line_to(301+439,56+266)
	c:line_to(301,    56+266)
	c:line_to(301,    56)
	c:set_source_bitmap(b,301,56)
	c:fill(true)
	--c:paint(255)
	--local old = g:find_child("tag")
	
	--c:new_path()
    --c:move_to(old.x,      old.y)
	--c:line_to(old.x+old.w,old.y)
	--c:line_to(old.x+old.w,old.y+old.h)
	--c:line_to(old.x,      old.y+old.h)
	--c:line_to(old.x,      old.y)
	
	--c:set_source_bitmap(Bitmap(old.source.src,false),old.x,old.y)
	--c:paint(255)--fill(true)
	c:set_source_bitmap(bmp.tag,48 ,bmp.shadow.h+14)
	c:paint(255)
	--old:unparent()
	
	local old = g:find_child("tag price")
	txt_to_canvas(c,old)
	old:unparent()
	
	--out with the old, in with the new
	g:find_child("Card BG Blit"):unparent()
	
	local img = c:Image{name="Card BG Blit",y=g.title_h-19}
	
	g:add(img)
	
	img:lower_to_bottom()
	--print("done")
end



--Card Constructor
local make_card = function(input)
	
	--the returned group
	local card = Group{w = bmp.card_bg.w}
	
	--the group's two animate functions
	card.update_time = update_time
	card.throb       = throb
	
	--Title portion of the card
	local title_text = Text{
		text = input.title,
		font = font_b.." 30px",
		color = white_text,
		x=53,
		y=title_padding,
		wrap=true,
	}
	
	local title_shadow = Text{
		text = input.title,
		font = font_b.." 30px",
		color = {0,0,0,255*.5},
		x=title_text.x+4,
		y=title_text.y+4,
		wrap=true,
	}
	
	title_text.w   = bmp.title_top.w-title_text.x*2
	title_shadow.w = title_text.w
    
	
	local slice_h = title_text.y+title_text.h+title_padding-bmp.title_top.h
	
	local title_h = bmp.title_top.h+slice_h
	
	--The Title Canvas
	local title = Canvas(bmp.card_bg.w,title_h+bmp.shadow.h)
	
	--add the background pieces to the title Canvas
	title:set_source_bitmap(bmp.title_top,0,0)
	title:paint(255)
	
	--tiling...
	for i = bmp.title_top.h, title_h, bmp.title_slice.h do
		title:set_source_bitmap(bmp.title_slice,0,i)
		title:paint(255)
	end
	
	title:set_source_bitmap(bmp.shadow,(bmp.card_bg.w - bmp.shadow.w)/2 ,title_h)
	title:paint(255*.5)
	
	txt_to_canvas(title,title_shadow)
	txt_to_canvas(title,title_text)
	
	----------------------------------------------------------------------------
	--the background Canvas
	local bg    = Canvas(bmp.card_bg.w,bmp.card_bg.h+bmp.shadow.h)
	
	--main bg
	bg:set_source_bitmap(bmp.card_bg,0,bmp.shadow.h)
	bg:paint(255)
	
	bg:save()
	bg:translate(bg.w,bmp.shadow.h)
	bg:rotate(180)
	bg:set_source_bitmap(bmp.shadow,(bmp.card_bg.w - bmp.shadow.w)/2 ,0)
	bg:paint(255*.5)
	bg:restore()
	---[[
	local tag = Clone{
		
		name = "tag",
		
		source=assets.tag,
		
		x=48,
		
		y=bmp.shadow.h+title_h+14,
		
	}
    --]]
	bg:set_source_bitmap(bmp.tag,48 ,bmp.shadow.h+14)
	bg:paint(255)
	
	card.glow = Clone{
		
		name = "GLOW",
		
		source=assets.btn_glow,
		
		x=tag.x+7,
		
		y=tag.y+7-bmp.shadow.h,
		
	}
	
	local na = Clone{
		
		name = "N/A",
		
		source=assets.n_a,
		
		opacity = 0,
		
		x=tag.x+15,
		
		y=tag.y-4,
		
	}
    
    --card.na = na
    
    
    
	
	card.hourglass = Clone{
		name   = "hourglass",
		source = assets.hourglass[1],
		x      = 117,
		y      = title_h+180
	}
	card.hourglass.x = card.hourglass.x - card.hourglass.w - 20
	
	local value = Text{
		text  = "Value",
		font  = font.." 16px",
		color = black_text,
		x     = 73,
		y     = bmp.shadow.h+116,
	}
	value.x=value.x+value.w/2
	value.anchor_point = {value.w/2,0}
	txt_to_canvas(bg,value)
	
	local value_amt = Text{
		text=input.msrp,
		font=font_b.." 20px",
		color = black_text,
		x = value.x,
		y = value.y+value.h,
	}
	value_amt.anchor_point = {value_amt.w/2,0}
	txt_to_canvas(bg,value_amt)
	
	local discount = Text{
		text="Discount",
		font=font.." 16px",
		color = black_text,
		x = value.x+value.w/2+25,
		y = value.y,
	}
	discount.x = discount.x + discount.w/2
	discount.anchor_point = {discount.w/2,0}
	txt_to_canvas(bg,discount)
	
	local discount_amt = Text{
		text=input.percentage.."%",
		font=font_b.." 20px",
		color = black_text,
		x = discount.x,
		y = discount.y+discount.h,
	}
	discount_amt.anchor_point = {discount_amt.w/2,0}
	txt_to_canvas(bg,discount_amt)
	
	local savings = Text{
		text="You Save",
		font=font.." 16px",
		color = black_text,
		x = discount.x+discount.w/2+15,
		y = value.y,
	}
	savings.x = savings.x + savings.w/2
	savings.anchor_point = {savings.w/2,0}
	txt_to_canvas(bg,savings)
	
	local savings_amt = Text{
		text=input.saved,
		font=font_b.." 20px",
		color = black_text,
		x = savings.x,
		y =savings.y+savings.h,
	}
	savings_amt.anchor_point = {savings_amt.w/2,0}
	txt_to_canvas(bg,savings_amt)
	
	local tltb = Text{
		text="Time Left To Buy",
		font=font.." 16px",
		color = black_text,
		x = 117,
		y = bmp.shadow.h+180,
	}
	txt_to_canvas(bg,tltb)
	
	local tltb_rem = Text{
		name="TIME",
		text="",
		font=font_b.." 20px",
		color = black_text,
		x = tltb.x,
		y = title_h+tltb.y+tltb.h-bmp.shadow.h,
	}
	
	local bought = Text{
		text=input.amount_sold.." bought",
		font=font_b.." 20px",
		color = black_text,
		x = 122,
		y = bmp.shadow.h+247,
	}
	bought.x=bought.x+bought.w/2
	bought.anchor_point = {bought.w/2,0}
	txt_to_canvas(bg,bought)
	
	local str
	if type(input.remaining) == "userdata" then
		str = "No Limit"
	elseif input.remaining <= 0 then
		str = "SOLD OUT"
		na.opacity = 255
		card.throb = empty
		card.update_time = empty
		card.glow.opacity = 0
		card.hourglass.source = assets.hourglass_soldout
		tltb_rem.text = "SOLD OUT"
	else
		str = input.remaining.." remaning"
	end
	local lim_quantity = Text{
		text=str,
		font=font.." 20px",
		color = black_text,
		x = bought.x,
		y = bought.y+bought.h,
	}
	lim_quantity.anchor_point = {lim_quantity.w/2,0}
	txt_to_canvas(bg,lim_quantity)
	
	local division = Text{
		text=input.division,
		font=font_b.." 18px",
		color = black_text,
		x = 550,
		--w = 582 - 303 - 15,
		ellipsize = "END",
		y = bg.h-74+16,
	}
    division.x = division.x - division.w
	txt_to_canvas(bg,division)
	
	local red_dot = Clone{
        source = assets.red_dot,
        x      = 562,
        y      = bmp.shadow.h+313+title_h
    }
	
	
	
	
	local tag_text = Text{
		name="tag text",
		text="More Info",
		font=font_b.." 26px",
		color = white_text,
		x = 81,
		y = tag.y+tag.h/2-1-bmp.shadow.h,
	}
	--tag_text.x = tag_text.x + tag_text.w/2
	tag_text.anchor_point = {0,tag_text.h/2}
	tag_text:move_anchor_point(tag_text.w/2,tag_text.h/2)
	
    function na:on_button_up()
        
        if App_State.state:current_state() == "ROLODEX" then
            
            if tag_text.text == "More Info" then
                KEY_HANDLER:key_press(keys.OK)
            else
                KEY_HANDLER:key_press(keys.BLUE)
            end
            
            return true
            
        end
        
    end
    
    
	local tag_price =  Text{
		name="tag price",
		text=input.price,
		font=font_b.." 26px",
		color = white_text,
		x = 301,
		y = bmp.shadow.h+tag_text.y-title_h,
	}
	tag_price.anchor_point = {tag_price.w,tag_price.h/2}
	
	local check = Clone{
		name = "CHECK",
		source = assets.check_red,
		x = 40,
		y = title_h+6,
		opacity = 0,
	}
	
	local deal_img       = Bitmap(input.picture_url,true)
	
	deal_img.on_loaded   = img_on_loaded
	deal_img.targ_canvas = bg
	deal_img.group       = card
	
	card.deal_img = deal_img
	
	
	
	card.exp = {isdst = "false"}
	card.exp.year,card.exp.month,card.exp.day,card.exp.hour,card.exp.min,card.exp.sec =
		string.match(input.expiration,"(%d*)-(%d*)-(%d*)T(%d*):(%d*):(%d*)")
	
	card.exp_secs = os.time(card.exp)
	--print(card.exp_secs)
	
	card.tz = input.tz/60/60
	
	--tltb_rem.anchor_point = {tltb_rem.w/2,0}
	
	
	---[[
	
	--]]
	
    local change_loc_btn = Clone{
        name   = "Change Loc Btn",--do not change name
        source = assets.change,
        x=556,
        y=316+title_h
    }
    change_loc_btn:hide()
    change_loc_btn:move_anchor_point(change_loc_btn.w/2,change_loc_btn.h/2)
	function change_loc_btn:on_enter()
        change_loc_btn.source               = assets.change_focus
        change_loc_btn.anchor_point         = {change_loc_btn.w/2,change_loc_btn.h/2}
        --mouse.to_mouse[change_loc_btn.show] = change_loc_btn
        --mouse.to_keys[change_loc_btn.hide]  = change_loc_btn
    end
    function change_loc_btn:on_leave()
        change_loc_btn.source               = assets.change
        change_loc_btn.anchor_point         = {change_loc_btn.w/2,change_loc_btn.h/2}
        --mouse.to_mouse[change_loc_btn.show] = nil
        --mouse.to_keys[change_loc_btn.hide]  = nil
    end
    
    function change_loc_btn:on_button_up()
        KEY_HANDLER:key_press(keys.RED)
        return true
    end
	local change_loc = Text{
		name="change location",
		text="Change Location",
		font=font_b.." 18px",
		color = "515b4c",
		x = 739,
		y = title_h+bg.h-74+16-bmp.shadow.h,
	}
	change_loc.anchor_point = {change_loc.w,0}
		
	--Values for the SMS Entry Object to pull
	card.fine_print = decode(input.fine_print)
	card.highlights = decode(gen_highlight(input.highlights))
	card.deal_url   = input.deal_url
	card.merchant   = input.merchant
	
	card.less_info = function(self)
		
        tag_text.text = "Less Info"
        tag_text.anchor_point = {tag_text.w/2,tag_text.h/2}
	end
    
    card.more_info = function(self)
		
        tag_text.text = "More Info"
        tag_text.anchor_point = {tag_text.w/2,tag_text.h/2}
	end
    
    card.sent = function(self)
		
		self.throb = empty
		
		tag_text.text = "Link Sent"
		
		self.glow.opacity = 0
		
		check.opacity = 255
		
		links_sent[input.id] = true
		
	end
	
	card.not_available = function(self)
		
        check.opacity     = 0
		
        self.glow.opacity = 0
		
        self.throb        = empty
        
		self.update_time  = empty
		
		na.opacity        = 255
		
	end
    
	local title_img = title:Image{name="Card Title Blit"}
    
	card.animate_in_sms  = function(self,msecs,p) title_img.y = -SMS_ENTRY.h*p     end
	
	card.animate_out_sms = function(self,msecs,p) title_img.y = -SMS_ENTRY.h*(1-p) end
	
	if links_sent[input.id] then card:sent() end
    
    
    function card:get_focus()
        change_loc_btn.reactive = true
        
        na.reactive = true
    end
    
    function card:lose_focus()
        change_loc_btn.reactive = false
        change_loc_btn.source = assets.change
        na.reactive = false
    end
    
    function card:to_mouse()
        red_dot:hide()
        change_loc:hide()
        change_loc_btn:show()
    end
    function card:to_keys()
        red_dot:show()
        change_loc:show()
        change_loc_btn:hide()
    end
    
    
    function card:fade_out_change_locs()
        change_loc_btn.reactive = false
        change_loc_btn.source = assets.change
        red_dot.opacity=255*.5
        change_loc.opacity=255*.5
        change_loc_btn.opacity=255*.5
    end
    function card:fade_in_change_locs()
        change_loc_btn.reactive = true
        red_dot.opacity=255
        change_loc.opacity=255
        change_loc_btn.opacity=255
    end
    
	card.title_h = title_h
	card.h = bg.h+(title_h-bmp.shadow.h)
	card:add(
		bg:Image{name="Card BG Blit",y=title_h-bmp.shadow.h},
		title_img,
		--deal_img,
		--tag,
		card.glow,
		tag_text,
		na,
		tag_price,
		check,
		--value,
		--value_amt,
		--discount,
		--discount_amt,
		--savings,
		--savings_amt,
		card.hourglass,
		--tltb,
		tltb_rem,
		--bought,
		--lim_quantity,
		--division,
		change_loc,
        red_dot,
        change_loc_btn
	)
	
	--table.insert(cards,card)
	--t:start()
	--tl:start()
	return card
	
end

return make_card