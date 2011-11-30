import os
import sys
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.MainWindow import Ui_MainWindow

from connection import CON
from wizard import Wizard

from Inspector.TrickplayInspector import TrickplayInspector
from DeviceManager.TrickplayDeviceManager import TrickplayDeviceManager
from Editor.EditorManager import EditorManager
from FileSystem.FileSystem import FileSystem
from Console.TrickplayConsole import TrickplayConsole

signal.signal(signal.SIGINT, signal.SIG_DFL)

class MainWindow(QMainWindow):
    
    def __init__(self, app, parent = None):
        
        QWidget.__init__(self, parent)
        
        # Restore size/position of window
        settings = QSettings()
        self.restoreGeometry(settings.value("mainWindowGeometry").toByteArray());
        
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        # Create FileSystem
        self.ui.FileSystemDock.toggleViewAction().setText("&File System")
        self.ui.menuView.addAction(self.ui.FileSystemDock.toggleViewAction())
        #self.ui.FileSystemDock.toggleViewAction().triggered.connect(self.fs)
        self._fileSystem = FileSystem()
        self.ui.FileSystemLayout.addWidget(self._fileSystem)
        
        # Create Editor
        self._editorManager = EditorManager(self._fileSystem, self.ui.centralwidget)
        
        # Create Inspector
        self.ui.InspectorDock.toggleViewAction().setText("&Inspector")
        self.ui.menuView.addAction(self.ui.InspectorDock.toggleViewAction())
        #self.ui.InspectorDock.toggleViewAction().triggered.connect(self.isptr)
        self._inspector = TrickplayInspector()
        self.ui.InspectorLayout.addWidget(self._inspector)
        
        # Create DeviceManager
        self.ui.DeviceManagerDock.toggleViewAction().setText("&Device Manager")
        self.ui.menuView.addAction(self.ui.DeviceManagerDock.toggleViewAction())
        #self.ui.DeviceManagerDock.toggleViewAction().triggered.connect(self.dm)
        self._deviceManager = TrickplayDeviceManager(self._inspector)
        self.ui.DeviceManagerLayout.addWidget(self._deviceManager)
        
        # Create Console
        self.ui.ConsoleDock.toggleViewAction().setText("&Console")
        self.ui.menuView.addAction(self.ui.ConsoleDock.toggleViewAction())
        #self.ui.DeviceManagerDock.toggleViewAction().triggered.connect(self.dm)
        self._console = TrickplayConsole()
        self.ui.ConsoleLayout.addWidget(self._console)
	
		#File Menu
        QObject.connect(self.ui.action_New, SIGNAL("triggered()"),  self.new)
        QObject.connect(self.ui.action_Save, SIGNAL('triggered()'),  self.editorManager.save)
        QObject.connect(self.ui.action_Save_As, SIGNAL('triggered()'),  self.editorManager.saveas)
        QObject.connect(self.ui.action_Close, SIGNAL('triggered()'),  self.editorManager.close)
        QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        
		#Edit Menu
        QObject.connect(self.ui.actionUndo, SIGNAL("triggered()"),  self.editor_undo)
        QObject.connect(self.ui.actionRedo, SIGNAL("triggered()"),  self.editor_redo)
        QObject.connect(self.ui.action_Cut, SIGNAL("triggered()"),  self.editor_cut)
        QObject.connect(self.ui.action_Copy, SIGNAL("triggered()"),  self.editor_copy)
        QObject.connect(self.ui.action_Paste, SIGNAL("triggered()"),  self.editor_paste)
        QObject.connect(self.ui.action_Delete, SIGNAL("triggered()"),  self.editor_delete)
        QObject.connect(self.ui.actionSelect_All, SIGNAL("triggered()"),  self.editor_selectall)

        # Restore sizes/positions of docks
        self.restoreState(settings.value("mainWindowState").toByteArray());
        
        self.path = None
        
        QObject.connect(app, SIGNAL('aboutToQuit()'), self.cleanUp)
        
        self.app = app
        
    @property
    def fileSystem(self):
        return self._fileSystem
    
    @property
    def deviceManager(self):
        return self._deviceManager
    
    @property
    def editorManager(self):
        return self._editorManager
    
    @property
    def inspector(self):
        return self._inspector


    def editor_undo(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].undo()

    def editor_redo(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].redo()

    def editor_cut(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].cut()
	
    def editor_copy(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].copy()
	
    def editor_paste(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].paste()
	
    def editor_selectall(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].selectAll()
	
    def editor_delete(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].removeSelectedText()
	
    def cleanUp(self):
        """
        End running Trickplay process
        
        TODO: Somehow stop Trickplay Avahi service...
        """
        
        try:
            print('Trickplay state', self.deviceManager.trickplay.state())
            #if self.trickplay.state() == QProcess.Running:
            self.deviceManager.trickplay.close()
            #    print('terminated trickplay')
        except AttributeError, e:
            pass
        
        #print('quitting')
        
    
    def start(self, path, openList = None):
        """
        Initialize widgets on the main window with a given app path
        """
        
        print("main.start")
        self.path = path
        
        self.fileSystem.start(self.editorManager, path)
        
        self.deviceManager.setPath(path)
        
        if openList:
            for file in openList:
                self.editorManager.newEditor(file)

    def closeEvent(self, event):
        """
        Save window and dock geometry on close
        """
        
        settings = QSettings()
        settings.setValue("mainWindowGeometry", self.saveGeometry());
        settings.setValue("mainWindowState", self.saveState());
        
	
    def new(self):
		print "New project"

    def exit(self):
        """
        Close in a clean way... but still Trickplay closes too soon and the
        Avahi service stays alive
        """
		#try to close current index tab and then, do that for every other tabs too
        self._deviceManager.stop()
        self.close()

    def dm(self):
		print "dm"

    def fs(self):
		print "fs"

    def isptr(self):
		print "inptr"
        
