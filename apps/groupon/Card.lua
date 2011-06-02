local font   = "DejaVu Condensed"
local font_b = "DejaVu Condensed Bold"
local title_padding = 23
local white_text = "f4fce9"
local black_text = "333333"
local title_h = Text{text = "Hy",font = font_b.." 30px"}.h

local function throb(self,msecs,p)
	if self:find_child("GLOW") then
		
		self:find_child("GLOW").opacity=255*
			(.5+.5*math.cos(math.pi/180*360*p))
		
	end
end
local function empty() end


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

local img_on_loaded = function(b,failed)
	print("Bitmap",b)
	
	
	b.on_loaded = nil
	
	if failed then
		
		print("Failed to load from the internat. ")
		
		return
		
	end
	
	
	local c = b.targ_canvas
	local g = b.group
	
	g.deal_img = nil
	
	c:new_path()
    c:move_to(301,    37)
	c:line_to(301+439,37)
	c:line_to(301+439,37+266)
	c:line_to(301,    37+266)
	c:line_to(301,    37)
	c:set_source_bitmap(b,301,37)
	c:fill(true)
	--c:paint(255)
	local old = g:find_child("tag")
	
	--c:new_path()
    --c:move_to(old.x,      old.y)
	--c:line_to(old.x+old.w,old.y)
	--c:line_to(old.x+old.w,old.y+old.h)
	--c:line_to(old.x,      old.y+old.h)
	--c:line_to(old.x,      old.y)
	c:set_source_bitmap(Bitmap(old.source.src,false),old.x,old.y)
	c:paint(255)--fill(true)
	old:unparent()
	
	old = g:find_child("tag price")
	c:new_path()
	c:move_to(
		old.x - old.anchor_point[1],
		old.y - old.anchor_point[2]
	)
	c:text_element_path(old)
	c:set_source_color(old.color)
	c:fill(true)
	old:unparent()
	
	--out with the old, in with the new
	g:find_child("Card BG Blit"):unparent()
	
	local img = c:Image{name="Card BG Blit",y=g:find_child("Card Title Blit").h}
	
	g:add(img)
	
	img:lower_to_bottom()
	--print("done")
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
	local title = Canvas(bmp.card_bg.w,title_h)
	
	--add the background pieces to the title Canvas
	title:set_source_bitmap(bmp.title_top,0,0)
	title:paint(255)
	
	--tiling...
	for i = bmp.title_top.h, title_h, bmp.title_slice.h do
		title:set_source_bitmap(bmp.title_slice,0,i)
		title:paint(255)
	end
	
	txt_to_canvas(title,title_shadow)
	txt_to_canvas(title,title_text)
	
	----------------------------------------------------------------------------
	--the background Canvas
	local bg    = Canvas(bmp.card_bg.w,bmp.card_bg.h)
	
	--main bg
	bg:set_source_bitmap(bmp.card_bg,0,0)
	bg:paint(255)
	
	local tag = Clone{
		
		name = "tag",
		
		source=assets.tag,
		
		x=48,
		
		y=14,
		
	}
	
	local glow = Clone{
		
		name = "GLOW",
		
		source=assets.btn_glow,
		
		x=tag.x+5,
		
		y=title_h+tag.y+6,
		
	}
	
	local na = Clone{
		
		name = "N/A",
		
		source=assets.n_a,
		
		opacity = 0,
		
		x=tag.x+15,
		
		y=title_h+tag.y+15,
		
	}
	
	card.hourglass = Clone{
		name = "hourglass",
		source = assets.hourglass[1],
		x=117,
		y = title_h+180
	}
	card.hourglass.x = card.hourglass.x - card.hourglass.w - 20
	
	local value = Text{
		text="Value",
		font=font.." 16px",
		color = black_text,
		x = 73,
		y = 116,
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
		y = savings.y+savings.h,
	}
	savings_amt.anchor_point = {savings_amt.w/2,0}
	txt_to_canvas(bg,savings_amt)
	
	local tltb = Text{
		text="Time Left To Buy",
		font=font.." 16px",
		color = black_text,
		x = 117,
		y = 180,
	}
	txt_to_canvas(bg,tltb)
	
	local tltb_rem = Text{
		name="TIME",
		text="",
		font=font_b.." 20px",
		color = black_text,
		x = tltb.x,
		y = title_h+tltb.y+tltb.h,
	}
	
	local bought = Text{
		text=input.amount_sold.." bought",
		font=font_b.." 20px",
		color = black_text,
		x = 122,
		y = 247,
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
		glow.opacity = 0
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
		x = 303,
		w = 582 - 303-15,
		ellipsize = "END",
		y = bg.h-74,
	}
	txt_to_canvas(bg,division)
	
	
	bg:set_source_bitmap(bmp.red_dot,562,315)
	bg:paint(255)
	
	
	
	local tag_text = Text{
		name="tag text",
		text="More Info",
		font=font_b.." 26px",
		color = white_text,
		x = 81,
		y = title_h+tag.y+tag.h/2-1,
	}
	--tag_text.x = tag_text.x + tag_text.w/2
	tag_text.anchor_point = {0,tag_text.h/2}
	
	local tag_price =  Text{
		name="tag price",
		text=input.price,
		font=font_b.." 26px",
		color = white_text,
		x = 301,
		y = tag_text.y-title_h,
	}
	tag_price.anchor_point = {tag_price.w,tag_price.h/2}
	
	local check = Clone{
		name = "CHECK",
		source = assets.check_red,
		x = 40,
		y = title_h+6,
		opacity = 0,
	}
	
	print("before",input.picture_url)
	local deal_img       = Bitmap(input.picture_url,true)
	
	deal_img.on_loaded   = img_on_loaded
	deal_img.targ_canvas = bg
	deal_img.group       = card
	
	card.deal_img = deal_img
	print("after",deal_img,deal_img.loaded )
	
	
	
	card.exp = {isdst = "false"}
	card.exp.year,card.exp.month,card.exp.day,card.exp.hour,card.exp.min,card.exp.sec =
		string.match(input.expiration,"(%d*)-(%d*)-(%d*)T(%d*):(%d*):(%d*)")
	
	card.exp_secs = os.time(card.exp)
	--print(card.exp_secs)
	
	card.tz = input.tz/60/60
	
	--tltb_rem.anchor_point = {tltb_rem.w/2,0}
	
	
	---[[
	
	--]]
	
	
	local change_loc = Text{
		name="change location",
		text="Change Location",
		font=font_b.." 18px",
		color = "515b4c",
		x = 739,
		y = title_h+bg.h-74,
	}
	change_loc.anchor_point = {change_loc.w,0}
		
	--Values for the SMS Entry Object to pull
	card.fine_print = decode(input.fine_print)
	card.highlights = decode(gen_highlight(input.highlights))
	card.deal_url   = input.deal_url
	card.merchant   = input.merchant
	
	card.sent = function(self)
		
		self.throb = empty
		
		tag_text.text = "Link Sent"
		
		glow.opacity = 0
		
		check.opacity = 255
		
		links_sent[input.id] = true
		
	end
	
	card.not_available = function(self)
		check.opacity = 0
		glow.opacity = 0
		self.throb = empty
		self.update_time = empty
		
		na.opacity = 255
		
		--SMS_ENTRY
	end
	local title_img = title:Image{name="Card Title Blit"}
	card.animate_in_sms = function(self,msecs,p)
		title_img.y = -SMS_ENTRY.h*p
	end
	
	card.animate_out_sms = function(self,msecs,p)
		title_img.y = -SMS_ENTRY.h*(1-p)
	end
	
	if links_sent[input.id] then
		card:sent()
	end
	card.title_h = title_h
	card:add(
		bg:Image{name="Card BG Blit",y=title_h},
		title_img,
		--deal_img,
		tag,
		glow,
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
		change_loc
		--red_dot
	)
	
	--table.insert(cards,card)
	--t:start()
	--tl:start()
	return card
	
end

return make_card