modelToDataTable = {
    
    'source': lambda v: ('source',  toString(v)),
    'activation': lambda v: ('activation', colors(v)), 
    'default': lambda v: ('default', colors(v)),
    'focus': lambda v: ('focus', colors(v)),
    'num_dots': lambda v: ('num_dots',  int(v)),
    'arrow_move_by': lambda v: ('arrow_move_by',  int(v)),
    'cell_w': lambda v: ('cell_w',  int(v)),
    'cell_h': lambda v: ('cell_h',  int(v)),
    'item_spacing': lambda v: ('item_spacing',  int(v)),
    'popup_offset': lambda v: ('popup_offset',  int(v)),
    'dot_size': lambda v: ('dot_size',  int(v)),
    'anchor_pointx': lambda v: ('anchor',  toFloat(v['x'])),
    'anchor_pointy': lambda v: ('anchor-y',  toFloat(v['y'])),
    'focused': lambda v: ('focused', toBool(v)),
    'enabled': lambda v: ('enabled', toBool(v)),
    'editable': lambda v: ('editable', toBool(v)),
    'clip_to_size': lambda v: ('clip_to_size', toBool(v)),
    'justify': lambda v: ('justify', toBool(v)),
    'single_line': lambda v: ('single_line', toBool(v)),
    'use_markup': lambda v: ('use_markup', toBool(v)),
    'wants_enter': lambda v: ('wants_enter', toBool(v)),
    'async': lambda v: ('async', toBool(v)),
    'animating': lambda v: ('animating', toBool(v)),
    'read_tags': lambda v: ('read_tags', toBool(v)),
    'selection_colorr': lambda v: ('selection_color', color(v)),
    'selection_colorg': lambda v: ('selection_color', color(v)),
    'selection_colorb': lambda v: ('selection_color', color(v)),
    'selection_colora': lambda v: ('selection_color', color(v)),
    'colorr': lambda v: ('color', color(v)),
    'colorg': lambda v: ('color', color(v)),
    'colorb': lambda v: ('color', color(v)),
    'colora': lambda v: ('color', color(v)),
    'color': lambda v: ('color', v),
    'message_color': lambda v: ('message_color', v),
    'message_colorr': lambda v: ('message_color', color(v)),
    'message_colorg': lambda v: ('message_color', color(v)),
    'message_colorb': lambda v: ('message_color', color(v)),
    'message_colora': lambda v: ('message_color', color(v)),
    'border_color': lambda v: ('border_color', v),
    'border_colorr': lambda v: ('border_color', color(v)),
    'border_colorg': lambda v: ('border_color', color(v)),
    'border_colorb': lambda v: ('border_color', color(v)),
    'border_colora': lambda v: ('border_color', color(v)),
    'is_visible': lambda v:('visible', toBool(v)),
    'selected': lambda v:('selected', toBool(v)),
    'group': lambda v: ('group',  toString(v)),
    'name': lambda v: ('name',  toString(v)),
    'direction': lambda v: ('direction',  toString(v)),
    'style': lambda v: ('style',  toString(v)),
    'title': lambda v: ('title',  toString(v)),
    'alignment': lambda v: ('alignment',  toString(v)),
    'message': lambda v: ('message',  toString(v)),
    'text': lambda v: ('text',  toString(v)),
    'selected_text': lambda v: ('selected_text',  toString(v)),
    'markup': lambda v: ('markup',  toString(v)),
    'font': lambda v: ('font',  toString(v)),
    'message_font': lambda v: ('message_font',  toString(v)),
    'src': lambda v: ('src', toString(v)),
    'opacity': lambda v: ('opacity',  opacity(v)),
    'width': lambda v: ('width',  toFloat(v)), 
    'height': lambda v: ('height',  toFloat(v)),
    'track_w': lambda v: ('track_w',  toFloat(v)),
    'track_h': lambda v: ('track_h',  toFloat(v)),
    'progress': lambda v: ('progress',  toFloat(v)),
    'grip_w': lambda v: ('grip_w',  toFloat(v)),
    'grip_h': lambda v: ('grip_h',  toFloat(v)),
    'tab_h': lambda v: ('tab_h',  toFloat(v)),
    'tab_w': lambda v: ('tab_w',  toFloat(v)),
    'tab_location': lambda v: ('tab_location',  toString(v)),
    'slider_thickness': lambda v: ('slider_thickness',  toFloat(v)),
    'virtual_x': lambda v: ('virtual_x',  toFloat(v)),
    'virtual_y': lambda v: ('virtual_y',  toFloat(v)),
    'virtual_h': lambda v: ('virtual_h',  toFloat(v)),
    'virtual_w': lambda v: ('virtual_w',  toFloat(v)),
    'pane_h': lambda v: ('pane_h',  toFloat(v)),
    'pane_w': lambda v: ('pane_w',  toFloat(v)),
    'baseline': lambda v: ('baseline',  toFloat(v)),
    'cursor_position': lambda v: ('cursor_position',  toFloat(v)),
    'cursor_size': lambda v: ('cursor_size',  toFloat(v)),
    'line_spacing': lambda v: ('line_spacing',  toFloat(v)),
    'max_length': lambda v: ('max_length',  toFloat(v)),
    'window_h': lambda v: ('window_h',  toFloat(v)),
    'window_w': lambda v: ('window_w',  toFloat(v)),
    'animate_duration': lambda v: ('animate_duration',  toFloat(v)),
    'password_char': lambda v: ('password_char',  toFloat(v)),
    'corner_radius': lambda v: ('corner_radius',  toFloat(v)), 
    'sizew': lambda v: ('width',  toFloat(v)), 
    'width': lambda v: ('width',  toFloat(v)), 
    'sizeh': lambda v: ('height',  toFloat(v)), 
    'size': lambda v: ('size',  toFloat(v)), 
    'border_width': lambda v: ('border_width',  int(v)), 
    'new_attra': lambda v: ('a attr',  toFloat(v['a'])), 
    'new_attrb': lambda v: ('b attr',  toFloat(v['b'])), 
    'new_attrc': lambda v: ('c attr',  v['c']), 
    #'positionx': lambda v: ('x',  toFloat(v['x'])), 
    #'positiony': lambda v: ('y',  toFloat(v['y'])), 
    #'positionz': lambda v: ('depth',  toFloat(v['z'])),
    'animate_in_duration': lambda v: ('animate_in_duration',  toFloat(v)), 
    'animate_out_duration': lambda v: ('animate_out_duration',  toFloat(v)), 
    'horizontal_alignment': lambda v: ('horizontal_alignment',  toString(v)), 
    'vertical_alignment': lambda v: ('vertical_alignment',  toString(v)), 
    'orientation': lambda v: ('orientation',  toString(v)), 
    'horizontal_spacing': lambda v: ('horizontal_spacing',  toFloat(v)), 
    'offset': lambda v: ('offset',  toFloat(v)), 
    'vertical_spacing': lambda v: ('vertical_spacing',  toFloat(v)), 
    'number_of_cols': lambda v: ('number_of_cols',  toFloat(v)), 
    'number_of_rows': lambda v: ('number_of_rows',  toFloat(v)), 
    'horizontal_icon_padding': lambda v: ('horizontal_icon_padding',  toFloat(v)), 
    'horizontal_message_padding': lambda v: ('horizontal_message_padding',  toFloat(v)), 
    'vertical_icon_padding': lambda v: ('vertical_icon_padding',  toFloat(v)), 
    'vertical_message_padding': lambda v: ('vertical_message_padding',  toFloat(v)), 
    'on_screen_duration': lambda v: ('on_screen_duration',  toFloat(v)), 
    'positionx': lambda v: ('x',  toFloat(v)), 
    'positiony': lambda v: ('y',  toFloat(v)), 
    'positionz': lambda v: ('z',  toFloat(v)),
    'separator_y': lambda v: ('separator_y',  toFloat(v)),
    'x_rotationangle': lambda v: ('rotation-angle-x',  toFloat(v)),
    'y_rotationangle': lambda v: ('rotation-angle-y',  toFloat(v['angle'])),
    'z_rotationangle': lambda v: ('rotation-angle-z',  toFloat(v['angle'])),
    'label': lambda v: ('label',  toString(v)),
}

