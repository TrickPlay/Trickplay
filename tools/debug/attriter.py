
"""
Return the attributes in the order they should be added to the model
"""
class AttrIter:
    
    def __init__(self, group = None):
        
        if group:
        
            self.group = NESTED_ATTR_LIST[group]
        
        else:
            
            self.group = ATTR_LIST
        
        self.current = 0
        
        self.limit = len(self.group)
        
        
    def __iter__(self):
        
        return self
        
        
    def next(self):
        
        if self.current < self.limit:
            
            r = self.group[self.current]
            
            self.current += 1
            
            return r
            
        else:
            
            self.current = 0
            
            raise StopIteration

     
ATTR_LIST = [
    'source', 
    'src', 
    'text',
    'font', 
    'position', 
    'size',
    'opacity', 
    'tile',
    'is_visible', 
    'color',
    'border_color',
    'anchor_point',
    'scale',
    'clip',
    'x_rotation',
    'y_rotation',
    'z_rotation',
    
    # Hidden
    #'gid',
    #'name', 
    #'type', 
    'children', 
]

NESTED_ATTR_LIST = {
    'position' : ['x', 'y', 'z'], 
    'size' : ['w', 'h'],
    'color' : ['r', 'g', 'b', 'a'],
    'border_color' : ['r', 'g', 'b', 'a'],
    'anchor_point' : ['x', 'y'],
    'scale' : ['x', 'y'],
    'clip' : ['x', 'y', 'w', 'h'],
    'x_rotation' : ['angle', 'y center', 'z center'],
    'y_rotation' : ['angle', 'x center', 'z center'],
    'z_rotation' : ['angle', 'x center', 'y center'],
    'tile' : ['x', 'y'], 
}