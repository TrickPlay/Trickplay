

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

NO_STYLE_WIDGET = ["Tab", "Widget_Text", "Widget_Rectangle", "Widget_Image", "Widget_Clone", "Widget_Group", "LayoutManager"] 

READ_ONLY= ["gid", "baseline", "selected_text", "base_size", "loaded", "tags"]

BOOL_PROP = [
    'is_visible', 
    'focused',
    'enabled',
    # Progress Spinner
    'animating', 
    # Toggle Button
    'selected', 
    # Widget Image
    'async',
    #'loaded',
    #'read_tags',
    # Widget Text
    'single_line',
    'use_markup',
    'wants_enter',
    'editable',
    'justify',
    # Widget Group
    'clip_to_size',
    # Widget Image
    'tile_x',
    'tile_y',
]

COLOR_PROP = [
    'color',
    'border_color',
    'message_color', 
    # Color Scheme 
    'default', 
    'focus', 
    'activation',
    'default_color', 
    'focus_color', 
    'activate_color', 
    'select_color', 
]

FONT_PROP = [
    'font', 
    'message_font', 
]

COMBOBOX_PROP = [
    # ButtonPicker
    'orientation', # horizontal, vertical
    # WidgetText
    'wrap_mode', # WORD(default), CHAR, WORD_CHAR
    'alignment', # LEFT(default), CENTER, RIGHT
    # TabBar, Slider, MenuButton
    'direction', # TabBar, Slider direction : horizontal, vertical
                 # MenuButton direction : up, down, left, right
    # ArrowPane
    'horizontal_alignment',
    'vertical_alignment', 
    # TabBar
    'tab_location',
]

COMBOBOX_PROP_VALS = {
    # ButtonPicker
    'orientation' : ['horizontal', 'vertical'],
    # WidgetText
    'wrap_mode' : ['WORD', 'CHAR', 'WORD_CHAR'],
    'alignment' : ['LEFT', 'CENTER', 'RIGHT'],
    # TabBar, Slider, MenuButton
    'direction' : { 
                    'TabBar':['horizontal', 'vertical'],
                    'Slider':['horizontal', 'vertical'],
                    'MenuButton':[ 'up', 'down', 'left', 'right']
                  }, # TabBar, Slider direction : horizontal, vertical
                    # MenuButton direction : up, down, left, right
    # MenuButton
    'horizontal_alignment' : ['left','center','right'],
    'vertical_alignment' : ['top', 'center', 'bottom'],
    # TabBar
    'tab_location':['top', 'left'],
    # Clone
    'source': [], 
}

FILE_PROP = [
    'src', 
]

TEXT_PROP = [
    'name', 
    'src', 
    'text',
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
    # ButtonPicker
    'window_w', 
    'window_h', 
    'animate_duration', 
    #'anchor_point',
    'scale',
    'clip',
    'x_rotation',
    'y_rotation',
    'z_rotation',
    # Widget Style
    'style', 
    'x_offset',
    'y_offset',
    'width',
    'corner_radius',
    # Color
    'hex_string', 
    'rgb_table',
    'color_table',
    # Button
    'label', 
    # Toggle Button
    'group', 
    'images_selection',
    # Radio Button Group
    'selected_item'
    # Layout Manager
    'number_of_rows',
    'number_of_columns',
    'cell_width', 
    'cell_height', 
    'horizontal_cell_spacing', 
    'vertical_cell_spacing', 
    'cell_timing', #

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
    # Obitting Dots
    'image', 
    'num_dots', 
    'dot_size', 
    # Dialog Box
    'title', 
    #'content', 
    'seterator_y', 
    'image', 
    # Toast Alert 
    'icon', 
    'message', 
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
    # Button Picker
    'items',
    'selected_item',
    'derection',
    # Tab Bar
    'dist_from_pane',
    'focus_opens_tab',
    # ArrowPane
    'cell_w', 
    'cell_h', 
    'children_want_focus', 
    'clip',
    'count',
    'depth',
    #'has_clip',
    'horizontal_spacing',
    #'is_animating',
    #'is_rotated',
    #'is_scaled',
    'arrow_move_by',
    'note_constructor',
    'number_of_cols',
    'number_of_rows',
    'pane_h', 
    'pane_w', 
    'placeholder', 
    'request_mode', # "HEIGHT_FOR_WIDTH"
    'vertical_spacing', 
    'virtual_x',
    'virtual_y',
    'virtual_w',
    'virtual_h',
    # ScroolPane
    'slider_thickness',
    # TabBar
    'tab_h',
    'tab_w',

    # MenuButton
    'item_spacing', 
    'popup_offset', 

    # Scroll Pane
    'horizontal_slider',
    'vertical_slider',
    # Slider 
    'value', 
    'ratio',
    'grip', 
    'grip_w', 
    'grip_h', 
    'track', 
    'track_w', 
    'track_h', 
    # Clippig Region
    'virtual_width',
    'virtual_height',

    # Widget Text
    'cursor_position',
    'cursor_size',
    'line_spacing',
    'markup',
    'max_length',
    'password_char',
    'selected_text',
    'selected_end',
    
    # Widget Image
    #'tags',        # Readonly

    # Widget Rectangle
    'border_width',
]

     
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
    # ButtonPicker
    'orientation',
    'window_w', 
    'window_h', 
    'animate_duration', 
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
    'image', 
    'num_dots', 
    'dot_size', 
    # Dialog Box
    'title', 
    #'content', 
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
    # Button Picker
    'items',
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
    #'has_clip',
    'horizontal_alignment',
    'horizontal_spacing',
    #'is_animating',
    #'is_rotated',
    #'is_scaled',
    'arrow_move_by',
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
    # ScroolPane
    'slider_thickness',
    # TabBar
    'tab_h',
    'tab_location',
    'tab_w',

    # MenuButton
    'item_spacing', 
    'popup_offset', 

    # Scroll Pane
    'horizontal_slider',
    'vertical_slider',
    # Slider 
    'value', 
    'ratio',
    'grip', # userdata ? 
    'grip_w', 
    'grip_h', 
    'track', #userdata ?
    'track_w', 
    'track_h', 
    # Clippig Region
    'virtual_width',
    'virtual_height',

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
    'wrap_mode',
    
    # Widget Image
    'async',
    'loaded',
    #'read_tags',
    #'tags',

    # Widget Rectangle
    'border_width',
    'neighbors',

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
    'base_size' : ['w', 'h'], #read only
    'new_attr' : ['a', 'b','c'],
    #'color' : ['r', 'g', 'b', 'a'],
    'cursor_color' : ['r', 'g', 'b', 'a'],
    'selection_color' : ['r', 'g', 'b', 'a'],
    #'message_color' : ['r', 'g', 'b', 'a'],
    'border_color' : ['r', 'g', 'b', 'a'],
    'anchor_point' : ['x', 'y'],
    'scale' : ['x', 'y'],
    'clip' : ['x', 'y', 'w', 'h'],
    'x_rotation' : ['angle', 'y center', 'z center'],
    'y_rotation' : ['angle', 'x center', 'z center'],
    'z_rotation' : ['angle', 'x center', 'y center'],
    'tile' : ['x', 'y'],
    #'items' : []
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
    #'items' : []
}
