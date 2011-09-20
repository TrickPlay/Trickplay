from PyQt4.QtCore import *
from PyQt4.QtGui import *

import os

from EditorTab import EditorTabWidget, EditorDock
from Editor import Editor



class EditorManager(QWidget):    
    
    def __init__(self, fileSystem, parent = None):
    
        QWidget.__init__(self)
        
        self.setupUi(parent)
        
        self.fileSystem = fileSystem
    
    
    def setupUi(self, parent):
        """
        Set up the editor UI where two QTabWidgets are arranged in a QSplitter
        """
        
        self.splitter = QSplitter()
        
        mainGrid = QGridLayout(parent)
        
        # Dock in MainWindow
        dock = EditorDock(self, parent)
        
        frame = QWidget()
        grid = QGridLayout(frame)
        hbox = QHBoxLayout()
        grid.addLayout(hbox, 0, 1, 1, 1)
        
        dock.setWidget(frame)
        
        dock.setWidget(self.splitter)
        
        mainGrid.addWidget(dock, 0, 0, 1, 1)
        
        self.editorGroups = []
        self.editors = {}
        
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

    def save(self):
        editor = self.app.focusWidget()
        if isinstance(editor, Editor):
            editor.save(self.statusBar())
        else:
            self.statusBar().showMessage('Failed to save because no text editor is currently selected.', 2000)                
        
    def newEditor(self, path, tabGroup = None):
        """
        Create a tab group if both don't exist,
        then add an editor in the correct tab widget.
        """
        
        path = str(path)
        name = os.path.basename(str(path))
            
        editor = Editor()
        
        # If the file is already open, just use the open document
        if self.editors.has_key(path):
            editor.setDocument(self.editors[path].document())
        else:
            editor.readFile(path)
        
        nTabGroups = len(self.editorGroups)
        
        # If there is already one tab group, create a new one in split view and open the file there  
        if 1 == nTabGroups:
            self.editorGroups.append(self.EditorTabWidget(self.splitter))
            tabGroup = 1
        
        # If there are no tab groups, create the first one
        elif 0 == nTabGroups:
            self.editorGroups.append(self.EditorTabWidget(self.splitter))
            tabGroup = 0
            
        # Default to opening in the first tab group
        elif not tabGroup:
            tabGroup = 0
        
        index = self.editorGroups[tabGroup].addTab(editor, name)
        
        if not self.editors.has_key(path):
            self.editors[path] = editor
        
        self.editorGroups[tabGroup].setCurrentIndex(index)
        editor.setFocus()
        editor.path = path
        
    def dropFileEvent(self, event, src, w = None):
        """
        Accept a file either by dragging onto the editor dock or into one of the
        editor tab widgets
        """
        
        #print('From', event.source(), event.mimeData().hasText())
            
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
 