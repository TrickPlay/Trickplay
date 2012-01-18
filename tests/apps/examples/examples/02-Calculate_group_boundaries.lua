-- Calculate the width and height of myGroup's boundary
function calculateBoundary( myGroup )
	local width, height = 0, 0
	local minX, maxX, minY, maxY = nil, nil, nil, nil
	local children = myGroup.children  -- use local version for efficiency

	-- Cycle through each object in myGroup
	for _,child in ipairs( children ) do
		-- Is this the right-most edge so far?
		if( minX == nil ) or (child.x < minX ) then
		  -- Yes, store it
		  minX = child.x
		end
		
		-- Is this the left-most edge so far?
		if( maxX == nil ) or (child.x + child.width > maxX ) then
		  -- Yes, store it
		  maxX = child.x + child.width
		end

		-- Is this the top-most edge so far?
		if( minY == nil ) or (child.y < minY ) then
		  -- Yes, store it
		  minY = child.y
		end

		-- Is this the bottom-most edge so far?
		if( maxY == nil ) or (child.y + child.height > maxY ) then
		  -- Yes, store it
		  maxY = child.y + child.height
		end
	end
	
	-- Were there any children in this Group?
    if( minX ~= nil ) then
      -- Yes, calculate boundary's width and height
      width  = maxX - minX
      height = maxY - minY
    end

    -- Return width and height of Group's boundary, if any
    return width, height
end

