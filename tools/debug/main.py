import os
import base64
import re
import sys
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.MainWindow import Ui_MainWindow

from connection import *
from wizard import Wizard
from tbar import * 

from Inspector.TrickplayInspector import TrickplayInspector
from DeviceManager.TrickplayDeviceManager import TrickplayDeviceManager
from Editor.EditorManager import EditorManager
from FileSystem.FileSystem import FileSystem
from Debug.TrickplayDebug import *
from Console.TrickplayConsole import TrickplayConsole

signal.signal(signal.SIGINT, signal.SIG_DFL)

class MainWindow(QMainWindow):
    
    def __init__(self, app, parent = None):
        
        QWidget.__init__(self, parent)
        
        # Restore size/position of window
        settings = QSettings()
        #self.restoreGeometry(settings.value("mainWindowGeometry").toByteArray());
        
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
		# Toolbar font 
        font = QFont()
        font.setPointSize(10)

        # Create FileSystem
        self.ui.FileSystemDock.toggleViewAction().setText("&File System")
        self.ui.FileSystemDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.FileSystemDock.toggleViewAction())
        #self.ui.FileSystemDock.toggleViewAction().triggered.connect(self.fs)
        self._fileSystem = FileSystem()
        self.ui.FileSystemLayout.addWidget(self._fileSystem)
        
        # Create Editor
        self._editorManager = EditorManager(self._fileSystem, self.ui.centralwidget)
        
        # Create Inspector
        self.ui.InspectorDock.toggleViewAction().setText("&Inspector")
        self.ui.InspectorDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.InspectorDock.toggleViewAction())
        #self.ui.InspectorDock.toggleViewAction().triggered.connect(self.isptr)
        self._inspector = TrickplayInspector()
        self.ui.InspectorLayout.addWidget(self._inspector)
        self.ui.InspectorDock.hide()
        
        # Create Console
        self.ui.ConsoleDock.toggleViewAction().setText("&Console")
        self.ui.ConsoleDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.ConsoleDock.toggleViewAction())
        self._console = TrickplayConsole()
        self.ui.ConsoleLayout.addWidget(self._console)
        self.ui.ConsoleDock.hide()
	
		# Set Interactive Line Edit 
        self.ui.interactive.setText("")
        #self.connect(self.ui.interactive, SIGNAL("textChanged(QString)"), self.text_changed)
        self.connect(self.ui.interactive, SIGNAL("returnPressed()"), self.return_pressed)

		#File Menu
        QObject.connect(self.ui.actionNew_File, SIGNAL("triggered()"),  self.newFile)
        QObject.connect(self.ui.actionNew_Folder, SIGNAL("triggered()"),  self.newFolder)
        QObject.connect(self.ui.action_New, SIGNAL("triggered()"),  self.new)
        QObject.connect(self.ui.actionOpen_App, SIGNAL("triggered()"),  self.new)
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
        QObject.connect(self.ui.actionSearch, SIGNAL("triggered()"),  self.editor_search)
        QObject.connect(self.ui.actionSearch_Replace, SIGNAL("triggered()"),  self.editor_search_replace)
        QObject.connect(self.ui.actionGo_to_line, SIGNAL("triggered()"),  self.editor_go_to_line)

		#Debug Menu
        QObject.connect(self.ui.actionContinue, SIGNAL("triggered()"),  self.debug_continue)
        QObject.connect(self.ui.actionPause, SIGNAL("triggered()"),  self.debug_pause)
        QObject.connect(self.ui.actionStep_into, SIGNAL("triggered()"),  self.debug_step_into)
        QObject.connect(self.ui.actionStep_over, SIGNAL("triggered()"),  self.debug_step_over)
        QObject.connect(self.ui.actionStep_out, SIGNAL("triggered()"),  self.debug_step_out)
		
        # Restore sizes/positions of docks
        #self.restoreState(settings.value("mainWindowState").toByteArray());
        self.path = None
        QObject.connect(app, SIGNAL('aboutToQuit()'), self.cleanUp)
        self.app = app

		# Create ToolBar 
        self.toolbar = DockAwareToolBar() 
        self.toolbar.setObjectName("debug_toolbar")
        self.addToolBar(QtCore.Qt.TopToolBarArea, self.toolbar)
        #self.toolbar.toggleViewAction().setText("&ToolBar")
        #self.ui.menuView.addAction(self.toolbar.toggleViewAction())

		# Create Debug 
        self.ui.DebugDock.toggleViewAction().setText("&Debug")
        self.ui.DebugDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.DebugDock.toggleViewAction())
        self._deviceManager = TrickplayDeviceManager(self._inspector)

		
        self._deviceManager.ui.comboBox.setFont(font)
        self.toolbar.addWidget(self._deviceManager.ui.comboBox)
		
        self._debug = TrickplayDebugger()
        self.ui.DebugLayout.addWidget(self._debug)
        self.ui.DebugDock.hide()

		#Create Backtrace
        self.ui.BacktraceDock.toggleViewAction().setText("&Backtrace")
        self.ui.BacktraceDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.BacktraceDock.toggleViewAction())
        self._backtrace = TrickplayBacktrace()
        self.ui.BacktraceLayout.addWidget(self._backtrace)
        self.ui.BacktraceDock.hide()
        #self.ui.DebugDock_2.hide()

		#Create Trickplay Devices Button
        """
        self._menu_button = QtGui.QToolButton()
        self._menu_button.setPopupMode(QtGui.QToolButton.InstantPopup)
        self._menu_button.setText("TrickPlay Devices    ")

        self._mini_menu = QtGui.QMenu()
        self._mini_menu.addAction(self.ui.action_New)
        self._mini_menu.addAction(self.ui.action_Save)

        self._menu_button.setMenu(self._mini_menu)        
        self._menu_button.setToolButtonStyle(QtCore.Qt.ToolButtonFollowStyle)
        self.toolbar.addWidget(self._menu_button)
		"""

        self.debug_tbt = QToolButton()
        self.debug_tbt.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        self.debug_tbt.setFont(font)
        self.debug_tbt.setText("Debug")

        #icon = QtGui.QIcon()
        #icon.addPixmap(QtGui.QPixmap("img_samples/voice-1.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        #self.debug_tbt.setIcon(icon)
        self.toolbar.addWidget(self.debug_tbt)

        QObject.connect(self.debug_tbt , SIGNAL("clicked()"),  self.debug)

        debug_tbt2 = QToolButton()
        debug_tbt2.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt2.setText("Run")
        debug_tbt2.setFont(font)

        #icon2 = QtGui.QIcon()
        #icon2.addPixmap(QtGui.QPixmap("img_samples/rightfocus.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        #debug_tbt2.setIcon(icon2)
        self.toolbar.addWidget(debug_tbt2)

        QObject.connect(debug_tbt2 , SIGNAL("clicked()"),  self.run)
        
        debug_tbt5 = QToolButton()
        debug_tbt5.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt5.setText("Stop")
        debug_tbt5.setFont(font)

        #icon5 = QtGui.QIcon()
        #icon5.addPixmap(QtGui.QPixmap("img_samples/voice-3.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        #debug_tbt5.setIcon(icon5)
        self.toolbar.addWidget(debug_tbt5)

        debug_tbt6 = QToolButton()
        debug_tbt6.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt6.setText("Resume")
        debug_tbt6.setFont(font)

        self.toolbar.addWidget(debug_tbt6)
 
        debug_tbt3 = QToolButton()
        debug_tbt3.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt3.setText("Step Into")
        debug_tbt3.setFont(font)
        #icon3 = QtGui.QIcon()
        #icon3.addPixmap(QtGui.QPixmap("img_samples/voice-3.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        #debug_tbt3.setIcon(icon3)
        self.toolbar.addWidget(debug_tbt3)

        debug_tbt4 = QToolButton()
        debug_tbt4.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt4.setText("Step Over")
        debug_tbt4.setFont(font)
        #icon4 = QtGui.QIcon()
        #icon4.addPixmap(QtGui.QPixmap("img_samples/voice-2.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        #debug_tbt4.setIcon(icon4)
        self.toolbar.addWidget(debug_tbt4)

        debug_tbt7 = QToolButton()
        debug_tbt7.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt7.setText("Step Out")
        debug_tbt7.setFont(font)
        self.toolbar.addWidget(debug_tbt7)

		
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

    def return_pressed(self):
		self.request = str(self.ui.interactive.text())
		print self.request
		try:
			ret = self.deviceManager.socket.write(self.request+'\n\n')
			if ret < 0 :
				print "tp console socket is not available"
			else :
				print ret
		except AttributeError, e:
    		# deal with AttributeError
			print "tp console socket is not opened"
		self.ui.interactive.setText("")
		self.request = ""
		
    def run(self):
        print("run !!!")
        self._deviceManager.run()

    def debug(self):
        print("debug !!!")
        self.debug_port = str(getTrickplayDebug()['port'])
        data = sendTrickplayDebugCommand(self.debug_port, "bn", True)
        #self.printResp(data, "cn")

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
		wizard = Wizard()
		path = wizard.start("")
		if path:
			settings = QSettings()
			settings.setValue('path', path)
			self.start(path, wizard.filesToOpen())

    def exit(self):
        """
        Close in a clean way... but still Trickplay closes too soon and the
        Avahi service stays alive
        """
		#try to close current index tab and then, do that for every other tabs too
    	if self.editorManager.tab != None:
    		while self.editorManager.tab.count() != 0:
				self.editorManager.close()

        self._deviceManager.stop()
        self.close()

    def newFile(self):
		pass
    def newFolder(self):
		pass
    def editor_search(self):
		pass
    def editor_search_replace(self):
		pass
    def editor_go_to_line(self):
		pass
    def debug_continue(self):
		pass
    def debug_pause(self):
		pass
    def debug_step_into(self):
		pass
    def debug_step_over(self):
		pass
    def debug_step_out(self):
		pass
