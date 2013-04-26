

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

PROP_S_LIST = {
    #'gid',
    #'name', 
    #'source', 
    #'src', 
    #'text',
    #'font', 
    #'position', 
    #'x',
    #'y',
    #'z',
    #'w',
    #'h',
    #'size',
    'separator_y':'separator height',
    #'opacity', 
    #'tile',
    'is_visible':'visible', 
    #'color',
    # ButtonPicker
    #'orientation',
    'window_w':'window width', 
    'window_h':'window height', 
    'animate_duration':'animation duration', 
    'border_color':'border color',
    'anchor_point':'anchor point',
    #'scale',
    #'clip',
    'x_rotation':'x rotation',
    'y_rotation':'y rotation',
    'z_rotation':'z rotation',
    # Widget
    #'style', 
    #'focused',
    #'enabled',
    # Widget Style
    #'border',
    #'arrow',
    #'fill_colors',
    # Style Text
    'x_offset':'x offset',
    'y_offset':'y offset',
    #'colors',
    # Style Border
    #'width',
    'corner_radius':'corner radius',
    #'colors',
    # Style Arrow 
    #'offset',
    #'colors',
    # Color Scheme 
    'default_color':'default color', 
    'focus_color':'focus color', 
    'activate_color':'active color', 
    'select_color':'select color', 
    # Color
    'hex_string':'hex string', 
    'rgb_table':'rgb table',
    'color_table':'color table',
    # Button
    #'label', 
    # Toggle Button
    #'selected', 
    #'group', 
    'images_selection' : 'images',
    # Radio Button Group
    'selected_item':'selected items',
    # Layout Manager
    'number_of_rows':'rows',
    'number_of_columns':'columns',
    'cell_w':'cell width', 
    'cell_h':'cell height', 
    'cell_width':'cell width', 
    'cell_height':'cell height', 
    'horizontal_cell_spacing':'horizontal cell spacing', 
    'horizontal_spacing':'horizontal cell spacing', 
    'vertical_cell_spacing':'vertical cell spacing', 
    'vertical_spacing':'vertical cell spacing', 
    'cell_timing':'cell timing', 
    'cell_timing_offset':'cell timing offset', 
    'cells_focusable':'cell focusable', 
    # Text Input
    # Progress Bar
    #'progress',
    'fill_style' : 'fill style',
    'empty_style' : 'empty style', 
    # Progress Spinner
    #'duration',
    #'image', 
    #'animating', 
    # Obitting Dots
    #'image', 
    'num_dots' : 'number of dots', 
    'dot_size' : 'dot size', 
    # Dialog Box
    #'title', 
    #'content', 
    #'image', 
    # Toast Alert 
    #'icon', 
    #'message', 
    'message_font':'message font', 
    'message_color':'message color', 
    'horizontal_message_padding' : 'horizontal message padding', 
    'vertical_message_padding' : 'vertical message padding', 
    'horizontal_icon_padding' : 'horizontal icon padding', 
    'vertical_icon_padding' : 'vertical icon padding', 
    'animate_in_duration':'animate in duration',
    'animate_out_duration':'animate out duration',
    'on_screen_duration':'on screen duration',
    # Menu Button
    #'button',
    'x_offset' : 'x offset',
    'y_offset' : 'y offset',
    'x_alignment' : 'x alignment',
    'y_alignment' : 'y alignment',
    # Button Picker
    #'items',
    #'derection',
    # Tab Bar
    #'direction', #"horizontal"
    'dist_from_pane' : 'distance from pane',# Alex 
    'focus_opens_tab' : 'focus opens tab', # Alex 
    # ArrowPane
    'children_want_focus' : 'children want focus', # Alex 
    #'clip',
    'clip_to_size' : 'clip to size',# Alex 
    #'count',
    #'depth',
    #'has_clip',
    'horizontal_alignment' : 'horizontal alignment',
    #'is_animating',
    #'is_rotated',
    #'is_scaled',
    'arrow_move_by':'arrow moves by',
    'number_of_cols' : 'columns',
    'number_of_rows' : 'rows',
    'pane_h': 'pane height', 
    'pane_w': 'pane width', 
    #'placeholder', 
    'request_mode':'request mode', # "HEIGHT_FOR_WIDTH"
    'vertical_alignment' : 'vertical alignment',
    'virtual_x' : 'virtual x',
    'virtual_y' : 'virtual y',
    'virtual_w' : 'virtual w',
    'virtual_h' : 'virtual h',
    # ScroolPane
    'slider_thickness':'slider thickness',
    # TabBar
    'tab_h':'tab height',
    'tab_location':'tab location',
    'tab_w':'tab width',

    # MenuButton
    'item_spacing':'item spacing', 
    'popup_offset':'popup offset', 

    # Scroll Pane
    'horizontal_slider':'horizontal slider',
    'vertical_slider':'vertical slider',
    # Slider 
    #'value', 
    #'ratio',
    #'grip', # userdata ? 
    'grip_w':'grip width', 
    'grip_h':'grip height', 
    #'track', #userdata ?
    'track_w':'track width', 
    'track_h':'track height', 
    # Clippig Region
    'virtual_width':'virtual width',
    'virtual_height':'virtual height',

    # Widget Text
    #'alignment',
    #'baseline',
    'cursor_position' : 'cursor position',
    'cursor_size' : 'cursor size',
    #'editable',
    #'justify',
    'line_spacing' : 'line spacing',
    #'markup',
    'max_length' : 'max length',
    'password_char' : 'password char',
    'selected_text' : 'selected text',
    'selected_end' : 'selected end',
    'single_line' : 'single line',
    'use_markup' : 'use markup',
    'wants_enter' : 'wants enter',
    'wrap_mode' : 'wrap mode',
    
    # Widget Image
    #'async',
    #'loaded',
    #'read_tags',
    #'tags',

    # Widget Rectangle
    #'border_width',
    #'neighbors',

    # Hidden
    #'type',
    #'children', 
}

NESTED_PROP_LIST = {
    #'style' : ['arrow', 'border', 'fill_colors', 'text'], 
    'style' : ['spritesheet_map','text'], 
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
    #'anchor_point' : ['x', 'y'],
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

NESTED_PROP_S_LIST = {
    'spritesheet_map' : 'spritesheet map', 
    'corner_radius' : 'corner radius',
    'x_offset' : 'x offset', 
    'y_offset' : 'y offset'
}
