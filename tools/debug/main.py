import os
import sys
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *

# UI File
from TreeView import Ui_MainWindow

from devices import TrickplayDiscovery
from editor import LuaEditor
from push import TrickplayPushApp
from connection import CON
from wizard import Wizard
from files import FileSystemModel
from editorTab import EditorTabWidget, EditorDock
from inspector import Inspector

class MainWindow(QMainWindow):
    
    def __init__(self, app, parent = None):
        
        # Main window setup
        QWidget.__init__(self, parent)
        
        # Restore size/position of window
        settings = QSettings()
        self.restoreGeometry(settings.value("mainWindowGeometry").toByteArray());
        
        # Main UI file, from Qt Designer, converted to .py using pyuic4
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        # Setup
        self.ui.lineEdit.setPlaceholderText("Search by GID or Name")
        
        # Create Editor
        self.createEditor()
        
        # Create Inspector
        self.inspector = Inspector(self.ui.inspector, self.ui.property) 
        
        # Toolbar
        QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        QObject.connect(self.ui.action_Save, SIGNAL('triggered()'),  self.save)

                
        # Buttons
        QObject.connect(self.ui.button_Refresh, SIGNAL("clicked()"), self.inspector.refresh)        
        QObject.connect(self.ui.button_Search, SIGNAL("clicked()"),  self.inspector.search)
        QObject.connect(self.ui.pushAppButton, SIGNAL("clicked()"),  self.pushApp)
        QObject.connect(self.ui.runButton, SIGNAL("clicked()"),  self.run)
        
        # Restore sizes/positions of docks
        self.restoreState(settings.value("mainWindowState").toByteArray());
        
        self.path = None
        
        QObject.connect(app, SIGNAL('aboutToQuit()'), self.cleanUp)
        
        self.app = app
        self.trickplay = QProcess()
        
    def run(self):
        if self.trickplay.state() == QProcess.Running:
            self.trickplay.close()
        print('exit status', self.trickplay.exitStatus())
        self.trickplay.start('/usr/bin/trickplay', [self.path])
        
        
    """
    Cleanup code goes here... nothing yet?
    """
    def cleanUp(self):
        # If there is a running trickplay, terminate it
        try:
            print(self.trickplay.state())
            #if self.trickplay.state() == QProcess.Running:
            self.trickplay.terminate()
            #    print('terminated trickplay')
        except AttributeError, e:
            pass
        print('quitting')
            
    """
    Initialize widgets on the main window with a given app path
    """
    def start(self, path, openList = None):
        self.path = path
        self.inspector.createTree()
        self.createFileSystem(path)
        self.discovery = TrickplayDiscovery(self.ui.deviceComboBox, self)
        
        if openList:
            for file in openList:
                self.newEditor(file)

    """
    Save window and dock geometry on close
    """
    def closeEvent(self, event):
        settings = QSettings()
        settings.setValue("mainWindowGeometry", self.saveGeometry());
        settings.setValue("mainWindowState", self.saveState());
    
    def pushApp(self):    
        print('Pushing app to', CON.get())
        tp = TrickplayPushApp(str(self.path))
        tp.push(address = CON.get())
        
    """
    Create editor in a new dock that accepts drop events from the FileSystemModel
    """
    def createEditor(self):
        
        self.splitter = QSplitter()
        
        mainGrid = QGridLayout(self.ui.centralwidget)
        
        # Dock in MainWindow
        dock = EditorDock(self, self.ui.centralwidget)
        
        frame = QWidget()
        grid = QGridLayout(frame)
        hbox = QHBoxLayout()
        grid.addLayout(hbox, 0, 1, 1, 1)
        
        dock.setWidget(frame)
        
        dock.setWidget(self.splitter)
        
        mainGrid.addWidget(dock, 0, 0, 1, 1)
        
        self.editorGroups = []
        self.editors = {}

    """
    Set up the file system model
    """
    def createFileSystem(self, appPath):
        QObject.connect(self.ui.fileSystem, SIGNAL('doubleClicked( QModelIndex )'), self.openInEditor)
        self.fileModel = FileSystemModel(self.ui.fileSystem, appPath)
        
    def getFileSystemModel(self):
        return self.fileModel
    
    def getFileSystemView(self):
        return self.ui.fileSystem
    
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
        if isinstance(editor, LuaEditor):
            editor.save(self.statusBar())
        else:
            self.statusBar().showMessage('Failed to save because no text editor is currently selected.', 2000)                

    """
    Accept a file either by dragging onto the editor dock or into one of the
    editor tab widget
    """
    def dropFileEvent(self, event, src, w = None):
        
        #print('From', event.source(), event.mimeData().hasText())
            
        n = self.getTabWidgetNumber(w)
        
        # This external file can be opened as plain text
        if event.mimeData().hasText():
            event.acceptProposedAction()
            path = str(event.mimeData().urls()[0].path())
            self.newEditor(path, n)
            
        # This file is from the fileSystem view
        elif event.source() == self.getFileSystemView():
            self.openInEditor(event.source().currentIndex(), n)
            
        else:
            print('Failed to open dropped file.')


    """
    Open a file from the FileSystemModel in the correct tab widget.
    """
    def openInEditor(self, fileIndex, n = None):
        if not self.fileModel.isDir(fileIndex):
            path = self.fileModel.filePath(fileIndex)
            self.newEditor(path, n)            
    
    """
    Create a tab group if both don't exist,
    then add an editor in the correct tab widget.
    """
    def newEditor(self, path, tabGroup = None):
        
        path = str(path)
        name = os.path.basename(str(path))
            
        editor = LuaEditor()
        
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
 
        
    def exit(self):
        sys.exit()
        
        