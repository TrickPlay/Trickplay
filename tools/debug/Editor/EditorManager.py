from PyQt4.QtGui import *
from PyQt4.QtCore import *

import os
import re

from EditorTab import EditorTabWidget, EditorDock
from Editor import Editor
from UI.SaveAsDialog import Ui_saveAsDialog
from PyQt4.Qsci import QsciScintilla, QsciLexerLua



class EditorManager(QWidget):    
    
    def __init__(self, main=None, windowsMenu = None, parent = None):
    
        QWidget.__init__(self)
        self.windowsMenu = windowsMenu
        self.main = main
        self.setupUi(parent)
        self.fileSystem = main._fileSystem
        self.debugWindow = main._debug
        self.deviceManager = None
        self.tab = None
        self.currentEditor = None


    def setupUi(self, parent):
        """
        Set up the editor UI where two QTabWidgets are arranged in a QSplitter
        """
        
        self.splitter = QSplitter()
        mainGrid = QGridLayout(parent)
        mainGrid.setSpacing(0)
        mainGrid.setMargin(0)

        # Dock in MainWindow
        dock = EditorDock(self, parent)
        
        container = QWidget()

        sizePolicy = QSizePolicy(QSizePolicy.Preferred, QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(container.sizePolicy().hasHeightForWidth())
        container.setSizePolicy(sizePolicy)
        container.setMinimumSize(QSize(0, 0))
        font = QFont()
        font.setStyleHint(font.Monospace)
        font.setFamily('Monospace')
        font.setPointSize(10)
        container.setFont(font)

        grid = QGridLayout(container)

        grid.setSpacing(0)
        grid.setMargin(0)

        hbox = QHBoxLayout()

        hbox.setSpacing(0)
        hbox.setMargin(0)

        grid.addLayout(hbox, 0, 1, 1, 1)
        
        dock.setWidget(container)

        dock.setWidget(self.splitter)
        mainGrid.addWidget(dock, 0, 0, 1, 1)
        
        self.editorGroups = []
        self.editors = {}
        self.app = parent
        
    def getEditorTabs(self):
        return self.editorGroups
    
    def EditorTabWidget(self, parent = None):
        tab = EditorTabWidget(self, self.windowsMenu, self.fileSystem, self.splitter)
        tab.setObjectName('EditorTab' + str(len(self.editorGroups)))
        return tab
    
    def getTabWidgetNumber(self, w):
        for n in range(len(self.editorGroups)):
            if self.editorGroups[n] == w:
                return n
        return None
    def scan(self, path):
        """
        Scan the path given:
        If path is not valid dir return 0 
		Otherwise, it returns 1
        """
        
        if os.path.isdir(path):
            files = os.listdir(path)
            return 1
        else:
			return 0
            
                  
    def adjustDialog(self, path):
        
        result = self.scan(str(path))
        
        # If the path is a directory...
        if 0 == result:
            msg = QMessageBox()
            msg.setText(path+'is not a valid directory.') 
            msg.setInformativeText('Please select a directory to save the file.')
            msg.setWindowTitle("Warning")
            msg.exec_()
        elif 1 == result:
        	return result

    def chooseDirectoryDialog(self):
		dir = self.ui.directory.text()
		path = QFileDialog.getExistingDirectory(None, 'Select app directory', dir)
		result = self.adjustDialog(path)
		if result > 0:
			self.ui.directory.setText(path)

    def save(self, editor_index = None):
		
		editor = None
		if editor_index is not None:
			editor = self.tab.editors[editor_index]
		else:
			editor = self.app.focusWidget()

	
		if isinstance(editor, Editor):
			if editor.tempfile == False:
				currentText = open(editor.path).read()
			else:
				self.saveas()
				return 

			index = self.tab.currentIndex()
			#comment 2/3 next if block
			"""
			if self.tab.textBefores[index] != currentText:
				if editor.text_status == 2: #TEXT_CHANGED
					msg = QMessageBox()
					msg.setText('The file "' + editor.path + '" changed on disk.')
					msg.setInformativeText('If you save it external changes could be lost.')
					msg.setStandardButtons(QMessageBox.Save | QMessageBox.Cancel)
					msg.setDefaultButton(QMessageBox.Cancel)
					msg.setWindowTitle("Warning")
					ret = msg.exec_()

					if ret == QMessageBox.Save:
						self.tab.textBefores[index] = editor.text()
						editor.text_status = 1 #TEXT_READ
						editor.save()
					else:
						return None
			"""
			editor.save()
			self.tab.textBefores[index] = editor.text() ## new 2/3 
		else:
			print '[VDBG] Failed to save because no text editor is currently selected.'                
		
    def saveall(self):
		index = 0 
		for editor in self.tab.editors :
			self.save(index)
			index = index + 1

    def close(self):
		
		index = self.tab.currentIndex()
		self.tab.closeTab(index)

    def saveas(self):
		self.dialog = QDialog()
		self.ui = Ui_saveAsDialog()
		self.ui.setupUi(self.dialog)

		editor = self.app.focusWidget()

		cur_file = re.search('(\w+)[.](\w+)', editor.path).group()
		cur_dir = editor.path[:re.search('(\w+)[.](\w+)', editor.path).start()-1]

		self.ui.filename.setText(cur_file)
		self.ui.directory.setText(cur_dir)

		QObject.connect(self.ui.browse, SIGNAL('clicked()'), self.chooseDirectoryDialog)

		if self.dialog.exec_():
			
			cur_dir = self.ui.directory.text() 
			cur_file = self.ui.filename.text() 

			new_path = cur_dir+'/'+cur_file
			print "[VDBG] Save As .. ' %s '"%new_path

			if editor.tempfile == False :
				currentText = open(editor.path).read()
				index = self.tab.currentIndex()
				self.tab.textBefores[index] = editor.text()
				editor.text_status = 1 
				editor.path = new_path
				editor.save()
				self.close()
				self.newEditor(new_path)
			else :
				index = self.tab.currentIndex()
				self.tab.textBefores[index] = editor.text()
				editor.text_status = 1 
				editor.path = new_path
				editor.save()
				self.close()
				editor = self.newEditor(new_path,None,None,None,False,None,True)

    def newEditor(self, path, tabGroup = None, line_no = None, prev_file = None, currentLine = False, fileIndex=None, tempfile = False):
        """
        Create a tab group if both don't exist,
        then add an editor in the correct tab widget.
        """

        if self.deviceManager is None:
            self.deviceManager = self.main._deviceManager

        path = str(path)
        name = os.path.basename(str(path))
        editor = Editor(self, None)

        editor.tempfile = tempfile
        editor.fileIndex = fileIndex

        closedTab = None

        # Default to opening in the first tab group
        tabGroup = 0
        
        nTabGroups = len(self.editorGroups)

		# If there is already one tab group, create a new one in split view and open the file there  
        if 0 == nTabGroups:
            self.tab = self.EditorTabWidget(self.splitter)
            self.editorGroups.append(self.tab) 
        # If the file is already open, just use the open document
        if self.editors.has_key(path):
            for k in self.editors:
				if not k in self.tab.paths:
					closedTab = k

            if closedTab != None:
        		self.editors.pop(closedTab)
        		for k in self.tab.paths:
					self.editors[k][1] = self.tab.paths.index(k) 
        		if editor.tempfile == False:
        			editor.readFile(path) 

            if closedTab != path:
				for k in self.editors:
					if path == k:
						curIndex = self.editors[k][1]
						self.editorGroups[tabGroup].setCurrentIndex(curIndex)
						if line_no != None:
							self.currentEditor = self.tab.editors[curIndex]
							self.currentEditor.SendScintilla(QsciScintilla.SCI_GOTOLINE, int(line_no)) # -1
							if currentLine == True :
								if self.currentEditor.current_line > -1 :
									if not self.currentEditor.line_click.has_key(self.currentEditor.current_line) or self.currentEditor.line_click[self.currentEditor.current_line] == 0 :
										self.currentEditor.markerDelete(self.currentEditor.current_line, 
																	Editor.ARROW_MARKER_NUM)
									elif self.currentEditor.line_click[self.currentEditor.current_line] == 1 :
										self.currentEditor.markerDelete(self.currentEditor.current_line, 
																	Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
										self.currentEditor.markerAdd(self.currentEditor.current_line, 
																	Editor.ACTIVE_BREAK_MARKER_NUM)
									elif self.currentEditor.line_click[self.currentEditor.current_line] == 2 :
										self.currentEditor.markerDelete(self.currentEditor.current_line, 
																	Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
										self.currentEditor.markerAdd(self.currentEditor.current_line, 
																	Editor.DEACTIVE_BREAK_MARKER_NUM)
								elif prev_file != None:
									if closedTab != prev_file:
										for j in self.editors:
											if prev_file == j:
												prevIndex = self.editors[j][1]
												curLine = self.tab.editors[prevIndex].current_line
												prevEditor = self.tab.editors[prevIndex]
												if not prevEditor.line_click.has_key(curLine) or prevEditor.line_click[curLine] == 0:
													prevEditor.markerDelete( curLine, Editor.ARROW_MARKER_NUM)
												elif prevEditor.line_click[curLine] == 1:
													prevEditor.markerDelete( curLine, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
													prevEditor.markerAdd( curLine, Editor.ACTIVE_BREAK_MARKER_NUM)
												elif prevEditor.line_click[curLine] == 2:
													prevEditor.markerDelete( curLine, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
													prevEditor.markerAdd( curLine, Editor.DEACTIVE_BREAK_MARKER_NUM)
												self.tab.editors[prevIndex].current_line = -1
								if path == k:
									nextCurLine = int(line_no) -1
									if not self.currentEditor.line_click.has_key(nextCurLine) or self.currentEditor.line_click[nextCurLine] == 0: 
										self.currentEditor.markerAdd(nextCurLine, Editor.ARROW_MARKER_NUM)
									elif self.currentEditor.line_click[nextCurLine] == 1: 
										self.currentEditor.markerDelete(nextCurLine, Editor.ACTIVE_BREAK_MARKER_NUM)
										self.currentEditor.markerAdd(nextCurLine, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
									elif self.currentEditor.line_click[nextCurLine] == 2: 
										self.currentEditor.markerDelete(nextCurLine, Editor.DEACTIVE_BREAK_MARKER_NUM)
										self.currentEditor.markerAdd(nextCurLine, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
									self.currentEditor.current_line = nextCurLine
				return self.currentEditor
        elif tempfile == False:
            path = os.path.join (self.deviceManager.path(), path)
            editor.readFile(path)
        
        if 0 == nTabGroups:
			seperatorAction = self.windowsMenu.addSeparator()

        if not self.editors.has_key(path):
            self.tab.paths.append(path)
            self.tab.textBefores.append(editor.text())
            self.tab.editors.append(editor)

        index = self.editorGroups[tabGroup].addTab(editor, name)
        editor.tabIndex = index

        if not self.editors.has_key(path):
            self.editors[path] = [editor, index]
        
        self.editorGroups[tabGroup].setCurrentIndex(index)
        editor.setFocus()
        editor.path = path

        font = QFont()
        font.setStyleHint(font.Monospace)
        font.setFamily('Monospace')
        font.setPointSize(10)

        n = re.search("[/]+\S+[/]+", editor.path).end()
        fileName = editor.path[n:]
		
        editorAction = QAction(self.windowsMenu)
        editorAction.setText(fileName)
        editorAction.setIconText(editor.path)
        editorAction.setFont(font)
        editorAction.setShortcut(QApplication.translate("MainWindow", "Ctrl+"+str(index+1), None, QApplication.UnicodeUTF8))
        self.windowsMenu.addAction(editorAction)
        QObject.connect(editorAction , SIGNAL("triggered()"),  self, SLOT("moveToThisEditor()"))
        editor.windowsAction = editorAction 

        if not line_no == None:
			editor.SendScintilla(QsciScintilla.SCI_GOTOLINE, int(line_no))
			self.currentEditor = editor
			if currentLine == True :
				if editor.current_line > -1 :
					if not editor.line_click.has_key(editor.current_line) or editor.line_click[editor.current_line] == 0:
						editor.markerDelete( editor.current_line, Editor.ARROW_MARKER_NUM)
					if editor.line_click[editor.current_line] == 1:
						editor.markerDelete( editor.current_line, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
						editor.markerAdd( editor.current_line, Editor.ACTIVE_BREAK_MARKER_NUM)
					if editor.line_click[editor.current_line] == 2:
						editor.markerDelete( editor.current_line, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
						editor.markerAdd( editor.current_line, Editor.DEACTIVE_BREAK_MARKER_NUM)
				elif prev_file != None:
					for l in self.editors:
						if prev_file == l:
							prevEditor = self.tab.editors[self.editors[l][1]]
							curLine = self.tab.editors[self.editors[l][1]].current_line
							if not prevEditor.line_click.has_key(curLine) or prevEditor.line_click[curLine] == 0 :
								prevEditor.markerDelete(curLine, Editor.ARROW_MARKER_NUM)
							elif prevEditor.line_click[curLine] == 1 :
								prevEditor.markerDelete(curLine, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
								prevEditor.markerAdd(curLine, Editor.ACTIVE_BREAK_MARKER_NUM)
							elif prevEditor.line_click[curLine] == 0 :
								prevEditor.markerDelete(curLine, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
								prevEditor.markerAdd(curLine, Editor.DEACTIVE_BREAK_MARKER_NUM)
							self.tab.editors[self.editors[l][1]].current_line = -1

				if not editor.line_click.has_key(int(line_no) -1) or editor.line_click[int(line_no) -1] == 0:
					editor.markerAdd(int(line_no) -1, Editor.ARROW_MARKER_NUM)
				elif editor.line_click[int(line_no) -1] == 1:
					editor.markerDelete(int(line_no) -1, Editor.ACTIVE_BREAK_MARKER_NUM)
					editor.markerAdd(int(line_no) -1, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
				elif editor.line_click[int(line_no) -1] == 2:
					editor.markerDelete(int(line_no) -1, Editor.DEACTIVE_BREAK_MARKER_NUM)
					editor.markerAdd(int(line_no) -1, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
				editor.current_line = int(line_no) -1 
        return editor

    @pyqtSlot()
    def moveToThisEditor(self):
		senderAction = self.sender()
		self.newEditor(senderAction.iconText(), None)

    def dropFileEvent(self, index):
		pass
    def dropFileEvent(self, event, src, w = None):
        """
        Accept a file either by dragging onto the editor dock or into one of the
        editor tab widgets
        """
        n = self.getTabWidgetNumber(w)
        
        # This external file can be opened as plain text
        if event.mimeData().hasText():
            event.acceptProposedAction()
            path = str(event.mimeData().urls()[0].path())
            self.newEditor(path, n)
            
        # This file is from the fileSystem view
        elif event.source() == self.fileSystem.ui.view:
            self.openFromFileSystem(event.source().currentIndex(), n)
            
        else:
            print('[VDBG] Failed to open dropped file.')
        
    def openFromFileSystem(self, fileIndex, n = None):
        """
        Open a file from the FileSystemModel in the correct tab widget.
        """
        model = self.fileSystem.model
        
        if not model.isDir(fileIndex):
            path = model.filePath(fileIndex)
            
            self.newEditor(path, n, None, None, False, fileIndex, False)       
