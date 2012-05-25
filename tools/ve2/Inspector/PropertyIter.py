

class PropertyIter:
    """
    Return the UI Element properties in the order they should be
    added to the model
    """    

    def __init__(self, group = None):
        
        if group:
            self.group = NESTED_PROP_LIST[group]
        else:
            self.group = PROP_LIST
        
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

     
PROP_LIST = [
    'gid',
    'name', 
    'source', 
    'src', 
    'text',
    'font', 
    'position', 
    'x',
    'y',
    'z',
    'w',
    'h',
    'size',
    'separator_y',
    'animate_in_duration',
    'animate_out_duration',
    'horizontal_icon_padding',
    'horizontal_message_padding',
    'message',
    'message_color',
    'on_screen_duration',
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
    # Widget
    'style', 
    'focused',
    # Widget Style
    #'border',
    #'arrow',
    #'fill_colors',
    # Style Text
    'x_offset',
    'y_offset',
    #'colors',
    # Style Border
    'width',
    'corner_radius',
    #'colors',
    # Style Arrow 
    #'offset',
    #'colors',
    # Color Scheme 
    'default_color', 
    'focus_color', 
    'activate_color', 
    'select_color', 
    # Color
    'hex_string', 
    'rgb_table',
    'color_table',
    # Button
    'label', 
    # Toggle Button
    'selected', 
    'group', 
    'images_selection',
    # Radio Button Group
    'items',
    'selected_item'
    # Layout Manager
    'number_of_rows',
    'number_of_columns',
    'cell_width', 
    'cell_height', 
    'horizontal_cell_spacing', 
    'vertical_cell_spacing', 
    'cell_timing', 
    'cell_timing_offset', 
    'cells', 
    'cells_focusable', 
    # Text Input
    # Progress Bar
    'progress',
    'fill_style',
    'empty_style', 
    # Progress Spinner
    'duration',
    'image', 
    'animating', 
    # Obitting Dots
    'duration', 
    'image', 
    'animating', 
    'num_dots', 
    'dot_size', 
    # Dialog Box
    'title', 
    'content', 
    'seterator_y', 
    'image', 
    # Toast Alert 
    'icon', 
    'message', 
    'message_font', 
    'message_color', 
    'horizontal_message_padding', 
    'vertical_message_padding', 
    'horizontal_icon_padding', 
    'vertical_icon_padding', 
    'animate_in_duration',
    'animate_out_duration',
    'on_screen_duration',
    # Menu Button
    'button',
    'x_offset',
    'y_offset',
    'x_alignment',
    'y_alignment',
    'items',
    # Button Picker
    'selected_item',
    'derection',
    # Tab Bar
    'direction',
    'dist_from_pane',
    'focus_opens_tab',
    # Scroll Pane
    'horizontal_slider',
    'vertical_slider',
    # Slider 
    'value', 
    'ratio',
    'grip',
    'track',
    # Clippig Region
    'virtual_width',
    'virtual_height',
    'content',

    # Hidden
    #'type',
    #'children', 
]

NESTED_PROP_LIST = {
    'style' : ['arrow', 'border', 'fill_colors', 'text'], 
    'arrow' : ['colors', 'offset', 'size'],
    'border' : ['colors', 'corner_radius', 'width'],
    'fill_colors' : ['activation', 'default', 'focus'],
    'colors' : ['activation', 'default', 'focus'],
    'text' : ['alignment', 'colors', 'font', 'justify', 'wrap', 'x_offset', 'y_offset'], 
    'position' : ['x', 'y', 'z'], 
    'size' : ['w', 'h'],
    'new_attr' : ['a', 'b','c'],
    'color' : ['r', 'g', 'b', 'a'],
    'message_color' : ['r', 'g', 'b', 'a'],
    'border_color' : ['r', 'g', 'b', 'a'],
    'anchor_point' : ['x', 'y'],
    'scale' : ['x', 'y'],
    'clip' : ['x', 'y', 'w', 'h'],
    'x_rotation' : ['angle', 'y center', 'z center'],
    'y_rotation' : ['angle', 'x center', 'z center'],
    'z_rotation' : ['angle', 'x center', 'y center'],
    'tile' : ['x', 'y'], 
}
