

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
    'enabled',
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
    'direction', #"horizontal"
    'dist_from_pane',
    'focus_opens_tab',
    # ArrowPane
    'cell_w', 
    'cell_h', 
    'children_want_focus', 
    'clip',
    'clip_to_size',
    'count',
    'depth',
    'has_clip',
    'horizontal_alignment',
    'horizontal_spacing',
    'is_animating',
    'is_rotated',
    'is_scaled',
    'move_by',
    'note_constructor',
    'number_of_cols',
    'number_of_rows',
    'pane_h', 
    'pane_w', 
    'placeholder', 
    'request_mode', # "HEIGHT_FOR_WIDTH"
    'vertical_alignment', 
    'vertical_spacing', 
    'virtual_x',
    'virtual_y',
    'virtual_w',
    'virtual_h',

    """
    # ScroolPane
    'slider_thickness',
    # TabBar
    'length',
    'tab_h',
    'tab_location',
    'tab_w',
    # ButtonPicker
    'orientation',
    'spacing', # horizontal_spacing, vertical_spacing, 'horizontal_cell_spacing', 'vertical_cell_spacing', 
    'visible', # is_visible ??
    'window_w', # is_visible ??
    'window_h', # is_visible ??
    # MenuButton
    'item_spacing', 
    'popup_offset', 

    """

    # Scroll Pane
    'horizontal_slider',
    'vertical_slider',
    # Slider 
    'value', 
    'ratio',
    'grip', # userdata ? 
    'track', #userdata ?
    # Clippig Region
    'virtual_width',
    'virtual_height',
    'content',

    # Widget Text
    'alignment',
    'baseline',
    'cursor_position',
    'cursor_size',
    'editable',
    'justify',
    'line_spacing',
    'markup',
    'max_length',
    'password_char',
    'selected_text',
    'selected_end',
    'single_line',
    'use_markup',
    'wants_enter',
    'wrap_mote',
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
    'cursor_color' : ['r', 'g', 'b', 'a'],
    'selected_color' : ['r', 'g', 'b', 'a'],
    'message_color' : ['r', 'g', 'b', 'a'],
    'border_color' : ['r', 'g', 'b', 'a'],
    'anchor_point' : ['x', 'y'],
    'scale' : ['x', 'y'],
    'clip' : ['x', 'y', 'w', 'h'],
    'x_rotation' : ['angle', 'y center', 'z center'],
    'y_rotation' : ['angle', 'x center', 'z center'],
    'z_rotation' : ['angle', 'x center', 'y center'],
    'tile' : ['x', 'y']
    #Arrow Pane
    #'cells' : [], 
    #'center' : ['',''], 
    #'children' : [], 
    #'constraints' : [], 
    #'min_size' : [], 
    #'natural_size' : [], 
    #Arrow Pane
    #'tabs' : [], 
    #ButtonPicker
    #'items' : [], 
}
