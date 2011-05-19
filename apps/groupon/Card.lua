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




local delta = {}
local update_time = function(self,curr_time)
	--curr=os.date('*t')
	
	--for _,c in ipairs(cards) do
		
	delta.year  = self.exp.year  - curr_time.year
	delta.month = self.exp.month - curr_time.month
	delta.day   = self.exp.day   - curr_time.day
	delta.hour  = self.exp.hour  - curr_time.hour
	delta.min   = self.exp.min   - curr_time.min
	delta.sec   = self.exp.sec   - curr_time.sec
	
	if delta.sec < 0 then
		delta.sec = delta.sec + 60
		delta.min = delta.min - 1
	end
	if delta.min < 0 then
		delta.min  = delta.min + 60
		delta.hour = delta.hour - 1
	end
	if delta.hour < 0 then
		delta.hour = delta.hour + 24
		delta.day  = delta.day - 1
	end
	if delta.day < 0 then
		delta.day   = delta.day + 30
		delta.month = delta.month - 1
	end
	if delta.month < 0 then
		delta.month   = delta.month + 12
		delta.year = delta.year - 1
	end
	if delta.year < 0 then
		self:find_child("TIME").text="EXPIRED"
	else
		
		local day = (30*delta.month+delta.day)
		
		local str = ""
		
		if day > 1 then
			str = str..day.." days "
		elseif day == 1 then
			str = str..day.." day "
		elseif day ~= 0 then
			error("IMPOSSSIBLE!?!?!?!?!?!?!?!")
		end
		
		str = str..string.format("%02d",delta.hour)..
			":"..string.format("%02d",delta.min)..
			":"..string.format("%02d",delta.sec)
		
		self:find_child("TIME").text = str
		self:find_child("TIME").anchor_point = {self:find_child("TIME").w/2,0}
	end
end

