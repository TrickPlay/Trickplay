from PyQt4.QtGui import *
from PyQt4.QtCore import *

class FileSystemModel(QFileSystemModel):
    
    def __init__(self, view, path, parent = None):
        
        QFileSystemModel.__init__(self, parent)
        
        self.setReadOnly(False)
        self.setRootPath(path)
        
        view.setModel(self)
        view.setRootIndex(self.index(path))
        self.view = view
        
        header = view.header()
        for i in range(1,4):
            header.hideSection(header.logicalIndex(i))
            
        view.setContextMenuPolicy(Qt.CustomContextMenu)
        self.createContextMenu()
        QObject.connect(view, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)
            
    def createContextMenu(self):
        
        # Popup Menu
        self.popMenu = QMenu( self.view )
        self.popMenu.addAction( '&Rename', self.rename )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Delete', self.delete )
        
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
            success = self.remove(i)
            
    def rename(self):
        i = self.currentIndex()
        if i:
            self.view.setCurrentIndex(i)
            self.view.edit(i)