dataToModelTable = {

    'source': lambda v: ('source', summarizeSource(v)),
    'type': lambda v: ('type', typeTextureToImage(v)), 
    'is_visible': lambda v: ('visible', bool(v)), 
    'tile': lambda v: ('tile', tileToBool(v)), 
    'source': lambda v: ('source', summarizeSource(v)),
    'scale': lambda v: ('scale', scaleToFloat(v)),
    'x_rotation': lambda v: ('x_rotation', angleToFloat(v)),
    'y_rotation': lambda v: ('y_rotation', angleToFloat(v)),
    'z_rotation': lambda v: ('z_rotation', angleToFloat(v)),

}

def colors(v):
    v = v[1:] 
    v = v[:len(v)-1] 
    v = "{"+v+"}"
    return v

def toString(v):
     return "'"+str(v)+"'"

def angleToFloat(v):
    v['angle'] = float(v['angle'])
    return v

def scaleToFloat(v):
    v['x'] = float(v['x'])
    v['y'] = float(v['y'])
    return v
    
def summarizeSource(v):
    """
    Summarize clone data into a string
    print("summarize!!")
    """
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
    v['x'] = toBool(v['x'])
    v['y'] = toBool(v['y'])
    return v

def typeTextureToImage(v):
    if 'Texture' == v:
        return "Image"
    else:
        return v
    
def dataToModel(title, value):

    title, value = dataToModelTable.get(title, lambda v: (title, value))(value)
    simple = not isinstance(value, dict)
    
    return (title, value, simple)

def modelToData(title, value):
    
    return modelToDataTable[str(title)](value)

def color(v):
    return 'rgba(' + str(v['r']) + ', ' + str(v['g']) + ', ' + str(v['b']) + ', ' + str(float(v['a'])/255) + ')'

def toBool(v):
    if str(v) == "True" or str(v) == "true": 
        return "true"
    elif str(v) == "False" or str(v) == "false":
        return "false"
    else :
        return "what?"

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

