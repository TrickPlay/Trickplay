-- Create three rectangle objects
local RedRect   = Rectangle{ color = { 255, 0, 0, 255 }, 
                             position = { 600, 100, 0 },
                             size = { 800, 250 } }
local GreenRect = Rectangle{ color = { 0, 255, 0, 255 }, 
                             position = { 0, 300, 0 },
                             size = { 400, 350 } }
local BlueRect  = Rectangle{ color = { 0, 0, 255, 255 },
                             position = { 200, 0, 0 },
                             size = { 1000, 200 } }

-- Create a Group
local RectGroup = Group{ position = { 100, 100 },
                         size = { 1400, 650 } }                                 

-- Add three Rectangles to the Group
RectGroup.children = { RedRect, GreenRect, BlueRect }

-- Rotate all three Rectangles as a single object
-- Flip upside-down, i.e., 180 degrees
RectGroup.x_rotation = { 180, RectGroup.height / 2, 0 }

-- Restore original non-rotated position
RectGroup.x_rotation = { 0, 0, 0 }

