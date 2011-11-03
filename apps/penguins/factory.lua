local group = Group()
group:hide()
screen:add(group)

return function(src,func)
	local orig = _Image{src = "assets/" .. src}
	group:add(orig)
	
	local clones = {}
	
	return function(def)
		local ret
		for i=1,#clones do
			if clones[i].freed then
				ret = clones[i]
				break
			end
		end
		
		if not ret then
			clones[#clones+1] = _Clone{source = orig}
			ret = clones[#clones]
			ret.free = function(self)
				self.freed = true
				self:unparent()
			end
		end
		
		def.source = nil
		def.src = nil
		
		for k,v in pairs(def) do
			ret[k] = v
		end
		
		if func then
			func(ret)
		end
		
		ret.freed = false
		
		return ret
	end
end