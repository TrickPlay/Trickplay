import os
import time
import base64
import re
import sys
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.Qsci import QsciScintilla, QsciLexerLua

from UI.MainWindow import Ui_MainWindow

from connection import *
from wizard import Wizard
from tbar import * 
from preference import Preference

from Inspector.TrickplayInspector import TrickplayInspector
from DeviceManager.TrickplayDeviceManager import TrickplayDeviceManager
from Editor.EditorManager import EditorManager
from Editor.Editor import Editor
from FileSystem.FileSystem import FileSystem
from Debug.TrickplayDebug import *
from Console.TrickplayConsole import TrickplayConsole
from UI.Search import Ui_searchDialog
from UI.Replace import Ui_replaceDialog
from UI.GotoLine import Ui_gotoLineDialog

signal.signal(signal.SIGINT, signal.SIG_DFL)

EDITOR_MODE = 1
RUN_STOP = 2
DEBUG_INBREAK = 3
DEBUG_NOT_INBREAK = 4

TEXT_DEFAULT = 0
TEXT_READ = 1
TEXT_CHANGED = 2

class MainWindow(QMainWindow):
    
    def __init__(self, app, apath=None, parent = None):
        
        QWidget.__init__(self, parent)
        
        
        self.closedByIDE = False
        self.untitled_idx = 1
        self.debug_mode = False
        self.apath = apath

        # Restore size/position of window
        settings = QSettings()
        self.restoreGeometry(settings.value("mainWindowGeometry").toByteArray())
        
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
       
        self.editorMenuEnabled(False)
        self.debuggerMenuEnabled(False)

		#Create Preference 
        self._preference = Preference(self)

		# Toolbar font 
        font = QFont()   
        font.setPointSize(11)

        # Create FileSystem
        self.ui.FileSystemDock.toggleViewAction().setText("File system")
        #self.ui.FileSystemDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.FileSystemDock.toggleViewAction())
        self.ui.FileSystemDock.toggleViewAction().triggered.connect(self.fileWindowClicked)
        self._fileSystem = FileSystem(self._preference)
        self.ui.FileSystemLayout.addWidget(self._fileSystem)
        
        # Create Inspector
        self.ui.InspectorDock.toggleViewAction().setText("Inspector")
        #self.ui.InspectorDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.InspectorDock.toggleViewAction())
        self.ui.InspectorDock.toggleViewAction().triggered.connect(self.inspectorWindowClicked)
        self._inspector = TrickplayInspector()
        self.ui.InspectorLayout.addWidget(self._inspector)
        self.ui.InspectorDock.hide()
        
        # Create Console
        self.ui.ConsoleDock.toggleViewAction().setText("Console")
        #self.ui.ConsoleDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.ConsoleDock.toggleViewAction())
        self.ui.ConsoleDock.toggleViewAction().triggered.connect(self.consoleWindowClicked)
        self.console = TrickplayConsole()
        self.console.ui.textEdit.setFont(self.preference.consoleFont)

        self.ui.ConsoleLayout.addWidget(self.console)
        self.ui.ConsoleDock.hide()
        
		# Set Interactive Line Edit 
        self.ui.interactive.setText("")
        self.ui.interactive.setFont(self.preference.consoleFont)
        self.connect(self.ui.interactive, SIGNAL("returnPressed()"), self.return_pressed)

		# Create Debug 
        self.ui.DebugDock.toggleViewAction().setText("Debug")
        #self.ui.DebugDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.DebugDock.toggleViewAction())
        self.ui.DebugDock.toggleViewAction().triggered.connect(self.debugWindowClicked)
        self._debug = TrickplayDebugger(self)
        self.ui.DebugLayout.addWidget(self._debug)
        self.ui.DebugDock.hide()

        # Create Editor
        self._editorManager = EditorManager(self, self.ui.menuView, self.ui.centralwidget)
        
		#Create Backtrace
        self.ui.BacktraceDock.toggleViewAction().setText("Backtrace")
        #self.ui.BacktraceDock.toggleViewAction().setFont(font)
        self.ui.menuView.addAction(self.ui.BacktraceDock.toggleViewAction())
        self.ui.BacktraceDock.toggleViewAction().triggered.connect(self.traceWindowClicked)
        self.backtrace = TrickplayBacktrace()
        self.backtrace.font = self.preference.btFont
        self.ui.BacktraceLayout.addWidget(self.backtrace)
        self.ui.BacktraceDock.hide()

		#File Menu    
        QObject.connect(self.ui.actionNew_File, SIGNAL("triggered()"),  self.newFile)
        QObject.connect(self.ui.action_New, SIGNAL("triggered()"),  self.new)
        QObject.connect(self.ui.actionOpen_App, SIGNAL("triggered()"),  self.openApp)
        QObject.connect(self.ui.action_Save, SIGNAL('triggered()'),  self.editorManager.save)
        QObject.connect(self.ui.action_Save_As, SIGNAL('triggered()'),  self.editorManager.saveas)
        QObject.connect(self.ui.actionSave_All, SIGNAL('triggered()'),  self.editorManager.saveall)
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
        QObject.connect(self.ui.actionPreference, SIGNAL("triggered()"),  self.preferenceStart)

		#Debug Menu
        QObject.connect(self.ui.action_Run, SIGNAL("triggered()"),  self.run)
        QObject.connect(self.ui.action_Debug, SIGNAL("triggered()"),  self.debug)
        QObject.connect(self.ui.action_Stop, SIGNAL("triggered()"),  self.stop)
        QObject.connect(self.ui.actionContinue, SIGNAL("triggered()"),  self.debug_continue)
        QObject.connect(self.ui.actionPause, SIGNAL("triggered()"),  self.debug_pause)
        QObject.connect(self.ui.actionStep_into, SIGNAL("triggered()"),  self.debug_step_into)
        QObject.connect(self.ui.actionStep_over, SIGNAL("triggered()"),  self.debug_step_over)
        QObject.connect(self.ui.actionStep_out, SIGNAL("triggered()"),  self.debug_step_out)
		
        # Restore sizes/positions of docks
        #self.restoreState(settings.value("mainWindowState").toByteArray());
        self.path = None
        QObject.connect(app, SIGNAL('aboutToQuit()'), self.exit)
        self.app = app

		#Icon 
        icon_continue = QtGui.QIcon()
        icon_continue.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-continue.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_continue.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-continue-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        self.icon_debug = QtGui.QIcon()
        self.icon_debug.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-debug.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.icon_debug.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-debug-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        icon_pause = QtGui.QIcon()
        icon_pause.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-pause.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_pause.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-pause-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        self.icon_run = QtGui.QIcon()
        self.icon_run.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-run.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        self.icon_run.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-run-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        icon_stepinto = QtGui.QIcon()
        icon_stepinto.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stepinto.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stepinto.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stepinto-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        icon_stepout = QtGui.QIcon()
        icon_stepout.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stepout.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stepout.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stepout-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        icon_stepover = QtGui.QIcon()
        icon_stepover.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stepover.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stepover.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stepover-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        icon_stop = QtGui.QIcon()
        icon_stop.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stop.png"), QtGui.QIcon.Normal, QtGui.QIcon.Off)
        icon_stop.addPixmap(QtGui.QPixmap(apath+"/Assets/icon-stop-gray.png"), QtGui.QIcon.Disabled, QtGui.QIcon.Off)
        self.icon_file_on = QtGui.QIcon()
    	self.icon_file_on.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-files-on.png"), QtGui.QIcon.Normal)
        self.icon_file_off = QtGui.QIcon()
    	self.icon_file_off.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-files-off.png"), QtGui.QIcon.Normal)
        self.icon_inspector_on = QtGui.QIcon()
    	self.icon_inspector_on.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-inspector-on.png"), QtGui.QIcon.Normal)
        self.icon_inspector_off = QtGui.QIcon()
    	self.icon_inspector_off.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-inspector-off.png"), QtGui.QIcon.Normal)
        self.icon_console_on = QtGui.QIcon()
    	self.icon_console_on.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-console-on.png"), QtGui.QIcon.Normal)
        self.icon_console_off = QtGui.QIcon()
    	self.icon_console_off.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-console-off.png"), QtGui.QIcon.Normal)
        self.icon_debug_on = QtGui.QIcon()
    	self.icon_debug_on.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-debug-on.png"), QtGui.QIcon.Normal)
        self.icon_debug_off = QtGui.QIcon()
    	self.icon_debug_off.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-debug-off.png"), QtGui.QIcon.Normal)
        self.icon_trace_on = QtGui.QIcon()
    	self.icon_trace_on.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-refresh-on.png"), QtGui.QIcon.Normal)
        self.icon_trace_off = QtGui.QIcon()
    	self.icon_trace_off.addPixmap(QtGui.QPixmap(apath+"/Assets/panel-refresh-off.png"), QtGui.QIcon.Normal)

		# Create ToolBar 
        self.toolbar = DockAwareToolBar() 
        self.toolbar.setObjectName("debug_toolbar")
        self.addToolBar(QtCore.Qt.TopToolBarArea, self.toolbar)

		# Toolbar font 
        font = QFont()
        font.setPointSize(9)

		#Create Target Devices Drop Down Button
        self._deviceManager = TrickplayDeviceManager(self)
        font_deviceManager = QFont()
        font_deviceManager.setPointSize(9)
        self._deviceManager.ui.comboBox.setFont(font_deviceManager)
        self._deviceManager.ui.comboBox.setToolTip("Target Devices")
        self.toolbar.addWidget(self._deviceManager.ui.comboBox)
        

		# Create Debug/Run tool button 
        self.debug_tbt = QtGui.QToolButton()
        self.debug_tbt.setPopupMode(QtGui.QToolButton.MenuButtonPopup)
        self.debug_tbt.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_tbt.setFont(font)
        self.debug_tbt.setText("Run")
        self.debug_tbt.setIcon(self.icon_run)

        self.debug_menu = QtGui.QMenu()

        self.debug_action = QtGui.QAction(self.debug_menu)
        self.debug_action.setIcon(self.icon_debug)
        self.debug_action.setText("Debug")
        self.debug_action.setFont(font)
        self.debug_action.setIconVisibleInMenu (True)

        self.run_action = QtGui.QAction(self.debug_menu)
        self.run_action.setIcon(self.icon_run)
        self.run_action.setText("Run")
        self.run_action.setFont(font)
        self.run_action.setIconVisibleInMenu (True)
        
        QObject.connect(self.debug_action , SIGNAL("triggered()"),  self.debug)
        QObject.connect(self.run_action , SIGNAL("triggered()"),  self.run)

        self.debug_menu.addAction(self.debug_action)
        self.debug_tbt.setMenu(self.debug_menu)        
        self.toolbar.addWidget(self.debug_tbt)

        QObject.connect(self.debug_tbt , SIGNAL("clicked()"),  self.run)

        self.debug_stop = QToolButton()
        self.debug_stop.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_stop.setText("Stop")
        self.debug_stop.setFont(font)
        self.debug_stop.setIcon(icon_stop)
        self.debug_stop.setEnabled(False)
        self.toolbar.addWidget(self.debug_stop)
        QObject.connect(self.debug_stop , SIGNAL("clicked()"),  self.stop)

        self.debug_stepinto = QToolButton()
        self.debug_stepinto.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_stepinto.setText("Step Into")
        self.debug_stepinto.setFont(font)
        self.debug_stepinto.setEnabled(False)
        self.toolbar.addWidget(self.debug_stepinto)
        QObject.connect(self.debug_stepinto , SIGNAL("clicked()"),  self.debug_step_into)
        self.debug_stepinto.setIcon(icon_stepinto)

        self.debug_stepover = QToolButton()
        self.debug_stepover.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_stepover.setText("Step Over")
        self.debug_stepover.setFont(font)
        self.debug_stepover.setEnabled(False)
        self.debug_stepover.setIcon(icon_stepover)
        self.toolbar.addWidget(self.debug_stepover)
        QObject.connect(self.debug_stepover , SIGNAL("clicked()"),  self.debug_step_over)

        self.debug_stepout = QToolButton()
        self.debug_stepout.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_stepout.setText("Step Out")
        self.debug_stepout.setFont(font)
        self.debug_stepout.setEnabled(False)
        self.debug_stepout.setIcon(icon_stepout)
        self.toolbar.addWidget(self.debug_stepout)
        QObject.connect(self.debug_stepout , SIGNAL("clicked()"),  self.debug_step_out)

		 
        self.debug_pause_bt = QToolButton()
        self.debug_pause_bt.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_pause_bt.setText("Pause")
        self.debug_pause_bt.setFont(font)
        self.debug_pause_bt.setIcon(icon_pause)
        self.debug_pause_bt.setEnabled(False)
        self.toolbar.addWidget(self.debug_pause_bt)
        QObject.connect(self.debug_pause_bt , SIGNAL("clicked()"),  self.debug_pause)
 
        self.debug_continue_bt = QToolButton()
        self.debug_continue_bt.setToolButtonStyle(QtCore.Qt.ToolButtonTextUnderIcon)
        self.debug_continue_bt.setText("Continue")
        self.debug_continue_bt.setFont(font)
        self.debug_continue_bt.setEnabled(False)
        self.debug_continue_bt.setIcon(icon_continue)
        self.toolbar.addWidget(self.debug_continue_bt)
        QObject.connect(self.debug_continue_bt , SIGNAL("clicked()"),  self.debug_continue)

        self.current_debug_file = None

        right_spacer = QWidget()
        right_spacer.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.toolbar.addWidget(right_spacer)
        self.windows = {"file":True, "inspector":False, "console":False, "debug":False, "trace":False}

        self.file_toolBtn = QPushButton()
        self.file_toolBtn.setFixedWidth(30)
        self.file_toolBtn.setIcon(self.icon_file_on)
        self.file_toolBtn.setToolTip("File System")
        self.toolbar.addWidget(self.file_toolBtn)
        QObject.connect(self.file_toolBtn , SIGNAL("clicked()"),  self.fileWindowClicked)

        self.inspector_toolBtn = QPushButton()
        self.inspector_toolBtn.setFixedWidth(30)
        self.inspector_toolBtn.setIcon(self.icon_inspector_off)
        self.inspector_toolBtn.setToolTip("Inspector")
        self.toolbar.addWidget(self.inspector_toolBtn)
        QObject.connect(self.inspector_toolBtn , SIGNAL("clicked()"),  self.inspectorWindowClicked)
	
        self.console_toolBtn = QPushButton()
        self.console_toolBtn.setFixedWidth(30)
        self.console_toolBtn.setIcon(self.icon_console_off)
        self.console_toolBtn.setToolTip("Console")
        self.toolbar.addWidget(self.console_toolBtn)
        QObject.connect(self.console_toolBtn , SIGNAL("clicked()"),  self.consoleWindowClicked)

        self.debug_toolBtn = QPushButton()
        self.debug_toolBtn.setFixedWidth(30)
        self.debug_toolBtn.setIcon(self.icon_debug_off)
        self.debug_toolBtn.setToolTip("Debug")
        self.toolbar.addWidget(self.debug_toolBtn)
        QObject.connect(self.debug_toolBtn , SIGNAL("clicked()"),  self.debugWindowClicked)

        self.trace_toolBtn = QPushButton()
        self.trace_toolBtn.setFixedWidth(30)
        self.trace_toolBtn.setIcon(self.icon_trace_off)
        self.trace_toolBtn.setToolTip("Trace")
        self.toolbar.addWidget(self.trace_toolBtn)
        QObject.connect(self.trace_toolBtn , SIGNAL("clicked()"),  self.traceWindowClicked)

        # Search Flag
        self.find_expr = None
        self.replace_expr = None
        self.wo = None
        self.forward = None
        self.cs = None
        self.wrap = None
        self.onExit = False
        self.rSent = False

    def chgTool_debug(self) :
        if self.debug_tbt.text() != "Debug":
        	self.debug_tbt.setText("Debug")
        	self.debug_tbt.setIcon(self.icon_debug)

        	self.debug_menu.removeAction(self.debug_action)
        	self.debug_menu.addAction(self.run_action)
        	QObject.disconnect(self.debug_tbt , SIGNAL("clicked()"),  self.run)
        	QObject.connect(self.debug_tbt , SIGNAL("clicked()"),  self.debug)

    def chgTool_run(self) :
        if self.debug_tbt.text() != "Run":
        	self.debug_tbt.setText("Run")
        	self.debug_tbt.setIcon(self.icon_run)

        	self.debug_menu.removeAction(self.run_action)
        	self.debug_menu.addAction(self.debug_action)
	
        	QObject.disconnect(self.debug_tbt , SIGNAL("clicked()"),  self.debug)
        	QObject.connect(self.debug_tbt , SIGNAL("clicked()"),  self.run)

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
    def preference(self):
        return self._preference
    
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
		if self._deviceManager.ui.comboBox.currentIndex() != 0:
		    self.request = str(self.ui.interactive.text())
		    #print self.request
		    try:
			    ret = self.deviceManager.socket.write(self.request+'\n\n')
			    if ret < 0 :
				    print "[VDBG] tp console socket is not available"
    
		    except AttributeError, e:
    		    # deal with AttributeError
			    print "[VDBG] tp console socket is not opened"
		    self.ui.interactive.setText("")
		    self.request = ""
		else:
		    inputCmd = str(self.ui.interactive.text())
		    self._deviceManager.trickplay.write(inputCmd+"\n")
		    self._deviceManager.trickplay.waitForBytesWritten();
		    self.ui.interactive.setText("")
		
    def stop(self, serverStoped=False, exit=False):
        # send 'q' command and close trickplay process
        self.onExit = exit
        self.inspector.ui.refresh.setEnabled(False)
        self.inspector.ui.search.setEnabled(False)

        if self._deviceManager.trickplay.state() == QProcess.Running:
            # Local Debugging / Run 
            self.closedByIDE = True
            self._deviceManager.trickplay.close()
            self.closedByIDE = False
        elif self._deviceManager.ui.comboBox.currentIndex() != 0:
            # Remote Debugging / Run 
            #if getattr(self._deviceManager, "debug_mode") == False :
            if getattr(self, "debug_mode") == False and hasattr(self.deviceManager, "socket") == True:
                ret = self.deviceManager.socket.write('/close\n\n')
                if ret < 0 :
                    print ("tp console socket is not available !")
            elif serverStoped == False :
		        self.rSent = True
		        self._deviceManager.send_debugger_command(DBG_CMD_RESET)

        if getattr(self._deviceManager, "debug_mode") == True :
    	    # delete current line marker 
    	    for n in self.editorManager.editors:
    	        try :
    	            # delete current line marker and keep break point marker
    	            self.current_debug_file = str(self.path+'/'+self._deviceManager.file_name)
    	            if self.current_debug_file == n:
                        cEditor = self.editorManager.tab.editors[self.editorManager.editors[n][1]]
                        cLine = cEditor.current_line
                        lClick = 0
                        
                        if cEditor.line_click.has_key(cLine):
    	                    lClick = cEditor.line_click[cLine]

                        if lClick == 0 : #no break point
                            cEditor.markerDelete(cLine, -1)
                        elif lClick == 1 : #active break point 
                            cEditor.markerDelete(cLine, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
                            cEditor.markerAdd(cLine, Editor.ACTIVE_BREAK_MARKER_NUM)
                        elif lClick == 2 : #deactive break point
                            cEditor.markerDelete(cLine, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
                            cEditor.markerAdd(cLine, Editor.DEACTIVE_BREAK_MARKER_NUM)
    	                cEditor.current_line = -1
    	        except :
    	            print("[VDBG] exept ", self.editorManager.editors[n][1])

            # clean backtrace and debug window
            self.backtrace.clearTraceTable(0)
            self._debug.clearLocalTable(0)
            self._debug.clearGlobalTable(0)

        self.windows = {"file":False, "inspector":True, "console":True, "debug":True, "trace":True}
        self.inspectorWindowClicked()
        self.debugWindowClicked()
        self.traceWindowClicked()

        self.debug_stop.setEnabled(False)
        self.debug_stepinto.setEnabled(False)
        self.debug_stepover.setEnabled(False)
        self.debug_stepout.setEnabled(False)
        self.debug_pause_bt.setEnabled(False)
        self.debug_continue_bt.setEnabled(False)

        self.inspector.clearTree()
        self._deviceManager.ui.comboBox.setEnabled(True)
        self.debug_tbt.setEnabled(True)
        self.debuggerMenuEnabled(False)
        self.debug_mode = False
        self.deviceManager.debug_mode = False

    def run(self):
        self.inspector.clearTree()
        self._deviceManager.run(False)
        self.windows = {"file":False, "inspector":False, "console":False, "debug":True, "trace":False}
        self.inspectorWindowClicked()
        self.consoleWindowClicked()
        self.traceWindowClicked()
        self.debugWindowClicked()
        self.traceWindowClicked()
		
        self.debug_stop.setEnabled(True)
        self.debug_stepinto.setEnabled(False)
        self.debug_stepover.setEnabled(False)
        self.debug_stepout.setEnabled(False)
        self.debug_pause_bt.setEnabled(False)
        self.debug_continue_bt.setEnabled(False)

        self.ui.action_Stop.setEnabled(True)
        self.ui.actionContinue.setEnabled(False)
        self.ui.actionPause.setEnabled(False)
        self.ui.actionStep_into.setEnabled(False)
        self.ui.actionStep_over.setEnabled(False)
        self.ui.actionStep_out.setEnabled(False)

    	self.chgTool_run()

        self._deviceManager.ui.comboBox.setEnabled(False)
        self.debug_tbt.setEnabled(False)
        self.ui.action_Run.setEnabled(False)
        self.ui.action_Debug.setEnabled(False)

    def debug(self):
        ret = self._deviceManager.run(True)
        if ret != False :
            self.windows = {"file":False, "inspector":False, "console":False, "debug":False, "trace":False}
            self.inspectorWindowClicked()
            self.consoleWindowClicked()
            self.debugWindowClicked()
            self.traceWindowClicked()
    
            self.debug_stop.setEnabled(True)
            self.debug_stepinto.setEnabled(True)
            self.debug_stepover.setEnabled(False)
            self.debug_stepout.setEnabled(False)
            self.debug_continue_bt.setEnabled(True)

            self.ui.action_Stop.setEnabled(True)
            self.ui.actionContinue.setEnabled(True)
            self.ui.actionPause.setEnabled(False)
            self.ui.actionStep_into.setEnabled(True)
            self.ui.actionStep_over.setEnabled(True)
            self.ui.actionStep_out.setEnabled(False)
    
    	    self.chgTool_debug()
            self._deviceManager.ui.comboBox.setEnabled(False)
            self.debug_tbt.setEnabled(False)
            self.ui.action_Run.setEnabled(False)
            self.ui.action_Debug.setEnabled(False)
	
    def setEditorTabName(self, index):
        tabTitle = self.editorManager.tab.tabText(index)
        #if self.editorManager.tab.textBefores[index] == self.editorManager.tab.editors[index].text():
        if self.editorManager.editors[self.editorManager.tab.editors[index].path][2] == self.editorManager.tab.editors[index].text():
            if tabTitle[:1] == "*":
                self.editorManager.tab.setTabText (index, tabTitle[1:])
                self.editorManager.tab.editors[index].starMark = False
                self.editorManager.tab.editors[index].text_status = TEXT_READ
        else:
            if tabTitle[:1] != "*" :
                self.editorManager.tab.setTabText (index, "*"+self.editorManager.tab.tabText(index))
                self.editorManager.tab.editors[index].starMark = True
                self.editorManager.tab.editors[index].text_status = TEXT_CHANGED

    def editor_undo(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].undo()
                self.setEditorTabName(index)

    def editor_redo(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].redo()
                self.setEditorTabName(index)

    def editor_cut(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.editorManager.tab.editors[index].cut()
	
    def editor_copy(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				#self.editorManager.tab.editors[index].SendScintilla(QsciScintilla.SCI_SETSELEOLFILLED, True)
				#self.editorManager.tab.editors[index].setSelectionToEol(True)
				#self.editorManager.tab.editors[index].selectAll()
				#self.editorManager.tab.editors[index].setSelection(1,10,3,10)
				#print self.editorManager.tab.editors[index].selectedText()
				#self.editorManager.tab.editors[index].SendScintilla(QsciScintilla.SCI_COPYALLOWLINE, 0,0)
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
            print('[VDBG] Trickplay state : [ %s ]'%self.deviceManager.trickplay.state())
            #if self.trickplay.state() == QProcess.Running:
            self.exit()
            #self.deviceManager.trickplay.close()
            #    print('terminated trickplay')
        except AttributeError, e:
            pass
        
        #print('quitting')
        
    
    def start(self, path, openList = None):
        """
        Initialize widgets on the main window with a given app path
        """
        self.path = path
        
        self.fileSystem.start(self.editorManager, path)
        
        if path is not -1:
            self.setWindowTitle(QtGui.QApplication.translate("MainWindow", "TrickPlay IDE [ "+str(os.path.basename(str(path))+" ]"), None, QtGui.QApplication.UnicodeUTF8))
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
        settings.setValue("mainWindowSize", self.size());
        #settings.setValue("mainWindowState", self.saveState());
	
    def clearBreakPoints(self):
        for n in self.editorManager.editors:
            try :
                for l in self.editorManager.tab.editors[self.editorManager.editors[n][1]].line_click:
                    self.editorManager.tab.editors[self.editorManager.editors[n][1]].markerDelete(int(l), -1) 
                self.editorManager.tab.editors[self.editorManager.editors[n][1]].line_click = {}
            except :
                print("[VDBG] clearBreakPoints failed")
        self.editorManager.bp_info = {1:[], 2:[]}
        self._debug.clearBreakTable(0)


    def openApp(self):
		wizard = Wizard()
		path = -1
		while path == -1 :
		    if self.path is None:
		        self.path = self.apath
		    path = QFileDialog.getExistingDirectory(None, 'Open App', self.path, QFileDialog.ShowDirsOnly)
		    path = wizard.start(path, True)
		print ("[VDBG] openApp [%s]"%path)
		if path:
			settings = QSettings()
			if settings.value('path') is not None:
			    self.stop()
			self.clearBreakPoints()
			settings.setValue('path', path)
			self.start(path, wizard.filesToOpen())
			self.setWindowTitle(QtGui.QApplication.translate("MainWindow", "TrickPlay IDE [ "+str(os.path.basename(str(path))+" ]") , None, QtGui.QApplication.UnicodeUTF8))
			if self.editorManager.tab != None:
			    while self.editorManager.tab.count() != 0:
			        self.editorManager.close()

    def new(self):
		orgPath = self.path
		wizard = Wizard()
		path = wizard.start("", False, True)
		if path and path != orgPath :
			settings = QSettings()
			if settings.value('path') is not None:
			    self.stop()
			self.clearBreakPoints()
			settings.setValue('path', path)
			self.start(path, wizard.filesToOpen())
			self.setWindowTitle(QtGui.QApplication.translate("MainWindow", "TrickPlay IDE [ "+str(os.path.basename(str(path)))+" ]" , None, QtGui.QApplication.UnicodeUTF8))
			if self.editorManager.tab != None:
			    while self.editorManager.tab.count() != 0:
			        self.editorManager.close()

    def preferenceStart(self):
        self.preference.start()

    def exit(self):
        self.stop(False, True)
        if self.rSent == False:
    	    if self.editorManager.tab != None:
    		    while self.editorManager.tab.count() != 0:
				    self.editorManager.close()

    	    #settings = QSettings()
            #for i in range (0, len(self._preference.lexerLua)):
                #settings.remove(self._preference.lexerLua[i]+"FC")
                #settings.remove(self._preference.lexerLua[i]+"BC")
                #settings.remove(self._preference.lexerLua[i])

            self._deviceManager.stop()
            self.close()



    def newFile(self):
    	file_name = self.path+'/Untitled_'+str(self.untitled_idx)+".lua"
        while os.path.exists(file_name) is True: 
            self.untitled_idx += 1
    	    file_name = self.path+'/Untitled_'+str(self.untitled_idx)+".lua"
        
        #TODO check if file_name is available and ... 

    	self.editorManager.newEditor(file_name, None, None, None, False, None, True)
    	self.untitled_idx = self.untitled_idx + 1
		
    def editor_search(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.search_dialog = QDialog()
				self.search_ui = Ui_searchDialog()
				self.search_ui.setupUi(self.search_dialog)
    			QObject.connect(self.search_ui.search_txt , SIGNAL("textChanged(QString)"),  self.search_textChanged)
				
    			self.search_ui.okButton = self.search_ui.buttonBox.button(QDialogButtonBox.Ok)
    			self.search_ui.okButton.setEnabled(False)

    			while self.search_dialog.exec_() :
					cur_geo = self.search_dialog.geometry()
					expr = self.search_ui.search_txt.text()
					re = False
					cs = self.search_ui.checkBox_case.isChecked() 
					wo = self.search_ui.checkBox_word.isChecked() 
					wrap = self.search_ui.checkBox_wrap.isChecked() 
					forward = self.search_ui.checkBox_forward.isChecked() 
					search_res = self.editorManager.tab.editors[index].findFirst(expr,re,cs,wo,wrap,forward)

					self.search_dialog = QDialog()
					self.search_ui = Ui_searchDialog()
					self.search_ui.setupUi(self.search_dialog)
					self.search_ui.search_txt.setText(expr)
					self.search_ui.checkBox_case.setChecked(cs) 
					self.search_ui.checkBox_word.setChecked(wo) 
					self.search_ui.checkBox_wrap.setChecked(wrap) 
					self.search_ui.checkBox_forward.setChecked(forward) 
					self.search_dialog.setGeometry(cur_geo)
					if search_res == False:
						self.search_ui.notification.setText("String Not Found") 
					else :
						self.search_ui.notification.setText("")


    def  search_textChanged(self, change):
		if len (self.search_ui.search_txt.text()) >= 1 :
			self.search_ui.okButton.setEnabled(True)
		else:
			self.search_ui.okButton.setEnabled(False)

    def editor_search_replace(self, expr="",replace_expr="", cs=True, wo=True, wrap=True, forward=True, cur_geo=None):
    	if self.editorManager.tab:
    		index = self.editorManager.tab.currentIndex()
    		if not index < 0:
    			self.replace_dialog = QDialog()
    			self.replace_ui = Ui_replaceDialog()
    			self.replace_ui.setupUi(self.replace_dialog)
    			self.prevForward = True
    			if self.find_expr is not None :
    			    self.replace_ui.search_txt.setText(self.find_expr)
    			    self.replace_ui.pushButton_find.setEnabled(True)
        		    self.replace_ui.pushButton_replaceAll.setEnabled(True)
    			    if self.replace_expr is not None :
    			        self.replace_ui.replace_txt.setText(self.replace_expr)
    			else:
    			    self.replace_ui.pushButton_find.setEnabled(False)
        		    self.replace_ui.pushButton_replaceAll.setEnabled(False)
        		    self.replace_ui.pushButton_replace.setEnabled(False)
        		    self.replace_ui.pushButton_replaceFind.setEnabled(False)

    			if self.forward is not None :
    			    if self.forward is False:
    			        self.replace_ui.radioButton_bw.setChecked(True)
    			if self.cs is not None :
    			    self.replace_ui.checkBox_case.setChecked(self.cs)
    			if self.wo is not None :
    			    self.replace_ui.checkBox_word.setChecked(self.wo)
    			if self.wrap is not None :
    			    self.replace_ui.checkBox_wrap.setChecked(self.wrap)

    			QObject.connect(self.replace_ui.search_txt , SIGNAL("textChanged(QString)"),  self.replace_textChanged)
    			QObject.connect(self.replace_ui.pushButton_close , SIGNAL("clicked()"),  self.replace_close)
    			QObject.connect(self.replace_ui.pushButton_find , SIGNAL("clicked()"),  self.replace_find)
    			QObject.connect(self.replace_ui.pushButton_replace , SIGNAL("clicked()"),  self.replace_replace)
    			QObject.connect(self.replace_ui.pushButton_replaceAll , SIGNAL("clicked()"),  self.replace_replaceAll)
    			QObject.connect(self.replace_ui.pushButton_replaceFind , SIGNAL("clicked()"),  self.replace_replaceFind)

    			while self.replace_dialog.exec_() :
					cur_geo = self.replace_dialog.geometry()
					expr = self.replace_ui.search_txt.text()
					self.find_expr = expr
					replace_expr = self.replace_ui.replace_txt.text()
					self.replace_expr = replace_expr
					re = False
					cs = self.replace_ui.checkBox_case.isChecked() 
					wo = self.replace_ui.checkBox_word.isChecked() 
					wrap = self.replace_ui.checkBox_wrap.isChecked() 
					forward = self.replace_ui.radioButton_fw.isChecked() 
					self.cs = cs
					self.wo = wo
					self.wrap = wrap
					self.forward = forward

					self.replace_ui.search_txt.setText(expr)
					self.replace_ui.replace_txt.setText(replace_expr)
					self.replace_ui.checkBox_case.setChecked(cs) 
					self.replace_ui.checkBox_word.setChecked(wo) 
					self.replace_ui.checkBox_wrap.setChecked(wrap) 
					self.replace_ui.radioButton.setChecked(forward) 
					self.replace_dialog.setGeometry(cur_geo)
	
    def  replace_textChanged(self, change):
		if len (self.replace_ui.search_txt.text()) >= 1 :
			self.replace_ui.pushButton_find.setEnabled(True)
			self.replace_ui.pushButton_replaceAll.setEnabled(True)
		else:
			self.replace_ui.pushButton_find.setEnabled(False)
			self.replace_ui.pushButton_replace.setEnabled(False)
			self.replace_ui.pushButton_replaceAll.setEnabled(False)
			self.replace_ui.pushButton_replaceFind.setEnabled(False)

    def  replace_close(self):
		self.replace_dialog.close()

    def  replace_find(self, replaceall = False):
		cur_geo = self.replace_dialog.geometry()
		expr = self.replace_ui.search_txt.text()
		self.find_expr = expr
		replace_expr = self.replace_ui.replace_txt.text()
		self.replace_expr = replace_expr
		re = False
		cs = self.replace_ui.checkBox_case.isChecked() 
		wo = self.replace_ui.checkBox_word.isChecked() 
		wrap = self.replace_ui.checkBox_wrap.isChecked() 
		forward = self.replace_ui.radioButton_fw.isChecked() 
		self.cs = cs
		self.wo = wo
		self.wrap = wrap
		self.forward = forward
		if replaceall is True:
		    wo = True

		if forward is False and self.prevForward is True:
		    self.firstBackward = True

		index = self.editorManager.tab.currentIndex()
		if forward is True or self.firstBackward is True:
		    find_result = self.editorManager.tab.editors[index].findFirst(expr,re,cs,wo,wrap,forward)
		    self.firstBackward = False
		else:
		    find_result = self.editorManager.tab.editors[index].findNext()

		if find_result == False :
			self.replace_ui.notification.setText("String Not Found") 
			self.replace_ui.pushButton_replace.setEnabled(False)
			self.replace_ui.pushButton_replaceFind.setEnabled(False)
		else:
			self.replace_ui.notification.setText("")
			self.replace_ui.pushButton_replace.setEnabled(True)
			self.replace_ui.pushButton_replaceFind.setEnabled(True)

		self.prevForward = forward 
		return find_result

    def  replace_replace(self):
		replace_expr = self.replace_ui.replace_txt.text()
		index = self.editorManager.tab.currentIndex()
		self.editorManager.tab.editors[index].replace(replace_expr)

    def  replace_replaceAll(self):
		findNext = self.replace_find(True) 
		if findNext == False:
			self.replace_ui.notification.setText("String Not Found") 
			self.replace_ui.pushButton_replace.setEnabled(False)
			self.replace_ui.pushButton_replaceFind.setEnabled(False)
			return

		replaceNum = 0 
		while findNext == True:
			self.replace_replace()
			findNext = self.replace_find(True)
			replaceNum = replaceNum + 1 

		self.replace_ui.notification.setText(str(replaceNum)+" matches replaced") 

    def  replace_replaceFind(self):
		self.replace_replace()
		self.replace_find()

    def editor_go_to_line(self):
		if self.editorManager.tab:
			index = self.editorManager.tab.currentIndex()
			if not index < 0:
				self.gotoLine_dialog = QDialog()
				self.gotoLine_ui = Ui_gotoLineDialog()
				self.gotoLine_ui.setupUi(self.gotoLine_dialog)
    			QObject.connect(self.gotoLine_ui.line_txt , SIGNAL("textChanged(QString)"),  self.line_textChanged)

    			self.gotoLine_ui.okButton = self.gotoLine_ui.buttonBox.button(QDialogButtonBox.Ok)
    			self.gotoLine_ui.okButton.setEnabled(False)

    			while self.gotoLine_dialog.exec_() :
					cur_geo = self.gotoLine_dialog.geometry()
					try :
						lineNum = int(self.gotoLine_ui.line_txt.text())
					except :
						lineNum = -1
					maxNum = self.editorManager.tab.editors[index].lines()
					if 1 <= lineNum and lineNum <= maxNum:
						self.editorManager.tab.editors[index].SendScintilla(QsciScintilla.SCI_GOTOLINE, int(lineNum) - 1)
						return
					else :
						self.gotoLine_ui.line_txt.setText(str(lineNum))
						self.gotoLine_dialog = QDialog()
						self.gotoLine_ui = Ui_gotoLineDialog()
						self.gotoLine_ui.setupUi(self.gotoLine_dialog)
						self.gotoLine_dialog.setGeometry(cur_geo)

    def  line_textChanged(self, change):
		if len (self.gotoLine_ui.line_txt.text()) >= 1 :
			try :
				lineNum = int(self.gotoLine_ui.line_txt.text())
				self.gotoLine_ui.notification.setText("")
			except :
				self.gotoLine_ui.notification.setText("Not a number")
				lineNum = -1
			index = self.editorManager.tab.currentIndex()
			maxNum = self.editorManager.tab.editors[index].lines()
			if lineNum < 1 :
				self.gotoLine_ui.notification.setText("Line number out of range")
				self.gotoLine_ui.okButton.setEnabled(False)
			elif lineNum > maxNum:
				self.gotoLine_ui.notification.setText("Line number out of range")
				self.gotoLine_ui.okButton.setEnabled(False)
			else:
				self.gotoLine_ui.notification.setText("")
				self.gotoLine_ui.okButton.setEnabled(True)
		else:
			self.gotoLine_ui.okButton.setEnabled(False)

    def debug_continue(self):
        # delete current line marker 
        for n in self.editorManager.editors:
            try :
                # delete current line marker and keep break point marker
                self.current_debug_file = str(self.path+'/'+self._deviceManager.file_name)
                if self.current_debug_file == n:
                    cEditor = self.editorManager.tab.editors[self.editorManager.editors[n][1]]
                    cLine = cEditor.current_line
                    lClick = 0
                    if cEditor.line_click.has_key(cLine):
                        lClick = cEditor.line_click[cLine]

                    if lClick == 0 : #no break point
                        cEditor.markerDelete(cLine, -1)
                    elif lClick == 1 : #active break point 
                        cEditor.markerDelete(cLine, Editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
                        cEditor.markerAdd(cLine, Editor.ACTIVE_BREAK_MARKER_NUM)
                    elif lClick == 2 : #deactive break point
                        cEditor.markerDelete(cLine, Editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
                        cEditor.markerAdd(cLine, Editor.DEACTIVE_BREAK_MARKER_NUM)
                    cEditor.current_line = -1
            except :
                print("[VDBG] exept ", self.editorManager.editors[n][1])

        self._deviceManager.send_debugger_command(DBG_CMD_CONTINUE)
        self.inspector.ui.refresh.setEnabled(True)
        self.inspector.ui.search.setEnabled(True)
        return

    def debug_pause(self):
		self._deviceManager.send_debugger_command(DBG_CMD_BREAK_NEXT)
		self.inspector.clearTree()
		self.inspector.ui.refresh.setEnabled(False)
		self.inspector.ui.search.setEnabled(False)
		return

    def debug_step_into(self):
		self._deviceManager.send_debugger_command(DBG_CMD_STEP_INTO)
		return

    def debug_step_over(self):
		self._deviceManager.send_debugger_command(DBG_CMD_STEP_OVER)
		return

    def debug_step_out(self):
		return

    def editorMenuEnabled(self, enabled=True):
        self.ui.action_Save.setEnabled(enabled)
        self.ui.action_Save_As.setEnabled(enabled)
        self.ui.actionSave_All.setEnabled(enabled)
        self.ui.action_Close.setEnabled(enabled)
        if enabled == False :
            self.ui.actionUndo.setEnabled(enabled)
            self.ui.actionRedo.setEnabled(enabled)
            self.ui.action_Cut.setEnabled(enabled)
            self.ui.action_Copy.setEnabled(enabled)
            self.ui.action_Delete.setEnabled(enabled)

        self.ui.action_Paste.setEnabled(enabled)

        self.ui.actionSelect_All.setEnabled(enabled)
        self.ui.actionSearch_Replace.setEnabled(enabled)
        self.ui.actionGo_to_line.setEnabled(enabled)

    def debuggerMenuEnabled(self, enabled=True):

        self.ui.action_Run.setEnabled(not enabled)
        self.ui.action_Debug.setEnabled(not enabled)

        self.ui.action_Stop.setEnabled(enabled)
        self.ui.actionContinue.setEnabled(enabled)
        self.ui.actionPause.setEnabled(enabled)
        self.ui.actionStep_into.setEnabled(enabled)
        self.ui.actionStep_over.setEnabled(enabled)
        self.ui.actionStep_out.setEnabled(False)
