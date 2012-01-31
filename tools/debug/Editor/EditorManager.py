from PyQt4 import QtCore, QtGui

import os
import re

from EditorTab import EditorTabWidget, EditorDock
from Editor import Editor
from UI.SaveAsDialog import Ui_saveAsDialog
from PyQt4.Qsci import QsciScintilla, QsciLexerLua



class EditorManager(QtGui.QWidget):    
    
    def __init__(self, fileSystem, debugWindow, parent = None):
    
        QtGui.QWidget.__init__(self)
        
        self.setupUi(parent)
        
        self.fileSystem = fileSystem

        self.debugWindow = debugWindow

        self.tab = None

        self.currentEditor = None

    
    
    def setupUi(self, parent):
        """
        Set up the editor UI where two QTabWidgets are arranged in a QSplitter
        """
        
        self.splitter = QtGui.QSplitter()
        mainGrid = QtGui.QGridLayout(parent)
        mainGrid.setSpacing(0)
        mainGrid.setMargin(0)

        # Dock in MainWindow
        dock = EditorDock(self, parent)
        
        container = QtGui.QWidget()

        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(container.sizePolicy().hasHeightForWidth())
        container.setSizePolicy(sizePolicy)
        container.setMinimumSize(QtCore.QSize(0, 0))
        font = QtGui.QFont()
        font.setPointSize(10)
        container.setFont(font)

        grid = QtGui.QGridLayout(container)

        grid.setSpacing(0)
        grid.setMargin(0)

        hbox = QtGui.QHBoxLayout()

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
        tab = EditorTabWidget(self, self.splitter)
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

    def save(self):
		editor = self.app.focusWidget()
		if isinstance(editor, Editor):
			currentText = open(editor.path).read()
			index = self.tab.currentIndex()
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
			editor.save()
		else:
			print 'Failed to save because no text editor is currently selected.'                
		

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
			print "Save As .. "+new_path

			currentText = open(editor.path).read()
			index = self.tab.currentIndex()
			self.tab.textBefores[index] = editor.text()
			editor.text_status = 1 
			editor.path = new_path
			editor.save()
			self.close()
			self.newEditor(new_path)

		

    def newEditor(self, path, tabGroup = None, line_no = None, prev_file = None, currentLine = False):
        """
        Create a tab group if both don't exist,
        then add an editor in the correct tab widget.
        """

        path = str(path)
        name = os.path.basename(str(path))
        editor = Editor(self.debugWindow, self, None)
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

        		editor.readFile(path) 

            if closedTab != path:
				for k in self.editors:
					if path == k:
						self.editorGroups[tabGroup].setCurrentIndex(self.editors[k][1])
						if line_no != None:
							self.tab.editors[self.editors[k][1]].SendScintilla(QsciScintilla.SCI_GOTOLINE, int(line_no) - 1)
							self.currentEditor = self.tab.editors[self.editors[k][1]]
							if currentLine == True :
								if self.tab.editors[self.editors[k][1]].current_line > -1 :
									self.tab.editors[self.editors[k][1]].markerDelete(self.tab.editors[self.editors[k][1]].current_line, Editor.ARROW_MARKER_NUM)
								elif prev_file != None:
									if closedTab != prev_file:
										for j in self.editors:
											if prev_file == j:
												self.tab.editors[self.editors[j][1]].markerDelete(self.tab.editors[self.editors[j][1]].current_line, Editor.ARROW_MARKER_NUM)
												self.tab.editors[self.editors[j][1]].current_line = -1
								if path == k:
									self.tab.editors[self.editors[k][1]].markerAdd(int(line_no) -1, Editor.ARROW_MARKER_NUM)
									self.tab.editors[self.editors[k][1]].current_line = int(line_no) -1 
				return
        else:
            editor.readFile(path)
        
        if not self.editors.has_key(path):
            self.tab.paths.append(path)
            self.tab.textBefores.append(editor.text())
            self.tab.editors.append(editor)

        index = self.editorGroups[tabGroup].addTab(editor, name)

        if not self.editors.has_key(path):
            self.editors[path] = [editor, index]
        
        self.editorGroups[tabGroup].setCurrentIndex(index)
        editor.setFocus()
        editor.path = path

        if not line_no == None:
			editor.SendScintilla(QsciScintilla.SCI_GOTOLINE, int(line_no) - 1)
			self.currentEditor = editor
			if currentLine == True :
				if editor.current_line > -1 :
					editor.markerDelete(
						edito.current_line, 
						Editor.ARROW_MARKER_NUM)
				elif prev_file != None:
					for l in self.editors:
						if prev_file == l:
							self.tab.editors[self.editors[l][1]].markerDelete(self.tab.editors[self.editors[l][1]].current_line, Editor.ARROW_MARKER_NUM)
							self.tab.editors[self.editors[l][1]].current_line = -1

				editor.markerAdd(int(line_no) -1, Editor.ARROW_MARKER_NUM)
				editor.current_line = int(line_no) -1 

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
            print('Failed to open dropped file.')
        
    def openFromFileSystem(self, fileIndex, n = None):
        """
        Open a file from the FileSystemModel in the correct tab widget.
        """
        
        model = self.fileSystem.model
        
        if not model.isDir(fileIndex):
            path = model.filePath(fileIndex)
            
            self.newEditor(path, n)       
