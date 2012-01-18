
from PyQt4.QtGui import *
from PyQt4.QtCore import *

from Editor import Editor


class EditorTabWidget(QTabWidget):

    def __init__(self, main, parent = None):
        
        QTabWidget.__init__(self, parent)
        
        self.setDocumentMode(True)
        self.setTabsClosable(True)
        self.setMovable(True)
        self.setCurrentIndex(-1)
        self.setAcceptDrops(True)
        
        self.main = main
        self.paths = []
        self.editors = []
        self.textBefores = []
        
        QObject.connect(self, SIGNAL('tabCloseRequested(int)'), self.closeTab)
        QObject.connect(self, SIGNAL('currentChanged(int)'), self.changeTab)
        
    def dragEnterEvent(self, event):
        event.acceptProposedAction()
        
    def dropEvent(self, event):
        self.main.dropFileEvent(event, 'tab', self)
        
    def closeTab(self, index):
		if index < 0:
			return 
		# find current index tab 
		index = self.currentIndex()

		# save before close
		print index
		editor = self.editors[index] #self.app.focusWidget()
		if isinstance(editor, Editor):
			currentText = editor.text()#open(editor.path).read()
			if self.textBefores[index] != currentText:
				if editor.text_status == 2: #TEXT_CHANGED
					msg = QMessageBox()
					msg.setText('The file "' + editor.path + '" changed.')
					msg.setInformativeText('If you don\'t save it, the changes will be permanently lost.')
					msg.setStandardButtons(QMessageBox.Save | QMessageBox.Cancel)
					msg.addButton("Close without Saving" , QMessageBox.NoRole )
					msg.setDefaultButton(QMessageBox.Cancel)
					msg.setWindowTitle("Warning")
					ret = msg.exec_()

					if ret == QMessageBox.Save:
						self.textBefores[index] = editor.text()
						editor.text_status = 1 #TEXT_READ
						editor.save()
					elif ret == QMessageBox.Cancel:
						return 
					else:
						pass

		#close current index tab
		self.paths.pop(index)
		self.textBefores.pop(index) #new
		self.editors.pop(index) #new
		self.removeTab(index)
		if 0 == self.count():
			self.close()
			self.main.getEditorTabs().pop(self.main.getTabWidgetNumber(self))

    def changeTab(self, index):

		if index == -1:
			return 

		currentText = open(self.paths[index]).read()

		if self.textBefores[index] != currentText:
			msg = QMessageBox()
			msg.setText('The file "' + self.paths[index] + '" changed on disk.')
			if self.editors[index].text_status == 2: #TEXT_CHANGED
				msg.setInformativeText('Do you want to drop your changes and reload the file ?')
			else:
				msg.setInformativeText('Do you want to reload the file ?')
			msg.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
			msg.setDefaultButton(QMessageBox.Cancel)
			msg.setWindowTitle("Warning")
			ret = msg.exec_()

			if ret == QMessageBox.Ok:
    			# Reload 
				self.editors[index].readFile(self.paths[index])
				self.textBefores[index] = self.editors[index].text()
				self.editors[index].text_status = 1 #TEXT_READ

		self.setCurrentIndex(index)


"""
Subclass of dock to handle drag/drop events
"""
class EditorDock(QDockWidget):
    
    def __init__(self, main, parent = None):
        QDockWidget.__init__(self, parent)
        self.setAcceptDrops(True)
        #self.setFeatures(QDockWidget.DockWidgetClosable)
        self.setFeatures(QDockWidget.DockWidgetMovable)
        self.setObjectName("editorDock")
        #self.setWindowTitle("Text Editor")
        
        self.main = main
        
    def dragEnterEvent(self, event):
        event.acceptProposedAction()
        
    def dropEvent(self, event):
        self.main.dropFileEvent(event, 'dock')
        
        #print('From', event.source(), event.mimeData().hasText())
        #if event.mimeData().hasText():
        #    event.acceptProposedAction()
        #    path = str(event.mimeData().urls()[0].path())
        #    self.main.newEditor(path)
        #elif event.source() == self.main.getFileSystemView():
        #    self.main.openInEditor(event.source().currentIndex())
        #else:
        #    print('Failed to open dropped file.')
        #    #self.main.openInEditor()
            #print(event.mimeData().urls())
            #self.main.getFileSystemModel().currentIndex()
