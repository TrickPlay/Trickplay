local top_card = 1
local r_pos
local function flip_forward(self,msecs,p)
	
	for i,c in ipairs(self.cards) do
		
		if i == (top_card - 2) % #self.cards + 1 then
            
            c.x_rotation={-90*(1-p),0,0}
            
        else
            
            r_pos = (i - top_card) % #self.cards
            
            c.x_rotation={270*(r_pos + p) / #self.cards,0,0}
            
        end
	end
	
	if p == 1 then
		
        self.visible_cards[top_card] = nil
        
		top_card = top_card - 1
		
		if top_card < 1 then
			
			top_card = #self.cards
			
		end
        
        --self.cards[(top_card - 2) % #self.cards + 1]:raise_to_top()
        
        self.flipping = false
		
	end
	
end
local function pre_forward_flip(self)
    
    self.cards[(top_card - 2) % #self.cards + 1]:raise_to_top()
    
    self.visible_cards[(top_card - 2) % #self.cards + 1] = true
    
    self.cards[(top_card - 2) % #self.cards + 1]:update_time(os.date('*t'))
end

local function flip_backward(self,msecs,p)
	
	for i,c in ipairs(self.cards) do
		
		if i == top_card then
            
            c.x_rotation={-90*p,0,0}
            
        else
            
            r_pos = (i - top_card) % #self.cards
            
            c.x_rotation={270*(r_pos - p) / #self.cards,0,0}
            
        end
        
	end
	
	
	
    if p == 1 then
		
        self.visible_cards[top_card] = nil
        
		top_card = top_card + 1
		
		if top_card > #self.cards then
			
			top_card = 1
			
		end
        
        --self.cards[(top_card - 3) % #self.cards + 1]:lower_to_bottom()
        --self.cards[top_card]:raise_to_top()
        
        self.flipping = false
        
	end
    
end

local function pre_backward_flip(self)
    
    self.cards[(top_card - 2) % #self.cards + 1]:lower_to_bottom()
    
    self.visible_cards[top_card % #self.cards + 1] = true
    
    self.cards[top_card % #self.cards + 1]:update_time(os.date('*t'))
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
    
    for i,_ in pairs(self.parent.visible_cards) do
        
        self.parent.cards[i]:update_time(t)
        
    end
    
end


--ROLODEX CONSTRUCTOR
return function(response_table)
    
    --upvals: card, deal, rolodex
    local c, d, r
    
    --grab pre-existing rolodex, if any
    r = screen:find_child("Rolodex")
    
    --if not, create
    if r == nil then
        
        r = Group{name="Rolodex", x= 450, y=screen_h}
        
        screen:add(r)
        
    --else, reset
    else
        
        r:clear()
        
        top_card = 1
        
    end
    --dumptable(response_table.deals)
    r.cards = {}
    r.visible_cards = {}
    
    local tot = #response_table.deals
    
    local divs = {}
    
    for i = 1, tot do
        
        d = response_table.deals[i]
        
        --pass the card constructor all of the important aspects of the deal information
        c = Card_Constructor{
            title         = d.title,
            merchant_name = d.merchant.name,
            price         = "$"..d.options[1].price.amount/100,
            msrp          = "$"..d.options[1].value.amount/100,
            percentage    = d.options[1].discountPercent,
            saved         = "$"..d.options[1].discount.amount/100,
            expiration    = d.endAt,
            amount_sold   = d.options[1].soldQuantity,
            picture_url   = d.largeImageUrl,
        }
        
        table.insert( r.cards, c )
        
        if divs[d.division.name] then
            
            divs[d.division.name] = divs[d.division.name] + 1
            
        else
            
            divs[d.division.name] = 1
            
        end
        
        c.anchor_point={c.w/2,c.h}
		
		c.x_rotation={270*(i-1)/tot,0,0}
        
        r:add(c)
        
        c:lower_to_bottom()
    end
    
    Zip.list_locations(divs)
    
    if Zip.parent then Zip:unparent() end
    
    r:add(Zip)
    
    Zip.is_up = true
    
    Zip.timer:start()
    
    Zip.y = -r.cards[1].h
    
    --only the first card is visible
    r.visible_cards[1] = true
    
    print("made a ROLODEX with ",#r.cards," CARDS")
    
    --reference to flip functions
    r.flip_forward  = flip_forward
    
    r.flip_backward = flip_backward
    
    --reference to flip setup functions
    r.pre_forward_flip  = pre_forward_flip
    
    r.pre_backward_flip = pre_backward_flip
    
    --if there is only one card, lock the UP and DOWN keys
    if #r.cards == 1 then r.flipping = true
    else                  r.flipping = false end
    
    --increments the seconds counter
    r.time = Timer{interval=1000,on_timer=update_times}
    
    r.time.parent = r
    
    r.time:start()
    
    r.throb_cards = throb_cards
    
    Idle_Loop:add_function(r.throb_cards,r,1000,true)
    
    --fade out the loading animation
    Idle_Loop:add_function(Loading_G.fade_out,Loading_G,500)
    
    
    --ROLODEX is ready, change state
    App_State:change_state_to(STATES.ROLODEX)
    
end