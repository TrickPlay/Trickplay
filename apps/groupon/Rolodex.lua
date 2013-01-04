--local top_card = 1

local r_pos, flip_on_completed

local function flip_forward(self,msecs,p)
	
    if not self.flipping then print("flip_forward double on_completed, TELL ALEX IF THIS HAPPENS") return end
    
	for i,c in ipairs(self.cards) do
		
		if i == (self.top_card - 2) % #self.cards + 1 then
            
            c.x_rotation={-90*(1-p),0,0}
            
        else
            
            r_pos = (i - self.top_card) % #self.cards
            
            c.x_rotation={270*(r_pos + p) / #self.cards,0,0}
            
        end
	end
	
	if p == 1 then
		
        App_State.rolodex.cards[App_State.rolodex.top_card]:find_child("change location").text = "Change location"
        
        self.visible_cards[self.top_card] = nil
        
		self.top_card = self.top_card - 1
		
		if self.top_card < 1 then
			
			self.top_card = #self.cards
			
		end
        
        self.cards[self.top_card]:get_focus()
        
        --self.cards[(top_card - 2) % #self.cards + 1]:raise_to_top()
        
        self.flipping = false
		
        if flip_on_completed then
            dolater(function()
                flip_on_completed()
                flip_on_completed = nil
            end)
        end
        --print("post_forward_flip",self.top_card)
	end
	
end

local next_card

local function pre_forward_flip(self)
    --print("pre_forward_flip",self.top_card," raised & next ",(self.top_card - 2) % #self.cards + 1,"\n",self.cards[(self.top_card - 2) % #self.cards + 1].name,"\n")
    self.cards[self.top_card]:lose_focus()
    
    next_card = (self.top_card - 2) % #self.cards + 1
    
    self.cards[  next_card  ]:raise_to_top()
    
    self.visible_cards[  next_card  ] = true
    
    self.cards[  next_card  ]:update_time(os.date('*t'))
end

local function flip_backward(self,msecs,p)
	
    if not self.flipping then print("flip_backward double on_completed, TELL ALEX IF THIS HAPPENS") return end
	
	for i,c in ipairs(self.cards) do
		
		if i == self.top_card then
            
            c.x_rotation={-90*p,0,0}
            
        else
            
            r_pos = (i - self.top_card) % #self.cards
            
            c.x_rotation={270*(r_pos - p) / #self.cards,0,0}
            
        end
        
	end
	
	
	
    if p == 1 then
		
        App_State.rolodex.cards[App_State.rolodex.top_card]:find_child("change location").text = "Change location"
        
        self.visible_cards[self.top_card] = nil
        
		self.top_card = self.top_card + 1
		
		if self.top_card > #self.cards then
			
			self.top_card = 1
			
		end
        
        self.cards[self.top_card]:get_focus()
        
        self.flipping = false
		
        if flip_on_completed then
            dolater(function()
                flip_on_completed()
                flip_on_completed = nil
            end)
        end
        --print("post_backward_flip",self.top_card)
	end
    
end

local function pre_backward_flip(self)
    --print("pre_backward_flip, curr ",self.top_card," lowered ",(self.top_card - 2) % #self.cards + 1," next ",self.top_card % #self.cards + 1,"\n",self.cards[(self.top_card) % #self.cards + 1].name,"\n")
    self.cards[self.top_card]:lose_focus()
    
    self.cards[(self.top_card - 2) % #self.cards + 1]:lower_to_bottom()
    
    self.visible_cards[self.top_card % #self.cards + 1] = true
    
    self.cards[self.top_card % #self.cards + 1]:update_time(os.date('*t'))
    
end


local function throb_cards(self,msecs,p)
    
    for i,_ in pairs(self.visible_cards) do
        
        self.cards[i]:throb(msecs,p)
        
    end
    
end

--upval
local t

local function update_times(self)
    
    t = os.date('!*t')
    --[[
    if os.date('*t').isdst then
        
        t.hour = t.hour + 1
        
        t = os.date('*t',os.time(t))
        
    end
    --]]
    --t.min = t.min + 41
    --t.day = t.day 
    --t.hour = t.hour - 1+13
    --print("\n\n")
    --dumptable(t)
    for i,_ in pairs(App_State.rolodex.visible_cards) do
        
        App_State.rolodex.cards[i]:update_time(t)
        
    end
    
end



--ROLODEX CONSTRUCTOR
return function(response_table)
    
    --upvals: card, deal, rolodex
    local c, d
    --print('make')
    if response_table == false then
        
        Loading_G:message("Having trouble connecting")
        
        return
        
    end
    
    --if not, create
    if App_State.rolodex == nil then
        
        App_State.rolodex = Group{name="Rolodex", x= 450, y=screen_h}
        
        --increments the seconds counter
        App_State.rolodex.time = Timer{interval=1000,on_timer=update_times}
        
        App_State.rolodex.throb_cards = throb_cards
        
        screen:add(App_State.rolodex)
        
        mouse:raise_to_top()
        
        KEY_HANDLER:add_keys("ROLODEX",
            {
                --Flip Backward
                [keys.Down] = function()
                    
                    if not App_State.rolodex.flipping then
                        
                        App_State.rolodex:pre_backward_flip()
                        
                        Idle_Loop:add_function(
                            App_State.rolodex.flip_backward,
                            App_State.rolodex,
                            500
                        )
                        
                        App_State.rolodex.flipping = true
                    end
                    
                end,
                
                --Flip Forward
                [keys.Up] = function()
                    
                    if not App_State.rolodex.flipping then
                        
                        App_State.rolodex:pre_forward_flip()
                        
                        Idle_Loop:add_function(
                            App_State.rolodex.flip_forward,
                            App_State.rolodex,
                            500
                        )
                        
                        App_State.rolodex.flipping = true
                    end
                    
                end,
            }
        )
        
        App_State.rolodex.scroll_up = function(self)
            
            if not App_State.rolodex.flipping then
                
                App_State.rolodex:pre_forward_flip()
                
                Idle_Loop:add_function(
                    App_State.rolodex.flip_forward,
                    App_State.rolodex,
                    500
                )
                
                App_State.rolodex.flipping = true
                
            else
                
                Idle_Loop:modify_duration(
                    App_State.rolodex.flip_forward,
                    200
                )
                
                flip_on_completed = function()
                    
                    App_State.rolodex:pre_forward_flip()
                    
                    Idle_Loop:add_function(
                        App_State.rolodex.flip_forward,
                        App_State.rolodex,
                        500
                    )
                    
                    App_State.rolodex.flipping = true
                end
            end
        end
        
        App_State.rolodex.scroll_dn = function(self)
            
            if not App_State.rolodex.flipping then
                
                App_State.rolodex:pre_backward_flip()
                
                Idle_Loop:add_function(
                    App_State.rolodex.flip_backward,
                    App_State.rolodex,
                    500
                )
                
                App_State.rolodex.flipping = true
                
            else
                
                Idle_Loop:modify_duration(
                    App_State.rolodex.flip_backward,
                    200
                )
                
                flip_on_completed = function()
                    
                    App_State.rolodex:pre_backward_flip()
                    
                    Idle_Loop:add_function(
                        App_State.rolodex.flip_backward,
                        App_State.rolodex,
                        500
                    )
                    
                    App_State.rolodex.flipping = true
                end
            end
        end
        
        App_State.rolodex.to_mouse = function()
            for _,c in pairs(App_State.rolodex.cards) do
                c:to_mouse()
            end
        end
        
        mouse.to_mouse[App_State.rolodex.to_mouse] = true
        
        App_State.rolodex.to_keys = function()
            for _,c in pairs(App_State.rolodex.cards) do
                c:to_keys()
            end
        end
        
        mouse.to_keys[App_State.rolodex.to_keys] = true
        
    else
        
        Idle_Loop:remove_function(App_State.rolodex.throb_cards)
        
        App_State.rolodex.time:stop()
        
        App_State.rolodex:clear()
        
    end
    
    App_State.rolodex.top_card = 1
    
    --dumptable(response_table.deals)
    App_State.rolodex.cards = {}
    App_State.rolodex.visible_cards = {}
    
    local tot = math.min(#response_table.deals,10)
    
    local divs = {}
    
    for i = 1, tot do
        
        d = response_table.deals[i]
        
        if d.status ~= "closed" then 
            
            local lowest_price   = d.options[1].price.amount
            local lowest_price_i = 1
            
            for i,option in ipairs(d.options) do
                
                if lowest_price > option.price.amount then
                    
                    lowest_price = option.price.amount
                    
                    lowest_price_i = i
                    
                end
                
            end
            
            --pass the card constructor all of the important aspects of the deal information
            c = Card_Constructor{
                --Card Data
                title         = d.title or "Groupon Deal",
                division      = d.division and d.division.name or "",
                --Pricing
                price         = (d.options[lowest_price_i] and d.options[lowest_price_i].price and "$"..d.options[lowest_price_i].price.amount/100 or ""),
                msrp          = (d.options[lowest_price_i].value and "$"..d.options[lowest_price_i].value.amount/100 or ""),
                percentage    = (d.options[lowest_price_i].discountPercent.."%" or ""),
                saved         = (d.options[lowest_price_i].discount and "$"..d.options[lowest_price_i].discount.amount/100 or ""),
                --Timer
                expiration    = d.endAt ~= json.null and d.endAt or d.options[lowest_price_i].expiresAt or json.null,
                tz            = d.division.timezoneOffsetInSeconds or json.null,
                --Amount Sold
                amount_sold   = d.soldQuantity      or d.options[lowest_price_i].soldQuantity or "0",
                sold_out      = choose(d.isSoldOut         ~= nil, d.isSoldOut, choose(d.options[lowest_price_i].isSoldOut~= nil,d.options[lowest_price_i].isSoldOut,false)),
                limit         = choose(d.isLimitedQuantity ~= nil, d.isLimitedQuantity, choose(d.options[lowest_price_i].isLimitedQuantity~= nil,d.options[lowest_price_i].isLimitedQuantity,false)),
                
                picture_url   = choose(d.largeImageUrl~=nil,d.largeImageUrl, false),
                id            = choose(d.id~=nil,d.id, false),
                
                --SMS Menu needs these
                fine_print    = d.options[lowest_price_i].details and d.options[lowest_price_i].details[1].description or "",
                highlights    = d.highlightsHtml or "",
                merchant      = d.merchant.name or "",
                deal_url      = choose(d.dealUrl~=nil,d.dealUrl, false),
            }
            table.insert( App_State.rolodex.cards, c )
            
            if divs[d.division.name] then
                
                divs[d.division.name] = divs[d.division.name] + 1
                
            else
                
                divs[d.division.name] = 1
                
            end
            
            c.anchor_point={c.w/2,c.h}
            
            c.x_rotation={270*(i-1)/tot,0,0}
            
            App_State.rolodex:add(c)
            
            c:lower_to_bottom()
            
        end
        
    end
    
    if not using_keys then App_State.rolodex.to_mouse() end
    
    --[[
    Zip.list_locations(divs)
    
    if Zip.parent then Zip:unparent() end
    
    App_State.rolodex:add(Zip)
    
    Zip.prompt_is_up = true
    
    Zip.timer:start()
    
    Zip.y = -App_State.rolodex.cards[1].h
    
    Zip:lower_to_bottom()
    --]]
    
    --if CONTOLLER_PROMPT.parent then CONTOLLER_PROMPT:unparent() end
    
    --if ZIP_ENTRY.parent  then ZIP_ENTRY:unparent()  end

    --if SMS_ENTRY.parent  then SMS_ENTRY:unparent()  end    
    
    
   -- App_State.rolodex:add(--[[CONTOLLER_PROMPT,]] ZIP_ENTRY)
    
    --ZIP_PROMPT:set_city(divs)
    
    --CONTOLLER_PROMPT:lower_to_bottom()
    
    --only the first card is visible
    App_State.rolodex.visible_cards[1] = true
    
    print("made a ROLODEX with ",#App_State.rolodex.cards," CARDS")
    
    --reference to flip functions
    App_State.rolodex.flip_forward  = flip_forward
    
    App_State.rolodex.flip_backward = flip_backward
    
    --reference to flip setup functions
    App_State.rolodex.pre_forward_flip  = pre_forward_flip
    
    App_State.rolodex.pre_backward_flip = pre_backward_flip
    
    --if there is only one card, lock the UP and DOWN keys
    if #App_State.rolodex.cards == 1 then
        App_State.rolodex.flipping = true
    else
        App_State.rolodex.flipping = false
    end
    
    App_State.rolodex.time:start()
    
    Idle_Loop:add_function(App_State.rolodex.throb_cards,App_State.rolodex,3000,true)
    
    --fade out the loading animation
    Idle_Loop:add_function(Loading_G.fade_out,Loading_G,500)
    
    
    --ROLODEX is ready, change state
    App_State.state:change_state_to("ROLODEX")
    
    App_State.rolodex.cards[App_State.rolodex.top_card]:get_focus()
    
end