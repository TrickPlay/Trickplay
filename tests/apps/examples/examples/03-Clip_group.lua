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
-- Note: The size property is not relevant to the clipping operation; by 
-- default, object's will be displayed outside of the group's display region.
local RectGroup = Group{ position = { 100, 100 },
                         size = { 1, 1 } }                                 

-- Add three Rectangles to the Group
RectGroup.children = { RectRed, RectGreen, RectBlue }

-- To clip the Rectangles, set the Group's clip property to the desired
-- display region
RectGroup.clip = { 0, 0, 500, 250 }

-- To unclip the Rectangles, undefine the Group's clip property
RectGroup.clip = nil

