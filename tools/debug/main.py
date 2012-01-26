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
        self.connect(self.ui.interactive, SIGNAL("returnPressed()"), self.return_pressed)

		# Create Debug 
        self.ui.DebugDock.toggleViewAction().setText("&Debug")
        self.ui.DebugDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.DebugDock.toggleViewAction())
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

		#ICON 

        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap("img_samples/voice-1.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)

        icon2 = QtGui.QIcon()
        icon2.addPixmap(QtGui.QPixmap("img_samples/rightfocus.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)

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
        debug_tbt.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt.setFont(font)
        debug_tbt.setText("Debug")
        #debug_tbt.setIcon(icon)

        self.toolbar.addWidget(debug_tbt)

        QObject.connect(debug_tbt , SIGNAL("clicked()"),  self.debug)

        debug_tbt2 = QToolButton()
        debug_tbt2.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt2.setText("Run")
        debug_tbt2.setFont(font)
        #debug_tbt2.setIcon(icon2)

        self.toolbar.addWidget(debug_tbt2)

        QObject.connect(debug_tbt2 , SIGNAL("clicked()"),  self.run)
        
        debug_tbt5 = QToolButton()
        debug_tbt5.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt5.setText("Stop")
        debug_tbt5.setFont(font)
        self.toolbar.addWidget(debug_tbt5)
        QObject.connect(debug_tbt5 , SIGNAL("clicked()"),  self.stop)

		#Create Target Trickplay Devices Button
        self._deviceManager = TrickplayDeviceManager(self._inspector)
        self._deviceManager.ui.comboBox.setFont(font)
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
        self._menu_button.setToolButtonStyle(QtCore.Qt.ToolButtonFollowStyle)
        self.toolbar.addWidget(self._menu_button)
		"""

        debug_tbt3 = QToolButton()
        debug_tbt3.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt3.setText("Step Into")
        debug_tbt3.setFont(font)
        self.toolbar.addWidget(debug_tbt3)
        QObject.connect(debug_tbt3 , SIGNAL("clicked()"),  self.debug_step_into)

        debug_tbt4 = QToolButton()
        debug_tbt4.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt4.setText("Step Over")
        debug_tbt4.setFont(font)
        self.toolbar.addWidget(debug_tbt4)
        QObject.connect(debug_tbt4 , SIGNAL("clicked()"),  self.debug_step_over)

        debug_tbt7 = QToolButton()
        debug_tbt7.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt7.setText("Step Out")
        debug_tbt7.setFont(font)
        self.toolbar.addWidget(debug_tbt7)
        QObject.connect(debug_tbt7 , SIGNAL("clicked()"),  self.debug_step_out)

		 
        debug_pause = QToolButton()
        debug_pause.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_pause.setText("Pause")
        debug_pause.setFont(font)
        self.toolbar.addWidget(debug_pause)
        QObject.connect(debug_pause , SIGNAL("clicked()"),  self.debug_pause)
 
        debug_tbt6 = QToolButton()
        debug_tbt6.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        debug_tbt6.setText("Continue")
        debug_tbt6.setFont(font)
        self.toolbar.addWidget(debug_tbt6)
        QObject.connect(debug_tbt6 , SIGNAL("clicked()"),  self.debug_continue)

        self.current_debug_file = None

		
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
			else :
				print('Run stop------------------')
				ret = self.deviceManager.socket.write('/quit\n\n')
				if ret < 0 :
					print ("tp console socket is not available !")


        self.ui.InspectorDock.hide()
        self.ui.ConsoleDock.hide()
        self.ui.DebugDock.hide()
        self.ui.BacktraceDock.hide()
        self.inspector.clearTree()
        #self._deviceManager.ui.comboBox.removeItem(self._deviceManager.ui.comboBox.findText(self._deviceManager.newAppText))
        self._deviceManager.ui.comboBox.setCurrentIndex(0)
        self._deviceManager.service_selected(0)

    def run(self):
        self.inspector.clearTree()
        self._deviceManager.run(False)
        self.ui.InspectorDock.show()
        self.ui.ConsoleDock.show()
        self.ui.DebugDock.hide()
        self.ui.BacktraceDock.hide()

    def debug(self):
        self.inspector.clearTree()
        self._deviceManager.run(True)
        self.ui.InspectorDock.show()
        self.ui.ConsoleDock.show()
        self.ui.DebugDock.show()
        self.ui.BacktraceDock.show()
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

        self._editorManager.newEditor(self.current_debug_file, None, self._deviceManager.line_no)
	
	
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
			else :
				file_name = ""

				if self._deviceManager.file_name[:1] != '/' :
					file_name = self.path+'/'+self._deviceManager.file_name
				else :
					file_name = self.path+self._deviceManager.file_name

				if self.current_debug_file != file_name :
					self.editorManager.newEditor(file_name, None, self._deviceManager.line_no, self.current_debug_file)
				else :
					self.editorManager.newEditor(file_name, None, self._deviceManager.line_no)
				self.current_debug_file = file_name
		else :
			print('oh no ! not in debug mode -----')

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
