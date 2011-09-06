modelToDataTable = {
    
    'anchor_pointx': lambda v: ('anchor-x',  toFloat(v['x'])),
    'anchor_pointy': lambda v: ('anchor-y',  toFloat(v['y'])),
    'scalex': lambda v: ('scale-x',  toFloat(v['x'])),
    'scaley': lambda v: ('scale-y',  toFloat(v['y'])),
    #'clipx': lambda v: ('clip',  clip(v)),
    #'clipy': lambda v: ('clip',  clip(v)),
    'tilex': lambda v: ('repeat-x', bool(v)),
    'tiley': lambda v: ('repeat-y', bool(v)),
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
    #'src': lambda v: ('filename', v),
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

dataToModelTable = {

    'type': lambda v: ('type', typeTextureToImage(v)), 
    'is_visible': lambda v: ('is_visible', bool(v)), 
    'tile': lambda v: ('tile', tileToBool(v)), 
    'source': lambda v: ('source', summarizeSource(v)),
    'scale': lambda v: ('scale', scaleToFloat(v)),
    'x_rotation': lambda v: ('x_rotation', angleToFloat(v)),
    'y_rotation': lambda v: ('y_rotation', angleToFloat(v)),
    'z_rotation': lambda v: ('z_rotation', angleToFloat(v)),

}

def angleToFloat(v):
    
    v['angle'] = float(v['angle'])
    
    return v

def scaleToFloat(v):
    
    v['x'] = float(v['x'])
    
    v['y'] = float(v['y'])
    
    return v
    

def summarizeSource(v):

    # Clone may not have source
    try:
    
        s = str(v['gid']) 
        
        name = v['name']
        
        if '' != name:
            
            s += ' : ' + name
        
        return s
        
    except:
    
        return '' 

def tileToBool(v):
    v['x'] = bool(v['x'])
    v['y'] = bool(v['y'])
    return v

def typeTextureToImage(v):
    
    if 'Texture' == v:
    
        return "Image"
        
    else:

        return v
    
def modelToData(title,  value):
    t, v = typeTable[title](value)
    return (t, v)
    
def dataToModel(title, value):

    title, value = dataToModelTable.get(title, lambda v: (title, value))(value)
    simple = not isinstance(value, dict)
    
    return (title, value, simple)

def modelToData(title, value):
    
    return modelToDataTable[title](value)

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

