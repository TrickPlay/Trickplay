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
    ARROW_MARKER_NUM = 3
    ARROW_ACTIVE_BREAK_MARKER_NUM = 4
    ARROW_DEACTIVE_BREAK_MARKER_NUM = 5
    
    def __init__(self, editorManager=None, parent=None):
        super(Editor, self).__init__(parent)
        self.setAcceptDrops(False)

        self.editorManager = editorManager
        self.debugWindow = editorManager.debugWindow
        self.deviceManager = editorManager.deviceManager

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
        font.setStyleHint(font.Monospace)
        font.setFamily('Inconsolata')
        font.setPointSize(14)
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
            SIGNAL('copyAvailable(bool)'),
            self.copyAvailable)

        self.connect(self,
            SIGNAL('marginClicked(int, int, Qt::KeyboardModifiers)'),
            self.on_margin_clicked)

        self.connect(self,
            SIGNAL('modificationChanged(bool)'),
            self.modificationChanged)
		# Define markers 

        apath = self.editorManager.main.apath
        self.markerDefine(QPixmap(apath+"/Assets/currentline.png"), self.ARROW_MARKER_NUM)
        self.markerDefine(QPixmap(apath+"/Assets/breakpoint-off.png"), self.DEACTIVE_BREAK_MARKER_NUM)
        self.markerDefine(QPixmap(apath+"/Assets/breakpoint-on.png"), self.ACTIVE_BREAK_MARKER_NUM)
        self.markerDefine(QPixmap(apath+"/Assets/breakpoint-off-currentline.png"), self.ARROW_DEACTIVE_BREAK_MARKER_NUM)
        self.markerDefine(QPixmap(apath+"/Assets/breakpoint-on-currentline.png"), self.ARROW_ACTIVE_BREAK_MARKER_NUM)
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

        self.SendScintilla(QsciScintilla.SCI_STYLESETSIZE, lexer.Comment, font.pointSize())
        self.SendScintilla(QsciScintilla.SCI_STYLESETFONT, lexer.Comment, font.family())
        self.SendScintilla(QsciScintilla.SCI_STYLESETSIZE, lexer.LineComment, font.pointSize())
        self.SendScintilla(QsciScintilla.SCI_STYLESETFONT, lexer.LineComment, font.family())

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
        self.path = None
        self.tempfile = False
        self.margin_nline = None

    def get_bp_num(self, nline): #from break points table 
        #print("TABLE LEN = %s"%str(self.editorManager.main._debug.ui.breakTable.rowCount()))
        editorName = os.path.basename(str(self.path))
        editorName = editorName+":%s"%str(nline+1)
        #print("Editor Name = %s"%editorName)
        rowCnt = self.editorManager.main._debug.ui.breakTable.rowCount()

        for r in range(0, rowCnt):
            cellItem = self.editorManager.main._debug.ui.breakTable.item(r, 0) 
            #print (cellItem.whatsThis())
            if cellItem.whatsThis() == editorName :
                #print ("R [%s] Found !"%str(r))
                return r
    """
    def get_bp_num(self, nline): # from b response 
		data = sendTrickplayDebugCommand("9876", "b",False)
		bp_info = printResp(data, "b") # no need to print 
		m = 0
		for item in bp_info[3]: #info_var_list 
			if item == self.path+":"+str(nline+1) :
				return m
			m += 1
    """
    def modificationChanged(self, changed):
        if self.isRedoAvailable() == True:
            self.editorManager.main.ui.actionRedo.setEnabled(True)
        else :
            self.editorManager.main.ui.actionRedo.setEnabled(False)

        index = self.editorManager.tab.currentIndex()
        if self.isUndoAvailable() == True and self.text_status is not TEXT_DEFAULT :
            self.editorManager.main.ui.actionUndo.setEnabled(True)
            tabTitle = self.editorManager.tab.tabText(index)
            if tabTitle[:1] != "*":
                self.editorManager.tab.setTabText (index, "*"+self.editorManager.tab.tabText(index))
        elif self.isUndoAvailable() == True and self.tempfile is True :
            self.editorManager.main.ui.actionUndo.setEnabled(True)
            tabTitle = self.editorManager.tab.tabText(index)
            if tabTitle[:1] != "*":
                self.editorManager.tab.setTabText (index, "*"+self.editorManager.tab.tabText(index))
        else :
            self.editorManager.main.ui.actionUndo.setEnabled(False)
            tabTitle = self.editorManager.tab.tabText(index)
            if tabTitle[:1] == "*":
                self.editorManager.tab.setTabText (index, tabTitle[1:])
        
    def copyAvailable(self, avail):
        self.editorManager.main.ui.action_Cut.setEnabled(avail)
        self.editorManager.main.ui.action_Copy.setEnabled(avail)
        self.editorManager.main.ui.action_Delete.setEnabled(avail)
        
    def on_margin_clicked(self, nmargin, nline, modifiers):
        

		bp_num = 0
		self.margin_nline = nline

        # Break Point ADD 
		if not self.line_click.has_key(nline) or self.line_click[nline] == 0 :
			#t_path = self
			n = re.search(self.deviceManager.path(), str(self.path)).end()
			#t_path = os.path.basename(str(self.path))
			t_path = str(self.path)[n:]
			if t_path.startswith("/"):
			    t_path = t_path[1:]

			if self.editorManager.main.debug_mode == True :
			    self.deviceManager.send_debugger_command("%s "%DBG_CMD_BREAKPOINT+"%s:"%t_path+"%s"%str(nline+1))
			else :
			    pass
			    if self.current_line != nline :
			        self.markerAdd(nline, self.ACTIVE_BREAK_MARKER_NUM)
			    else:
			        self.markerDelete(nline, self.ARROW_MARKER_NUM)
			        self.markerAdd(nline, self.ARROW_ACTIVE_BREAK_MARKER_NUM)
			    #self.debugWindow.populateBreakTable(bp_info, self.editorManager)
			    self.line_click[nline] = 1

        # Break Point Deactivate  
		elif self.line_click[nline] == 1:

			bp_num = self.get_bp_num(nline)

			if self.editorManager.main.debug_mode == True :
			    self.deviceManager.send_debugger_command("%s "%DBG_CMD_BREAKPOINT+"%s "%str(bp_num)+"off")
			else:
			    pass
			    if self.current_line != nline :
				    self.markerDelete(nline, self.ACTIVE_BREAK_MARKER_NUM)
				    self.markerAdd(nline, self.DEACTIVE_BREAK_MARKER_NUM)
			    else :
				    self.markerDelete(nline, self.ARROW_ACTIVE_BREAK_MARKER_NUM)
				    self.markerAdd(nline, self.ARROW_DEACTIVE_BREAK_MARKER_NUM)

			    self.editorManager.bp_info[1].pop(bp_num)
			    self.editorManager.bp_info[1].insert(bp_num, "off")

			    #self.debugWindow.populateBreakTable(self.editorManager.bp_info, self.editorManager)
			    self.line_click[nline] = 2

        # Break Point Activate  
		elif self.line_click[nline] == 2:

			bp_num = self.get_bp_num(nline)
			if self.editorManager.main.debug_mode == True :
			    self.deviceManager.send_debugger_command("%s "%DBG_CMD_BREAKPOINT+"%s "%str(bp_num)+"on")
			else:
			    pass
			    if self.current_line != nline :
				    self.markerDelete(nline, self.DEACTIVE_BREAK_MARKER_NUM)
			    else :
				    self.markerDelete(nline, self.ARROW_DEACTIVE_BREAK_MARKER_NUM)
				    self.markerAdd(nline, self.ARROW_MARKER_NUM)
			    #self.debugWindow.populateBreakTable(bp_info, self.editorManager)
			    self.line_click[nline] = 1

    def readFile(self, path):
        self.setText(open(path).read())
        
    #def ss_changed(self):
		#print "SS changed "

    def text_changed(self):

		if self.tempfile == True and self.text_status != TEXT_CHANGED:
			self.text_status = TEXT_READ

		if self.text_status == TEXT_DEFAULT or self.text_status != TEXT_CHANGED:#(self.text_status == TEXT_READ and self.path == self.editorManager.tab.editors[0].path):
			index = 0 
			for edt in self.editorManager.tab.editors :
				if edt.path == self.path:
				    if self.isUndoAvailable() is True:
					    #self.editorManager.tab.setTabText (index, "*"+self.editorManager.tab.tabText(index))
					    pass
				index = index + 1

		if self.text_status == TEXT_DEFAULT:
			self.text_status = TEXT_READ 
		else:
			self.text_status = TEXT_CHANGED

    def save(self):
        path = self.path
        try:
            f = open(path,'w+')
            f.write(self.text())
            f.close()
        except:
            #statusBar.message('Could not write to %s' % (path),2000)
            pass
        
        self.text_status = TEXT_READ 
        
        index = 0 
        if self.editorManager is not None :
        	for edt in self.editorManager.tab.editors :
				if edt.path == self.path :
					tabTitle = self.editorManager.tab.tabText(index)
					if tabTitle[:1] == "*":
						self.editorManager.tab.setTabText (index, tabTitle[1:])
					break
				index = index + 1

        	self.editorManager.tab.textBefores[index] = self.text()
        	self.tempfile = False
        	if self.path is not None :
        	    print '[VDBG] \''+self.path+'\' File saved'
        else: 
			self.tempfile = True

        #statusBar.showMessage('File %s saved' % (path), 2000)
        
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
