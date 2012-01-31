0#-------------------------------------------------------------------------
# qsci_simple_pythoneditor.pyw
#
# QScintilla sample with PyQt
#
# Eli Bendersky (eliben@gmail.com)
# This code is in the public domain
#-------------------------------------------------------------------------
import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.Qsci import QsciScintilla, QsciLexerLua
from connection import *

TEXT_DEFAULT = 0
TEXT_READ = 1
TEXT_CHANGED = 2

class Editor(QsciScintilla):

    BACKGROUND_MARKER_NUM = 0
    ACTIVE_BREAK_MARKER_NUM = 1
    DEACTIVE_BREAK_MARKER_NUM = 2
    ARROW_MARKER_NUM = 8
    
    def __init__(self, debugWindow=None, editorManager=None, parent=None):
        super(Editor, self).__init__(parent)
        self.setAcceptDrops(False)

        self.debugWindow = debugWindow

        self.setTabWidth(4)
        
        self.setBraceMatching(QsciScintilla.SloppyBraceMatch)
        self.setAutoIndent(1)
        self.setIndentationWidth(4)
        self.setIndentationGuides(1)
        self.setIndentationsUseTabs(0)
        self.setAutoCompletionThreshold(2)
        #self.SendScintilla(QsciScintilla.SCI_SETTABWIDTH, 4)
    
        # Set the default font
        font = QFont()
        #font.setFamily('Monospace')
        font.setFixedPitch(True)
        font.setPointSize(10)
        self.setFont(font)
        self.setMarginsFont(font)

        # Margin 0 is used for line numbers
        fontmetrics = QFontMetrics(font)
        self.setMarginsFont(font)
        self.setMarginWidth(0, fontmetrics.width("00000"))
        self.setMarginLineNumbers(0, True)
        self.setMarginsBackgroundColor(QColor("#E6E6E6"))

        # Clickable margin 1 for showing markers
        self.setMarginSensitivity(1, True)
        self.connect(self,
            SIGNAL('marginClicked(int, int, Qt::KeyboardModifiers)'),
            self.on_margin_clicked)

		# Define markers 
        self.markerDefine(QsciScintilla.Background, self.BACKGROUND_MARKER_NUM)
        self.markerDefine(QsciScintilla.RightTriangle, self.ARROW_MARKER_NUM)
        self.markerDefine(QsciScintilla.Circle, self.DEACTIVE_BREAK_MARKER_NUM)
        self.markerDefine(QsciScintilla.Circle, self.ACTIVE_BREAK_MARKER_NUM)

		# Red : #ee1111, Orange : #DB7F1E
        self.setMarkerBackgroundColor(QColor("#DB7F1E"), self.ARROW_MARKER_NUM)
        self.setMarkerForegroundColor(QColor("#DB7F1E"), self.ARROW_MARKER_NUM)

		# Light blue : ##C7E4E4, White : #FFFFFF
        self.setMarkerBackgroundColor(QColor("#FFFFFF"), self.ACTIVE_BREAK_MARKER_NUM)
        #self.setMarkerForegroundColor(QColor("#FFFFFF"), self.ACTIVE_BREAK_MARKER_NUM)

		# Gray : #C5C5C5
        self.setMarkerBackgroundColor(QColor("#C5C5C5"), self.DEACTIVE_BREAK_MARKER_NUM)
        #self.setMarkerForegroundColor(QColor("#C5C5C5"), self.DEACTIVE_BREAK_MARKER_NUM)

		# Light green : #7CD7A5
        #self.setMarkerBackgroundColor(QColor("#7CD7A5"), #self.BACKGROUND_MARKER_NUM)

        # Brace matching: enable for a brace immediately before or after
        # the current position
        #
        self.setBraceMatching(QsciScintilla.SloppyBraceMatch)

        # Current line visible with special background color
        self.setCaretLineVisible(True)
        self.setCaretLineBackgroundColor(QColor("#ffe4e4"))

        # Set Python lexer
        # Set style for Python comments (style number 1) to a fixed-width
        # courier.
        #
        lexer = QsciLexerLua()
        lexer.setDefaultFont(font)
        self.setLexer(lexer)

        #self.SendScintilla(QsciScintilla.SCI_STYLESETSIZE, 1, 12)
        #self.SendScintilla(QsciScintilla.SCI_STYLESETFORE, 1, 0xBFBFBF)
        #self.SendScintilla(QsciScintilla.SCI_STYLESETFONT, 1, 'Monospace')

        # Don't want to see the horizontal scrollbar at all
        # Use raw message to Scintilla here (all messages are documented
        # here: http://www.scintilla.org/ScintillaDoc.html)
        #self.SendScintilla(QsciScintilla.SCI_SETHSCROLLBAR, 0)

        # not too small
        #self.setMinimumSize(600, 450)
        
        QObject.connect(self, SIGNAL("SCN_CHARADDED(int)"), self.charAdded)
        QObject.connect(self, SIGNAL("textChanged()"), self.text_changed)
        #QObject.connect(self, SIGNAL("selectionChanged()"), self.ss_changed)
        self.text_status = TEXT_DEFAULT
        self.setWrapMode(QsciScintilla.WrapWord)
        self.line_click = {}
        self.current_line = -1
        self.editorManager = editorManager

    def get_bp_num(self, nline):
		data = sendTrickplayDebugCommand("9876", "b",False)
		bp_info = printResp(data, "b") # no need to print 
		m = 0
		for item in bp_info[3]: #info_var_list 
			if item == self.path+":"+str(nline+1) :
				return m
			m += 1

		
    def on_margin_clicked(self, nmargin, nline, modifiers):
        # Toggle marker for the line the margin was clicked on
		#print "on_margin_clicked"
		bp_num = 0
		print (nmargin)

		if not self.line_click.has_key(nline) or self.line_click[nline] == 0 :
			#if self.markersAtLine(nline) == 0:
			sendTrickplayDebugCommand("9876", "b "+self.path+":"+str(nline+1), False)
			data = sendTrickplayDebugCommand("9876", "b",False)
			bp_info = printResp(data, "b") # no need to print 
										   # bp_info need to be drawn in bp window 
			self.debugWindow.populateBreakTable(bp_info, self.editorManager)
			self.markerAdd(nline, self.ACTIVE_BREAK_MARKER_NUM)
			self.line_click[nline] = 1

		elif self.line_click[nline] == 1:

			bp_num = self.get_bp_num(nline)
			sendTrickplayDebugCommand("9876", "b "+str(bp_num)+" "+"off", False)
			self.markerDelete(nline, self.ACTIVE_BREAK_MARKER_NUM)
			self.markerAdd(nline, self.DEACTIVE_BREAK_MARKER_NUM)
			data = sendTrickplayDebugCommand("9876", "b",False)
			bp_info = printResp(data, "b") # no need to print 
										   # bp_info need to be drawn in bp window 
			self.debugWindow.populateBreakTable(bp_info, self.editorManager)
			self.line_click[nline] = 2

		elif self.line_click[nline] == 2:

			bp_num = self.get_bp_num(nline)
			sendTrickplayDebugCommand("9876", "d "+str(bp_num), False)
			self.markerDelete(nline, self.DEACTIVE_BREAK_MARKER_NUM)
			data = sendTrickplayDebugCommand("9876", "b",False)
			bp_info = printResp(data, "b") # no need to print 
										   # bp_info need to be drawn in bp window 
			self.debugWindow.populateBreakTable(bp_info, self.editorManager)
			self.line_click[nline] = 0
		
		#if self.markersAtLine(nline) == 0:
            
    def readFile(self, path):
        self.setText(open(path).read())
        
    #def ss_changed(self):
		#print "SS changed "

    def text_changed(self):
		if self.text_status == TEXT_DEFAULT:
			self.text_status = TEXT_READ 
		else:
			self.text_status = TEXT_CHANGED

    #def save(self, statusBar):
    def save(self):
        path = self.path
        try:
            f = open(path,'w+')
        except:
            #statusBar.message('Could not write to %s' % (path),2000)
            print 'Could not write to path'
            return
        
        f.write(self.text())
        self.text_status = TEXT_READ 
        f.close()
        
        #statusBar.showMessage('File %s saved' % (path), 2000)
        print 'File saved'
        
    def charAdded(self, c):
        """
        Notification every time a character is typed, used for bringing up
        autocomplete or calltip menus.
        """
        
        #print(int(c))
        pass
        ## :
        #if c == 58:
        #    self.SendScintilla(QsciScintilla.SCI_AUTOCSHOW, 0, UI_ELEMENT_FUNCTIONS + UI_CONTAINER_FUNCTIONS)
        #
        ## ()
        #elif c == 40:
        #    pos = self.SendScintilla(QsciScintilla.SCI_GETCURRENTPOS)
        #    self.SendScintilla(QsciScintilla.SCI_INSERTTEXT, pos, ')')
        #    
        ## {}
        #elif c == 123:
        #    pos = self.SendScintilla(QsciScintilla.SCI_GETCURRENTPOS)
        #    self.SendScintilla(QsciScintilla.SCI_INSERTTEXT, pos, '}')
        #
        ## .
        #elif c == 46:
        #    self.SendScintilla(QsciScintilla.SCI_AUTOCSHOW, 0, UI_ELEMENT_PROPS + UI_CONTAINER_PROPS)
        
if __name__ == "__main__":
    app = QApplication(sys.argv)
    editor = Editor()
    editor.show()
    editor.setText(open(sys.argv[0]).read())
    app.exec_()
    
UI_CONTAINER_FUNCTIONS = 'add remove clear foreach_child find_child raise_child lower_child'
UI_ELEMENT_FUNCTIONS = 'animate blur complete_animation desaturate grab_key_focus hide hide_all lower lower_to_bottom move_anchor_point move_by pageflatten pageturn raise raise_to_top saturate set show show_all tint transform_point unblur unparent untint'
UI_ELEMENT_PROPS = 'anchor_point center clip clip_to_size depth gid h has_clip height is_animating is_rotated is_scaled is_visible min_size name natural_size opacity parent position reactive request_mode scale size transformed_position transformed_size w width x x_rotation y y_rotation z z_rotation'
UI_CONTAINER_PROPS = 'count children'
