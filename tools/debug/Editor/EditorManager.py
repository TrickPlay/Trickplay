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
        self.bp_info = {1:[],2:[]}
        self.fontSettingCheck = {}


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
        font.setFamily('Inconsolata')
        font.setPointSize(12)
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
        tab = EditorTabWidget(self, self.windowsMenu, self.fileSystem, self.splitter, self.main)
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
			if editor.tempfile is True:
				self.saveas(editor_index)
				return 

			editor.save(None, editor_index)

			if self.editors.has_key(editor.path):
			    self.editors[editor.path][2] = editor.text() 
		else:
			print '[VDBG] Failed to save because no text editor is currently selected.'                
		
    def saveall(self):
		index = 0 
		for editor in self.tab.editors :
			if self.tab.editors[index].tempfile is True :
			    index_offset = 0
			else :
			    index_offset = 1
			self.save(index)
			index = index + index_offset

    def close(self, editor_index = None):
        if editor_index is None:
            index = self.tab.currentIndex()
        else:
            index = editor_index

        self.tab.closeTab(index)

    def get_bp_path(self, file_path):
        if re.search(str(self.deviceManager.path()), file_path) is not None :
            n = re.search(str(self.deviceManager.path()), file_path).end()
            editorName = str(file_path[n:])
            if editorName.startswith("/"):
                return editorName[1:]


    def delete_marker(self, bp_file):

        bp_file = self.get_bp_path(bp_file)

        bp_cnt = len(self.bp_info[1]) 
        if bp_cnt > 0:
            idx=0
            for r in range(0, bp_cnt):
                bp_info = self.bp_info[2][idx]
                n = re.search(":", bp_info).end()
                fileName = bp_info[:n-1]
                lineNum  = int(bp_info[n:]) -1
                if fileName == bp_file :
                    if self.deviceManager.debug_mode == True:
                        self.deviceManager.send_debugger_command(DBG_CMD_DELETE+" %s"%str(idx))
            
                    self.bp_info[1].pop(idx)
                    self.bp_info[2].pop(idx)
                    self.debugWindow.ui.breakTable.removeRow(idx)
                else:
                    idx += 1

    def saveas(self, editor_index= None):
		self.dialog = QDialog()
		self.ui = Ui_saveAsDialog()
		self.ui.setupUi(self.dialog)

		if editor_index is not None:
			editor = self.tab.editors[editor_index]
		else:
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

			if str(new_path) == str(editor.path) and editor.tempfile == False :
			    msg = QMessageBox()
			    msg.setText('The file named "' + cur_file + '" already exists in "'+ cur_dir + '". Do you want to replace it? ')
			    msg.setInformativeText('Saving it will overwrite its contents.')
			    msg.setStandardButtons(QMessageBox.Save | QMessageBox.Cancel)
			    msg.setDefaultButton(QMessageBox.Cancel)
			    msg.setWindowTitle("Warning")
			    ret = msg.exec_()
			    if ret == QMessageBox.Cancel:
			        return 

			print "[VDBG] Save As .. ' %s '"%new_path
			bp_file = self.get_bp_path(new_path)

			if editor.tempfile == False :
				currentText = editor.text()
				editor.save(self.editors[editor.path][2], editor_index)
				editor.set_temp_marker(bp_file)
				editor.delete_marker()
				self.close()
				"""
				if len(self.bp_info[1]) > 0:
				    for i in range (0, len(self.bp_info[1])) :
				        print self.bp_info[1][i]
				        print self.bp_info[2][i]
				"""
				self.newEditor(new_path, None, None, None, False, None, False, currentText)
				editor = self.app.focusWidget()
				editor.save(None, editor_index)
				editor.add_marker()
			else :
				currentText = editor.text()
				editor.reload_marker()
				if self.editors.has_key(editor.path):
				    editor.setText(self.editors[editor.path][2])
				editor.set_temp_marker(bp_file)
				if editor.path != new_path :
				    editor.delete_marker()
				
				self.close(editor_index)

				"""
				if len(self.bp_info[1]) > 0:
				    for i in range (0, len(self.bp_info[1])) :
				        print self.bp_info[1][i]
				        print self.bp_info[2][i]
				"""
				self.newEditor(new_path, None, None, None, False, None, False, currentText)
				editor = self.app.focusWidget()
				editor.save()
				editor.add_marker()
                
    def newEditor(self, path, tabGroup = None, line_no = None, prev_file = None, currentLine = False, fileIndex=None,
    tempfile = False, currentText=None):
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

        #closedTab = None
        closedTab = []

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
				if not str(k) in self.tab.paths:
					#closedTab = k
					closedTab.append(k)

            #if closedTab != None:
            if len(closedTab) > 0 :
        		#self.editors.pop(closedTab)
        		for c_idx in range (0, len(closedTab)):
        		    self.editors.pop(closedTab[c_idx])

        		for k in self.tab.paths:
					self.editors[k][1] = self.tab.paths.index(k) 
        		if editor.tempfile == False:
        		    if currentText is None:
        			    editor.readFile(path) 
        		    else:
        			    editor.setText(currentText) 

            #if closedTab != path:
            if not path in closedTab :
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
									#if closedTab != prev_file:
									if not prev_file in closedTab :
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
				#print ("return here - opened tab")
				return self.currentEditor
        elif tempfile == False:
            path = os.path.join (self.deviceManager.path(), path)
            if currentText is None:
                editor.readFile(path)
            else:
                editor.setText(currentText) 
        
        if 0 == nTabGroups:
			seperatorAction = self.windowsMenu.addSeparator()

        if not self.editors.has_key(path):
            self.tab.paths.append(path)
            #self.tab.textBefores.append(editor.text())
            #self.editors[path][2] = editor.text()
            self.tab.editors.append(editor)

        index = self.editorGroups[tabGroup].addTab(editor, name)
        editor.tabIndex = index

        if not self.editors.has_key(path):
            self.editors[path] = [editor, index, editor.text()]
        
        self.editorGroups[tabGroup].setCurrentIndex(index)
        editor.setFocus()
        editor.path = path
        if len(self.bp_info[1]) > 0:
            editor.show_marker()

        n = re.search("[/]+\S+[/]+", editor.path).end()
        fileName = editor.path[n:]
		
        editorAction = QAction(self.windowsMenu)
        editorAction.setText(fileName)
        editorAction.setIconText(editor.path)
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

        if self.tab.count() > 0:
            self.main.editorMenuEnabled()

            if self.currentEditor is not None :
                if self.currentEditor.isRedoAvailable() == True:
                    self.main.ui.actionRedo.setEnabled(True)
                else :
                    self.main.ui.actionRedo.setEnabled(False)
    
                if self.currentEditor.isUndoAvailable() == True:
                    self.main.ui.actionUndo.setEnabled(True)
                else :
                    self.main.ui.actionUndo.setEnabled(False)

        #print ("return there - new tab")
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

            fi = QFileInfo(path)
            ext = fi.suffix();
            name = os.path.basename(str(path))
            if ext == "lua" or ext == "txt" or name == "app":
                self.newEditor(path, n, None, None, False, fileIndex, False)       
            else:
                print"[VDBG] This is %s"%str(model.type(fileIndex))+". Not editable."
                return
            
    #def getBPInfo_file (self):
        
