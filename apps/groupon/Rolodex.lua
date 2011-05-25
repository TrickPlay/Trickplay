--local top_card = 1
local r_pos
local function flip_forward(self,msecs,p)
	
	for i,c in ipairs(self.cards) do
		
		if i == (self.top_card - 2) % #self.cards + 1 then
            
            c.x_rotation={-90*(1-p),0,0}
            
        else
            
            r_pos = (i - self.top_card) % #self.cards
            
            c.x_rotation={270*(r_pos + p) / #self.cards,0,0}
            
        end
	end
	
	if p == 1 then
		
        self.visible_cards[self.top_card] = nil
        
		self.top_card = self.top_card - 1
		
		if self.top_card < 1 then
			
			self.top_card = #self.cards
			
		end
        
        --self.cards[(top_card - 2) % #self.cards + 1]:raise_to_top()
        
        self.flipping = false
		
	end
	
end
local function pre_forward_flip(self)
    
    self.cards[(self.top_card - 2) % #self.cards + 1]:raise_to_top()
    
    self.visible_cards[(self.top_card - 2) % #self.cards + 1] = true
    
    self.cards[(self.top_card - 2) % #self.cards + 1]:update_time(os.date('*t'))
end

local function flip_backward(self,msecs,p)
	
	for i,c in ipairs(self.cards) do
		
		if i == self.top_card then
            
            c.x_rotation={-90*p,0,0}
            
        else
            
            r_pos = (i - self.top_card) % #self.cards
            
            c.x_rotation={270*(r_pos - p) / #self.cards,0,0}
            
        end
        
	end
	
	
	
    if p == 1 then
		
        self.visible_cards[self.top_card] = nil
        
		self.top_card = self.top_card + 1
		
		if self.top_card > #self.cards then
			
			self.top_card = 1
			
		end
        
        self.flipping = false
        
	end
    
end

local function pre_backward_flip(self)
    
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
    
    t = os.date('*t')
    
    for i,_ in pairs(App_State.rolodex.visible_cards) do
        
        App_State.rolodex.cards[i]:update_time(t)
        
    end
    
end


--ROLODEX CONSTRUCTOR
return function(response_table)
    
    --upvals: card, deal, rolodex
    local c, d
    
    --grab pre-existing rolodex, if any
    --r = screen:find_child("Rolodex")
    
    --if not, create
    if App_State.rolodex == nil then
        
        App_State.rolodex = Group{name="Rolodex", x= 450, y=screen_h}
        
        --increments the seconds counter
        App_State.rolodex.time = Timer{interval=1000,on_timer=update_times}
        
        App_State.rolodex.throb_cards = throb_cards
        
        screen:add(App_State.rolodex)
        
        KEY_HANDLER:add_keys("ROLODEX",{
    --Flip Backward
	[keys.Down] = function()
		
        if not App_State.rolodex.flipping then
            
			App_State.rolodex:pre_backward_flip()
			
            Idle_Loop:add_function(
                App_State.rolodex.flip_backward,
                App_State.rolodex,
                1000
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
                1000
            )
			
            App_State.rolodex.flipping = true
        end
        
		--dumptable(r.visible_cards)
	end,})
    --else, reset
    else
        
        Idle_Loop:remove_function(App_State.rolodex.throb_cards)
        
        App_State.rolodex.time:stop()
        
        App_State.rolodex:clear()
        
        
        
    end
    
    App_State.rolodex.top_card = 1
    
    --dumptable(response_table.deals)
    App_State.rolodex.cards = {}
    App_State.rolodex.visible_cards = {}
    
    local tot = #response_table.deals
    
    local divs = {}
    
    for i = 1, tot do
        
        d = response_table.deals[i]
        
        --pass the card constructor all of the important aspects of the deal information
        c = Card_Constructor{
            title         = d.title,
            division      = d.division.name,
            price         = "$"..d.options[1].price.amount/100,
            msrp          = "$"..d.options[1].value.amount/100,
            percentage    = d.options[1].discountPercent,
            saved         = "$"..d.options[1].discount.amount/100,
            expiration    = d.endAt,
            amount_sold   = d.options[1].soldQuantity,
            picture_url   = d.largeImageUrl,
            fine_print    = d.options[1].details[1].description,
            highlights    = d.highlightsHtml,
            id            = d.id,
            deal_url      = d.dealUrl,
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
    --[[
    Zip.list_locations(divs)
    
    if Zip.parent then Zip:unparent() end
    
    App_State.rolodex:add(Zip)
    
    Zip.prompt_is_up = true
    
    Zip.timer:start()
    
    Zip.y = -App_State.rolodex.cards[1].h
    
    Zip:lower_to_bottom()
    --]]
    
    if ZIP_PROMPT.parent then ZIP_PROMPT:unparent() end
    
    if ZIP_ENTRY.parent  then ZIP_ENTRY:unparent()  end

    if SMS_ENTRY.parent  then SMS_ENTRY:unparent()  end    
    
    
    App_State.rolodex:add(SMS_ENTRY,ZIP_PROMPT,ZIP_ENTRY)
    
    ZIP_PROMPT:set_city(divs)
    
    ZIP_PROMPT:lower_to_bottom()
    
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
    
end