local make_card = function(input)
	
	local card = Group{}
	
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
	
    card.title_h = title_text.h
    
	local title_shadow = Text{
		text = input.title,
		font = font_b.." 30px",
		color = "000000",
		opacity = 255*.5,
		x=title_text.x+4,
		y=title_text.y+4,
		wrap=true,
	}
	
	local title_bg_top   = Clone{
		
		source=assets.title_top
		
	}
	title_text.w=title_bg_top.w-title_text.x*2
	title_shadow.w=title_bg_top.w-title_text.x*2
	local title_bg_slice = Clone{
		
		source=assets.title_slice,
		
		y=title_bg_top.y+title_bg_top.h,
		
	}
	
	title_bg_slice.h = title_text.y+title_text.h+title_padding-title_bg_slice.y
	
	
	card:add(
		
		title_bg_top,
		
		title_bg_slice,
		
		title_shadow,
		
		title_text
	)
	
	--Body portion of the card
	local bg = Clone{
		
		source=assets.bg,
		
		y=title_bg_slice.y+title_bg_slice.h
		
	}
	
	
	local tag = Clone{
		
		source=assets.tag,
		
		x=48,
		
		y=bg.y+24,
		
	}
	
	local glow = Clone{
		
		name = "GLOW",
		
		source=assets.btn_glow,
		
		x=tag.x+5,
		
		y=tag.y+6,
		
	}
	
	local tag_text = Text{
		name="TAG_TEXT",
		text="More Info",
		font=font_b.." 26px",
		color = white_text,
		x = 81,
		y = tag.y+tag.h/2-1,
	}
	--tag_text.x = tag_text.x + tag_text.w/2
	tag_text.anchor_point = {0,tag_text.h/2}
	
	local tag_price =  Text{
		text=input.price,
		font=font_b.." 26px",
		color = white_text,
		x = 301,
		y = tag_text.y,
	}
	tag_price.anchor_point = {tag_price.w,tag_price.h/2}
	
	local check = Clone{
		name = "CHECK",
		source = assets.check_red,
		x = 40,
		y = bg.y+16,
		opacity = 0,
	}
	
	local deal_img = Image{
		src=input.picture_url,
		async = true,
		x = 301,
		y = bg.y+47,
		on_loaded = function(self,failed)
			if failed then
				print("THE IMAGE ",self.src," FAILED TO LOAD")
			end
		end
	}
	
	
	local value = Text{
		text="Value",
		font=font.." 16px",
		color = black_text,
		x = 73,
		y = bg.y+129,
	}
	value.x=value.x+value.w/2
	value.anchor_point = {value.w/2,0}
	
	local value_amt = Text{
		text=input.msrp,
		font=font_b.." 20px",
		color = black_text,
		x = value.x,
		y = value.y+value.h,
	}
	value_amt.anchor_point = {value_amt.w/2,0}
	
	local discount = Text{
		text="Discount",
		font=font.." 16px",
		color = black_text,
		x = value.x+72,
		y = value.y,
	}
	discount.anchor_point = {discount.w/2,0}
	
	local discount_amt = Text{
		text=input.percentage.."%",
		font=font_b.." 20px",
		color = black_text,
		x = discount.x,
		y = discount.y+discount.h,
	}
	discount_amt.anchor_point = {discount_amt.w/2,0}
	
	local savings = Text{
		text="You Save",
		font=font.." 16px",
		color = black_text,
		x = discount.x+72,
		y = value.y,
	}
	savings.anchor_point = {savings.w/2,0}
	
	local savings_amt = Text{
		text=input.saved,
		font=font_b.." 20px",
		color = black_text,
		x = savings.x,
		y = savings.y+savings.h,
	}
	savings_amt.anchor_point = {savings_amt.w/2,0}
	
	local tltb = Text{
		text="Time Left To Buy",
		font=font.." 16px",
		color = black_text,
		x = 122,
		y = bg.y+197,
	}
	tltb.x=tltb.x+tltb.w/2
	tltb.anchor_point = {tltb.w/2,0}
	
	
	card.exp = {}
	card.exp.year,card.exp.month,card.exp.day,card.exp.hour,card.exp.min,card.exp.sec =
		string.match(input.expiration,"(%d*)-(%d*)-(%d*)T(%d*):(%d*):(%d*)")
	
	local tltb_rem = Text{
		name="TIME",
		text="Value",
		font=font_b.." 20px",
		color = black_text,
		x = tltb.x,
		y = tltb.y+tltb.h,
	}
	tltb_rem.anchor_point = {tltb_rem.w/2,0}
	
	local bought = Text{
		text=input.amount_sold.." bought",
		font=font_b.." 18px",
		color = black_text,
		x = 110,
		y = bg.y+265,
	}
	bought.x=bought.x+bought.w/2
	bought.anchor_point = {bought.w/2,0}
	
	local lim_quantity = Text{
		text="Limited quantity available",
		font=font.." 12px",
		color = black_text,
		x = bought.x,
		y = bought.y+bought.h,
	}
	lim_quantity.anchor_point = {lim_quantity.w/2,0}
	
	local merchant = Text{
		text=input.merchant_name,
		font=font.." 18px",
		color = black_text,
		x = 303,
		y = bg.y+bg.h-64,
	}
	
	card.fine_print = decode(input.fine_print)
	card.highlights = decode(gen_highlight(input.highlights))
	card.id         = input.id
	card.deal_url   = input.deal_url
	
	card.sent = function(self)
		
		self.throb = empty
		
		tag_text.text = "Link Sent"
		
		glow.opacity = 0
		
		check.opacity = 255
	end
	
	
	card:add(
		bg,
		deal_img,
		tag,
		glow,
		tag_text,
		tag_price,
		check,
		value,
		value_amt,
		discount,
		discount_amt,
		savings,
		savings_amt,
		tltb,
		tltb_rem,
		bought,
		lim_quantity,
		merchant
	)
	
	--table.insert(cards,card)
	--t:start()
	--tl:start()
	return card
	
end

return make_card