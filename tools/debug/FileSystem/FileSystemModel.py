import os, re
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from Editor import *
from UI.NewFolder import Ui_newFolderDialog


class FileSystemModel(QFileSystemModel):
    
    def __init__(self, view, path, editorManager, parent = None):
        
        QFileSystemModel.__init__(self, parent)
        
        self.setReadOnly(False)
        if path is -1 :
            return 
        self.setRootPath(path)
        
        self.path = path
        
        view.setModel(self)
        view.setRootIndex(self.index(path))

        self.view = view
        self.editorManager = editorManager
        
        header = view.header()
        for i in range(1,4):
            header.hideSection(header.logicalIndex(i))
            
        view.setContextMenuPolicy(Qt.CustomContextMenu)
        self.createContextMenu()
        QObject.connect(view, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)
            
    def createContextMenu(self):
        
		# Toolbar font 
        font = QFont()
        font.setPointSize(9)

        # Popup Menu
        self.popMenu = QMenu( self.view )
        self.popMenu.setFont(font)
        self.popMenu.addAction( '&Rename', self.rename )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Delete', self.delete )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&New_Directory', self.newDir )
        
    def contextMenu(self, point):
        self.popMenu.exec_( self.view.mapToGlobal(point) )
    
    def currentIndex(self):
        indexList = self.view.selectedIndexes()
        if len(indexList) == 1:
            return indexList[0]
        else:
            return None
    
    def delete(self):
        i = self.currentIndex()
        if i:
            #Close the tab if the file is opened. 
            if self.isDir(i) == False:
                file_path = self.filePath(i)
                for n in self.editorManager.editors :
                    if n == file_path:
                        try :
                            self.editorManager.tab.editors[self.editorManager.editors[n][1]].delete_marker()
                            self.editorManager.tab.closeTab(self.editorManager.editors[n][1])
                        except:
                            self.editorManager.delete_marker(n)

                        break
        success = self.remove(i)
            
    def rename(self):
        i = self.currentIndex()
        if i:
            self.view.setCurrentIndex(i)
            self.view.edit(i)

    def newDir(self):
        i = self.currentIndex()
        if i:
            self.view.setCurrentIndex(i)
            path = self.filePath(i)
        else: 
        	path = self.path 

        self.dialog = QDialog()
        self.ui = Ui_newFolderDialog()
        self.ui.setupUi(self.dialog)
			
        if self.dialog.exec_():
			dir_name = self.ui.folder_name.text()

			if self.isDir(i):
				new_path = path+"/"+dir_name
				self.view.expand(i)
			else:
				new_path = path[:re.search('(\w+)[.](\w+)', path).start()-1] +"/"+dir_name
			new_path = str(new_path)
			if not os.path.exists(new_path):
				os.makedirs(new_path)
				

