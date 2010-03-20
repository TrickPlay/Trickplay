print("DOING IT")


function layout(...)

    local function rsize(size,relative_to)
        if size == 0 then
            return size
        elseif size < 0 then
            return relative_to+size
        elseif size < 1 then
            return relative_to*size
        else
            return size
        end
    end

    -- You can pass a parent and a table, or just a table, in which case,
    -- the screen is the parent.
    
    -- ids is a table - all ui elements that have a name, are
    -- added to this table using their name as a key. This effectively collects
    -- all named ui elements so you can refer to them easily later.
    
    local parent,t,ids,r=...
    
    if t==nil then
        t=parent
        parent=screen
    end
    
    ids=ids or {}

    -- The rectangle of the parent, or the one passed in. We make a copy
    -- so that we don't change the caller's rectangle
    
    if r then
        r={x=r.x,y=r.y,w=r.w,h=r.h}
    else
        r={x=0,y=0,w=parent.w,h=parent.h}
    end
    
    -- Background. This is added to the parent without padding
    
    local background=t.background
    
    if background then
        parent:add(background:set{position={r.x,r.y},size={r.w,r.h}})
        if background.name then
            ids[background.name]=background
        end
    end
    
    -- Padding can be set as a single number for all 4 sides, or
    -- independently for each side
    
    local padding=t.padding
    
    if type(padding)=="number" then
        padding={top=rsize(padding,r.h),
                bottom=rsize(padding,r.h),
                left=rsize(padding,r.w),
                right=rsize(padding,r.w)}
    elseif type(padding)=="table" then
        padding={top=rsize(padding.top or 0,r.h),
                bottom=rsize(padding.bottom or 0,r.h),
                left=rsize(padding.left or 0,r.w),
                right=rsize(padding.right or 0,r.w)}
    end
    
    -- Shrink the rectangle according to the padding
    
    if padding then
        r.x=r.x+padding.left
        r.w=r.w-(padding.left+padding.right)

        r.y=r.y+padding.top
        r.h=r.h-(padding.top+padding.bottom)
    end
    
    -- Now see if there is a group. If there is a group, it is added to the
    -- parent and all children found below are added to the group
    
    local dad=parent
    
    local group=t.group
    
    if group then
        parent:add(group:set{position={r.x,r.y},size={r.w,r.h}})
        r.x=0
        r.y=0
        dad=group
        if group.name then
            ids[group.name]=group
        end
    end
    
    -- See if there is a content child. The content is added to the group or
    -- parent after padding. 
    
    local content=t.content
    
    if content then
        dad:add(content:set{position={r.x,r.y},size={r.w,r.h}})
        if content.name then
            ids[content.name]=content
        end
    end
    
    -- Now look for rows or columns - only one is observed. They can either be
    -- tables or functions that return a table.
    
    local columns=t.columns
    
    if type(columns)=="function" then
        columns=columns()
    end
    
    local rows=t.rows
    
    if type(rows)=="function" then
        rows=rows()
    end
    
    local children=columns or rows

    if children then
    
        local relative_to
        
        if children==columns then
            relative_to=r.w
        else
            relative_to=r.h
        end
        
        -- Iterate over all the children and determine their real size. Any
        -- children that have a size of 0 will get their share of whatever is
        -- left over.
        
        local size_left=relative_to
        local unsized={}
        
        for _,child in ipairs(children) do
            local size=child.size or 0
            
            if size==0 then
                table.insert(unsized,child)
            else
                size=rsize(size,relative_to)
                size_left=size_left-size
                child.size=size
            end
        end
        
        -- Now distribute the remaining size among the unsized children
        
        if #unsized > 0 then
            local size_share=size_left/#unsized
            for _,child in ipairs(unsized) do
                child.size=size_share
            end
        end
        
        -- Finally, all children have a real, absolute size, so we can
        -- process each one
        
        local child_r
        
        if children==columns then
            
            child_r={x=r.x,y=r.y,w=0,h=r.h}
            
            for _,child in ipairs(children) do
                child_r.w=child.size
                layout(dad,child,ids,child_r)
                child_r.x=child_r.x+child.size
            end
            
        else
        
            child_r={x=r.x,y=r.y,w=r.w,h=0}
            
            for _,child in ipairs(children) do
                child_r.h=child.size
                layout(dad,child,ids,child_r)
                child_r.y=child_r.y+child.size
            end
            
        end
        
    end
    
    -- Return the parent as well as the table of ids that was either passed in
    -- or created
    
    return parent,ids
end
