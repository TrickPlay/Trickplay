
"""
A row of items
"""
class Row:
    
    def __init__(self, items):
    
        self.last = 0
    
        self.items = items
        
        self.tNode = items[TITLE]
        
        self.t = self.tNode.pyData()
        
        self.vNode = items[VALUE]
        
        self.v = self.vNode.pyData()
        
        try:
        
            self.gNode = items[GID]
        
            self.g = self.gNode.pyData()
            
        except:
            
            gid = 0
    
    def valueNode(self): return self.vNode
    
    def value(self): return self.v
    
    def titleNode(self): return self.tNode
    
    def title(self): return self.t
    
    def gidNode(self): return self.gidNode
    
    def gid(self): return self.g
        
    def __len__(self):
        
        len(self.items)

    def next(self):
        
        if self.last < len(self):
        
            self.last += 1
            
            return self.items(self.last)

        else:

            self.last = 0
            
            raise StopIteration



    def __iter__(self):
        
        return self



ATTR = [
    'text',
    'font', 
    {'position' : ['x', 'y', 'z']}, 
    {'size' : ['w', 'h']},
    'opacity', 
    'is_visible', 
    {'color' : ['r', 'g', 'b', 'a']},
    {'border_color' : ['r', 'g', 'b', 'a']},
    {'anchor_point' : ['x', 'y']},
    {'scale' : ['x', 'y']},
    {'clip' : ['x', 'y', 'w', 'h']},
    {'x_rotation' : ['angle', 'y', 'z']},
    {'y_rotation' : ['angle', 'x', 'z']},
    {'z_rotation' : ['angle', 'x', 'y']},
]

FIND_ATTR_POSITION = {
    'text' : 0,
    'font' : 1,
    'position' : 2,
    'size' : 3,
    'opacity' : 4,
    'is_visible' : 5,
    'color' : 6,
    'border_color' : 7,
    'anchor_point' : 8,
    'scale' : 9,
    'clip' : 10,
    'x_rotation' : 11,
    'y_rotation' : 12,
    'z_rotation' : 13,
}
