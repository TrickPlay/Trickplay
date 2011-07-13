typeTable = {
    
    'anchor_point x': lambda v: ('anchor-x',  toFloat(v)),
    'anchor_point y': lambda v: ('anchor-y',  toFloat(v)),
    'is_visible': lambda v:('visible',  bool(v)),
    'name': lambda v: ('name',  v),
    'text': lambda v: ('text',  v),
    'opacity': lambda v: ('opacity',  opacity(v)),
    'width': lambda v: ('width',  width(v)), 
    'height': lambda v: ('height',  toFloat(v)),
    'w': lambda v: ('width',  toFloat(v)), 
    'h': lambda v: ('height',  toFloat(v)), 
    'x': lambda v: ('x',  toFloat(v)), 
    'y': lambda v: ('y',  toFloat(v)), 
    'z': lambda v: ('depth',  toFloat(v)),

}

def dataToModel(title,  value):
    t = title
    v = value
    s = True
    
    if "anchor_point" == t or \
    "clip" == t or "scale" == t or \
    "tile" == t or "source" == t or \
    "color" == t or "border_color" == t:
        s = False
        
    #if "gid" == v:
    #    v = int(v)
        
    if "type" == t and "Texture" == v:
        v = "Image"
        
    if "is_visible" == t:
        if v:
            v = True
        else:
            v = False
    
    return (t, v, s)
    
def modelToData(title,  value):
    t, v = typeTable[title](value)
    return (t, v)

def getTypeTable():
    return typeTable

def opacity(v):
    try:
        v = int(v)
        if v < 0:
            v = 0
        elif v > 255:
            v = 255
        return v
    except:
        raise BadDataException('Opacity must be an integer between 0 and 255.')
        
def toFloat(v):
    try:
        return float(v)
    except:
        raise BadDataException('Value entered cannot be converted to a float.')

class BadDataException(Exception):
       def __init__(self, value):
           self.value = value
       def __str__(self):
           return repr(self.value)

#try:
#    raise CustomException("My Useful Error Message")
#except CustomException, (instance):
#    print "Caught: " + instance.value
#
