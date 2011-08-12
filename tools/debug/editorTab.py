from PyQt4.QtGui import *
from PyQt4.QtCore import *

class EditorTabWidget(QTabWidget):

    def __init__(self, parent = None):
        
        QTabWidget.__init__(self, parent)
        
        self.setDocumentMode(True)
        self.setTabsClosable(True)
        self.setMovable(True)
        self.setCurrentIndex(-1)
        self.setAcceptDrops(True)
        
    def dragEnterEvent(self, event):
        print('awoefuijkhawf', event)
        


"""
Subclass of dock to handle drag/drop events
"""
class EditorDock(QDockWidget):
    
    def __init__(self, parent = None):
        QDockWidget.__init__(self, parent)
        self.setAcceptDrops(True)
        self.setFeatures(QDockWidget.DockWidgetClosable)
        self.setObjectName("editorDock")
        self.setWindowTitle("Text Editor")
        
    def dragEnterEvent(self, event):
        print('awoefuijkhawf', event)
        