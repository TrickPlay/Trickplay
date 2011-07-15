typeTable = {
    
    'anchor_pointx': lambda v: ('anchor-x',  toFloat(v['x'])),
    'anchor_pointy': lambda v: ('anchor-y',  toFloat(v['y'])),
    'scalex': lambda v: ('scale-x',  toFloat(v['x'])),
    'scaley': lambda v: ('scale-y',  toFloat(v['y'])),
    'clipx': lambda v: ('clip',  clip(v)),
    'clipy': lambda v: ('clip',  clip(v)),
    'colorr': lambda v: ('color', color(v)),
    'colorg': lambda v: ('color', color(v)),
    'colorb': lambda v: ('color', color(v)),
    'colora': lambda v: ('color', color(v)),
    'border_colorr': lambda v: ('border_color', color(v)),
    'border_colorg': lambda v: ('border_color', color(v)),
    'border_colorb': lambda v: ('border_color', color(v)),
    'border_colora': lambda v: ('border_color', color(v)),
    'is_visible': lambda v:('visible',  bool(v)),
    'name': lambda v: ('name',  v),
    'text': lambda v: ('text',  v),
    'font': lambda v: ('font-name',  v),
    'opacity': lambda v: ('opacity',  opacity(v)),
    'width': lambda v: ('width',  width(v)), 
    'height': lambda v: ('height',  toFloat(v)),
    'sizew': lambda v: ('width',  toFloat(v['w'])), 
    'sizeh': lambda v: ('height',  toFloat(v['h'])), 
    'positionx': lambda v: ('x',  toFloat(v['x'])), 
    'positiony': lambda v: ('y',  toFloat(v['y'])), 
    'positionz': lambda v: ('depth',  toFloat(v['z'])),
    'x_rotationangle': lambda v: ('rotation-angle-x',  toFloat(v['angle'])),
    'y_rotationangle': lambda v: ('rotation-angle-y',  toFloat(v['angle'])),
    'z_rotationangle': lambda v: ('rotation-angle-z',  toFloat(v['angle'])),

}
    
def modelToData(title,  value):
    t, v = typeTable[title](value)
    return (t, v)
    
def dataToModel(title,  value):
    t = title
    v = value
    s = True
    
    if isinstance(value, dict):
        s = False
    
#    if "anchor_point" == t or \
#    "clip" == t or "scale" == t or \
#    "tile" == t or "source" == t or \
#    "color" == t or "border_color" == t or \
#    "size" ==t or "position" == t:
#        s = False
        
    #if "gid" == v:
    #    v = int(v)
        
    if "type" == t and "Texture" == v:
        v = "Image"
        
    if "is_visible" == t:
        #if v:
        #    v = True
        #else:
        #    v = False
        v = bool(v)
            
    if "tile" == t:
        v['x'] = bool(v['x'])
        v['y'] = bool(v['y'])
    
    return (t, v, s)

def getTypeTable():
    return typeTable

def color(v):

    return 'rgba(' + str(v['r']) + ', ' + str(v['g']) + ', ' + str(v['b']) + ', ' + str(float(v['a'])/255) + ')'

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
        
def clip(v):
    c = {}
    c['h']=100
    c['w']=100
    c['x']=100
    c['y']=100
    return c

def toFloat(v):
    try:
        return float(v)
    except:
        print(v)
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
