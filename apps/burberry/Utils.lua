

imgs = {
	box_foc_corner = "assets/focus-corner.png",
	box_foc_side = "assets/focus-edge.png",
	cursor = "assets/cursor.png",
	fp={
		foc_end = "assets/btn-end.png",
		foc_mid = "assets/btn-mid.png",
		arrow   = "assets/arrow.png"
		--[=[
		tiles = {
			"assets/tile-main-womes1.png",
			"assets/tile-main-mens1.png",
			"assets/tile-main-beauty1.png",
			"assets/tile-main-biker1a.png",
		},
		left_pane = "assets/main-bg-frame.jpg"
		--]=]
	}
}
--[[
local clone_sources_group = Group{name="clone sources"}
local clone_sources_table = {}

screen:add(clone_sources_group)
clone_sources_group:hide()

--save the function pointer to the old Clone constructor
local TP_Clone = Clone
local TP_Image = Image
--Image = nil
--local deletion_spy
--The new Clone Constructor
Clone = function(t)
	
	--must be created the same way you typically create Clones
	assert(type(t) == "table","Clone receives a table as its parameter,"..
		" received a parameter of type "..type(t))
    if t.source == nil then
        dumptable(t)
        error("Clone requires a source")
    end
	
	
	--If an asset has not been loaded in yet, then load it
	if clone_sources_table[t.source] == nil then
		
		clone_sources_table[t.source] = TP_Image{src=t.source,extra={count=0}}
		
		clone_sources_group:add(clone_sources_table[t.source])
		
	end
	
	
	clone_sources_table[t.source].count = clone_sources_table[t.source].count+1
	
	--print("I HAVE THIS MANY",clone_sources_table[t.source].count)
	
	local deletion_spy = newproxy(true)
	
	local sauce = t.source
	
	getmetatable( deletion_spy ).__gc = function()
		
		clone_sources_table[sauce].count = clone_sources_table[sauce].count - 1
		
		--print("DECREMENTTTTTT",clone_sources_table[sauce].count)
		
		if clone_sources_table[sauce].count == 0 then
			
			clone_sources_table[sauce]:unparent()
			
			clone_sources_table[sauce] = nil
			
		end
	end
	
	--replace the string with the UI_Element
	t.source = clone_sources_table[t.source]
	
	
	--return a Clone
	t= TP_Clone(t)
	
	t.deletion_spy = deletion_spy

	return t
end
--]]