import os
import time
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
from Editor.Editor import Editor
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
        font.setPointSize(9)

        # Create FileSystem
        self.ui.FileSystemDock.toggleViewAction().setText("&File System")
        self.ui.FileSystemDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.FileSystemDock.toggleViewAction())
        self.ui.FileSystemDock.toggleViewAction().triggered.connect(self.fileWindowClicked)
        self._fileSystem = FileSystem()
        self.ui.FileSystemLayout.addWidget(self._fileSystem)
        
        # Create Inspector
        self.ui.InspectorDock.toggleViewAction().setText("&Inspector")
        self.ui.InspectorDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.InspectorDock.toggleViewAction())
        self.ui.InspectorDock.toggleViewAction().triggered.connect(self.inspectorWindowClicked)
        self._inspector = TrickplayInspector()
        self.ui.InspectorLayout.addWidget(self._inspector)
        self.ui.InspectorDock.hide()
        
        # Create Console
        self.ui.ConsoleDock.toggleViewAction().setText("&Console")
        self.ui.ConsoleDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.ConsoleDock.toggleViewAction())
        self.ui.ConsoleDock.toggleViewAction().triggered.connect(self.consoleWindowClicked)
        self._console = TrickplayConsole()
        self.ui.ConsoleLayout.addWidget(self._console)
        self.ui.ConsoleDock.hide()
	
		# Set Interactive Line Edit 
        self.ui.interactive.setText("")
        self.connect(self.ui.interactive, SIGNAL("returnPressed()"), self.return_pressed)

		# Create Debug 
        self.ui.DebugDock.toggleViewAction().setText("&Debug")
        self.ui.DebugDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.DebugDock.toggleViewAction())
        self.ui.DebugDock.toggleViewAction().triggered.connect(self.debugWindowClicked)
        self._debug = TrickplayDebugger()
        self.ui.DebugLayout.addWidget(self._debug)
        self.ui.DebugDock.hide()

        # Create Editor
        self._editorManager = EditorManager(self._fileSystem, self._debug, self.ui.centralwidget)
        
		#Create Backtrace
        self.ui.BacktraceDock.toggleViewAction().setText("&Backtrace")
        self.ui.BacktraceDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.BacktraceDock.toggleViewAction())
        self.ui.BacktraceDock.toggleViewAction().triggered.connect(self.traceWindowClicked)
        self._backtrace = TrickplayBacktrace()
        self.ui.BacktraceLayout.addWidget(self._backtrace)
        self.ui.BacktraceDock.hide()

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

		#Icon 
        icon_continue = QtGui.QIcon()
        icon_continue.addPixmap(QtGui.QPixmap("Assets/icon-continue.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_debug = QtGui.QIcon()
        icon_debug.addPixmap(QtGui.QPixmap("Assets/icon-debug.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_pause = QtGui.QIcon()
        icon_pause.addPixmap(QtGui.QPixmap("Assets/icon-pause.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_run = QtGui.QIcon()
        icon_run.addPixmap(QtGui.QPixmap("Assets/icon-run.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stepinto = QtGui.QIcon()
        icon_stepinto.addPixmap(QtGui.QPixmap("Assets/icon-stepinto.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stepout = QtGui.QIcon()
        icon_stepout.addPixmap(QtGui.QPixmap("Assets/icon-stepout.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stepover = QtGui.QIcon()
        icon_stepover.addPixmap(QtGui.QPixmap("Assets/icon-stepover.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stop = QtGui.QIcon()
        icon_stop.addPixmap(QtGui.QPixmap("Assets/icon-stop.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.icon_file_on = QtGui.QIcon()
    	self.icon_file_on.addPixmap(QtGui.QPixmap("Assets/panel-files-on.png"), QtGui.QIcon.Normal)
        self.icon_file_off = QtGui.QIcon()
    	self.icon_file_off.addPixmap(QtGui.QPixmap("Assets/panel-files-off.png"), QtGui.QIcon.Normal)
        self.icon_inspector_on = QtGui.QIcon()
    	self.icon_inspector_on.addPixmap(QtGui.QPixmap("Assets/panel-inspector-on.png"), QtGui.QIcon.Normal)
        self.icon_inspector_off = QtGui.QIcon()
    	self.icon_inspector_off.addPixmap(QtGui.QPixmap("Assets/panel-inspector-off.png"), QtGui.QIcon.Normal)
        self.icon_console_on = QtGui.QIcon()
    	self.icon_console_on.addPixmap(QtGui.QPixmap("Assets/panel-console-on.png"), QtGui.QIcon.Normal)
        self.icon_console_off = QtGui.QIcon()
    	self.icon_console_off.addPixmap(QtGui.QPixmap("Assets/panel-console-off.png"), QtGui.QIcon.Normal)
        self.icon_debug_on = QtGui.QIcon()
    	self.icon_debug_on.addPixmap(QtGui.QPixmap("Assets/panel-debug-on.png"), QtGui.QIcon.Normal)
        self.icon_debug_off = QtGui.QIcon()
    	self.icon_debug_off.addPixmap(QtGui.QPixmap("Assets/panel-debug-off.png"), QtGui.QIcon.Normal)
        self.icon_trace_on = QtGui.QIcon()
    	self.icon_trace_on.addPixmap(QtGui.QPixmap("Assets/panel-refresh-on.png"), QtGui.QIcon.Normal)
        self.icon_trace_off = QtGui.QIcon()
    	self.icon_trace_off.addPixmap(QtGui.QPixmap("Assets/panel-refresh-off.png"), QtGui.QIcon.Normal)

		# Create ToolBar 
        self.toolbar = DockAwareToolBar() 
        self.toolbar.setObjectName("debug_toolbar")
        self.addToolBar(QtCore.Qt.TopToolBarArea, self.toolbar)

        """
        self.debugComboBox = QtGui.QComboBox()
        self.debugComboBox.setEditable(False)
        self.debugComboBox.setDuplicatesEnabled(False)
        self.debugComboBox.setFrame(False)
        #self.debugComboBox.setObjectName(_fromUtf8("debugComboBox"))
        self.toolbar.addWidget(self.debugComboBox)

        self.debugComboBox.addItem(icon, "Debug")
        self.debugComboBox.addItem(icon2, "Run")

        QObject.connect(self.debugComboBox, SIGNAL('currentIndexChanged(int)'), self.debug_selected)
        QObject.connect(self.debugComboBox, SIGNAL("clicked()"),  self.debug_clicked)

		"""

		# Create Debug/Run tool button 
        debug_tbt = QToolButton()
        debug_tbt.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt.setFont(font)
        debug_tbt.setText("Debug")
        debug_tbt.setIcon(icon_debug)

        self.toolbar.addWidget(debug_tbt)

        QObject.connect(debug_tbt , SIGNAL("clicked()"),  self.debug)

        debug_tbt2 = QToolButton()
        debug_tbt2.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt2.setText("Run")
        debug_tbt2.setFont(font)
        debug_tbt2.setIcon(icon_run)

        self.toolbar.addWidget(debug_tbt2)

        QObject.connect(debug_tbt2 , SIGNAL("clicked()"),  self.run)
        
        debug_tbt5 = QToolButton()
        debug_tbt5.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt5.setText("Stop")
        debug_tbt5.setFont(font)
        debug_tbt5.setIcon(icon_stop)
        self.toolbar.addWidget(debug_tbt5)
        QObject.connect(debug_tbt5 , SIGNAL("clicked()"),  self.stop)

		#Create Target Trickplay Devices Button
        self._deviceManager = TrickplayDeviceManager(self._inspector)
        font_deviceManager = QFont()
        font_deviceManager.setPointSize(9)
        self._deviceManager.ui.comboBox.setFont(font_deviceManager)
        self.toolbar.addWidget(self._deviceManager.ui.comboBox)
        
        """
        self._menu_button = QtGui.QToolButton()
        self._menu_button.setPopupMode(QtGui.QToolButton.MenuButtonPopup)
        self._menu_button.setText("TrickPlay Devices    ")

        self._mini_menu = QtGui.QMenu()
        self._mini_menu.addAction(self.ui.action_New)
        self._mini_menu.addAction(self.ui.action_Save)
        #self._mini_menu.addAction(icon2, "Device1")
        #self._mini_menu.addSeperator()
        #self._mini_menu.addAction(icon, "Device2")

        self._menu_button.setMenu(self._mini_menu)        
        self._menu_button.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.toolbar.addWidget(self._menu_button)
		"""

        debug_tbt3 = QToolButton()
        debug_tbt3.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt3.setText("Step Into")
        debug_tbt3.setFont(font)
        self.toolbar.addWidget(debug_tbt3)
        QObject.connect(debug_tbt3 , SIGNAL("clicked()"),  self.debug_step_into)
        debug_tbt3.setIcon(icon_stepinto)

        debug_tbt4 = QToolButton()
        debug_tbt4.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt4.setText("Step Over")
        debug_tbt4.setFont(font)
        debug_tbt4.setIcon(icon_stepover)
        self.toolbar.addWidget(debug_tbt4)
        QObject.connect(debug_tbt4 , SIGNAL("clicked()"),  self.debug_step_over)

        debug_tbt7 = QToolButton()
        debug_tbt7.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt7.setText("Step Out")
        debug_tbt7.setFont(font)
        debug_tbt7.setIcon(icon_stepout)
        self.toolbar.addWidget(debug_tbt7)
        QObject.connect(debug_tbt7 , SIGNAL("clicked()"),  self.debug_step_out)

		 
        debug_pause = QToolButton()
        debug_pause.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_pause.setText("Pause")
        debug_pause.setFont(font)
        debug_pause.setIcon(icon_pause)
        self.toolbar.addWidget(debug_pause)
        QObject.connect(debug_pause , SIGNAL("clicked()"),  self.debug_pause)
 
        debug_tbt6 = QToolButton()
        debug_tbt6.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        debug_tbt6.setText("Continue")
        debug_tbt6.setFont(font)
        debug_tbt6.setIcon(icon_continue)
        self.toolbar.addWidget(debug_tbt6)
        QObject.connect(debug_tbt6 , SIGNAL("clicked()"),  self.debug_continue)

        self.current_debug_file = None

        right_spacer = QWidget()
        right_spacer.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.toolbar.addWidget(right_spacer)
        self.windows = {"file":True, "inspector":False, "console":False, "debug":False, "trace":False}

        self.file_toolBtn = QPushButton()
        self.file_toolBtn.setFixedWidth(30)
        self.file_toolBtn.setIcon(self.icon_file_on)
        self.toolbar.addWidget(self.file_toolBtn)
        QObject.connect(self.file_toolBtn , SIGNAL("clicked()"),  self.fileWindowClicked)

        self.inspector_toolBtn = QPushButton()
        self.inspector_toolBtn.setFixedWidth(30)
        self.inspector_toolBtn.setIcon(self.icon_inspector_off)
        self.toolbar.addWidget(self.inspector_toolBtn)
        QObject.connect(self.inspector_toolBtn , SIGNAL("clicked()"),  self.inspectorWindowClicked)
	
        self.console_toolBtn = QPushButton()
        self.console_toolBtn.setFixedWidth(30)
        self.console_toolBtn.setIcon(self.icon_console_off)
        self.toolbar.addWidget(self.console_toolBtn)
        QObject.connect(self.console_toolBtn , SIGNAL("clicked()"),  self.consoleWindowClicked)

        self.debug_toolBtn = QPushButton()
        self.debug_toolBtn.setFixedWidth(30)
        self.debug_toolBtn.setIcon(self.icon_debug_off)
        self.toolbar.addWidget(self.debug_toolBtn)
        QObject.connect(self.debug_toolBtn , SIGNAL("clicked()"),  self.debugWindowClicked)

        self.trace_toolBtn = QPushButton()
        self.trace_toolBtn.setFixedWidth(30)
        self.trace_toolBtn.setIcon(self.icon_trace_off)
        self.toolbar.addWidget(self.trace_toolBtn)
        QObject.connect(self.trace_toolBtn , SIGNAL("clicked()"),  self.traceWindowClicked)

        #toolBtn.setEnabled(False)
        #toolBtn.setIcon(icon_console_on)
    def traceWindowClicked(self) :
    	if self.windows['trace'] == True:
    		self.trace_toolBtn.setIcon(self.icon_trace_off)
    		self.ui.BacktraceDock.hide()
    		self.windows['trace'] = False
    	else :
    		self.trace_toolBtn.setIcon(self.icon_trace_on)
    		self.ui.BacktraceDock.show()
    		self.windows['trace'] = True

    def fileWindowClicked(self) :
    	if self.windows['file'] == True:
			self.file_toolBtn.setIcon(self.icon_file_off)
			self.ui.FileSystemDock.hide()
			self.windows['file'] = False
    	else :
    		self.file_toolBtn.setIcon(self.icon_file_on)
    		self.ui.FileSystemDock.show()
    		self.windows['file'] = True

    def inspectorWindowClicked(self) :
    	if self.windows['inspector'] == True:
    		self.inspector_toolBtn.setIcon(self.icon_inspector_off)
    		self.ui.InspectorDock.hide()
    		self.windows['inspector'] = False
    	else :
    		self.inspector_toolBtn.setIcon(self.icon_inspector_on)
    		self.ui.InspectorDock.show()
    		self.windows['inspector'] = True

    def debugWindowClicked(self) :
    	if self.windows['debug'] == True:
    		self.debug_toolBtn.setIcon(self.icon_debug_off)
    		self.ui.DebugDock.hide()
    		self.windows['debug'] = False
    	else :
    		self.debug_toolBtn.setIcon(self.icon_debug_on)
    		self.ui.DebugDock.show()
    		self.windows['debug'] = True

    def consoleWindowClicked(self) :
    	if self.windows['console'] == True:
    		self.console_toolBtn.setIcon(self.icon_console_off)
    		self.ui.ConsoleDock.hide()
    		self.windows['console'] = False
    	else :
    		self.console_toolBtn.setIcon(self.icon_console_on)
    		self.ui.ConsoleDock.show()
    		self.windows['console'] = True

		
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

    def debug_clicked(self):
		print ("DEBUG_clicked!!!!!!!!!!!!!")
		if index == None :
			index = self.debugComboBox.currentIndex()
		print(index)
		if index < 0:
			return
		elif index == 0:
			self.debug()
		else:
			self.run()

    def debug_selected(self, index):
		print ("DEBUG_SELECTED!!!!!!!!!!!!!")
		print(index)
		if index < 0:
			return
		elif index == 0:
			self.debug()
		else:
			self.run()

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
		
    def stop(self):
    	if self._deviceManager.trickplay.state() == QProcess.Running:
        	# self._deviceManager.trickplay.kill() #close, terminate 
			if getattr(self._deviceManager, "debug_mode") == True :
				print('Debug stop------------------')
				data = sendTrickplayDebugCommand(str(self._deviceManager.debug_port), "q", True)
				# delete current line marker
				for n in self.editorManager.editors:
					if self.current_debug_file == n:
						self.editorManager.tab.editors[self.editorManager.editors[n][1]].markerDelete(
						self.editorManager.tab.editors[self.editorManager.editors[n][1]].current_line, Editor.ARROW_MARKER_NUM)
						self.editorManager.tab.editors[self.editorManager.editors[n][1]].current_line = -1
				# clean backtrace and debug window
				self._backtrace.ui.listWidget.clear()
				self._debug.clearLocalTable(0)
				self._debug.clearBreakTable(0)
			else :
				print('Run stop------------------')
				ret = self.deviceManager.socket.write('/quit\n\n')
				if ret < 0 :
					print ("tp console socket is not available !")

        #self.ui.InspectorDock.hide()
        #self.ui.ConsoleDock.hide()
        #self.ui.DebugDock.hide()
        #self.ui.BacktraceDock.hide()

        self.windows = {"file":False, "inspector":True, "console":True, "debug":True, "trace":True}
        self.inspectorWindowClicked()
        self.consoleWindowClicked()
        self.debugWindowClicked()
        self.traceWindowClicked()

        self.inspector.clearTree()
        #self._deviceManager.ui.comboBox.removeItem(self._deviceManager.ui.comboBox.findText(self._deviceManager.newAppText))
        self._deviceManager.ui.comboBox.setCurrentIndex(0)
        self._deviceManager.service_selected(0)

    def run(self):
        self.inspector.clearTree()
        self._deviceManager.run(False)
        self.windows = {"file":False, "inspector":False, "console":False, "debug":True, "trace":True}
        self.inspectorWindowClicked()
        self.consoleWindowClicked()
        self.debugWindowClicked()
        self.traceWindowClicked()

        #self.ui.InspectorDock.show()
        #self.ui.ConsoleDock.show()
        #self.ui.DebugDock.hide()
        #self.ui.BacktraceDock.hide()

    def debug(self):
        self.inspector.clearTree()
        self._deviceManager.run(True)

        self.windows = {"file":False, "inspector":False, "console":False, "debug":False, "trace":False}
        self.inspectorWindowClicked()
        self.consoleWindowClicked()
        self.debugWindowClicked()
        self.traceWindowClicked()
        #self.ui.InspectorDock.show()
        #self.ui.ConsoleDock.show()
        #self.ui.DebugDock.show()
        #self.ui.BacktraceDock.show()
        time.sleep(2)
        data = sendTrickplayDebugCommand(str(self._deviceManager.debug_port), "bn", True)
        print ("-----------")
        self._deviceManager.printResp(data, "cn")
        print ("-----------")

		# Open File, Show Current Lines 
        if self._deviceManager.file_name[:1] != '/' :
			self.current_debug_file = self.path+'/'+self._deviceManager.file_name
        else :
			self.current_debug_file = self.path+self._deviceManager.file_name

        self._editorManager.newEditor(self.current_debug_file, None, self._deviceManager.line_no, None, True)
	
	
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

    def debug_command(self, cmd):
		if getattr(self._deviceManager, "debug_mode") == True :
			data = sendTrickplayDebugCommand(str(self._deviceManager.debug_port), cmd, False)
			print ("-----------")
			self._deviceManager.printResp(data, cmd)
			print ("-----------")
			# Open File, Show Current Lines 
			if cmd == "c":
				# delete current line marker 
				for m in self.editorManager.editors:
					if self.current_debug_file == m:
						self.editorManager.tab.editors[self.editorManager.editors[m][1]].markerDelete(
						self.editorManager.tab.editors[self.editorManager.editors[m][1]].current_line, Editor.ARROW_MARKER_NUM)
						self.editorManager.tab.editors[self.editorManager.editors[m][1]].current_line = -1
				# clean backtrace and debug windows
				self._backtrace.ui.listWidget.clear()
				self._debug.clearLocalTable(0)
				self._debug.clearBreakTable(0)

			else :
				file_name = ""
				# update local variables table
				data = sendTrickplayDebugCommand(str(self._deviceManager.debug_port), "l", False)
				local_info = self._deviceManager.printResp(data, "l")
				self._debug.populateLocalTable(local_info)

				# update backtrace table
				data = sendTrickplayDebugCommand(str(self._deviceManager.debug_port), "bt", False)
				stack_info = self._deviceManager.printResp(data, "bt")
				self._backtrace.populateList(stack_info)

				# print breakpoints info 
				#data = sendTrickplayDebugCommand(str(self._deviceManager.debug_port), "b", False)
				#self._deviceManager.printResp(data, "b")

				# open current file and put line marker on the current line's margin 
				if self._deviceManager.file_name[:1] != '/' :
					file_name = self.path+'/'+self._deviceManager.file_name
				else :
					file_name = self.path+self._deviceManager.file_name

				if self.current_debug_file != file_name :
					self.editorManager.newEditor(file_name, None, self._deviceManager.line_no, self.current_debug_file, True)
				else :
					self.editorManager.newEditor(file_name, None, self._deviceManager.line_no, None, True)

				self.current_debug_file = file_name

		else :
			pass
			#print('oh no ! not in debug mode -----')

		return None

    def debug_continue(self):
		self.debug_command("c")

    def debug_pause(self):
		self.debug_command("bn")

    def debug_step_into(self):
		self.debug_command("s")

    def debug_step_over(self):
		self.debug_command("n")

    def debug_step_out(self):
		pass
