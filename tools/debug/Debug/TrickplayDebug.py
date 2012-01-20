from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.Debugger import Ui_TrickplayDebugger
from UI.Backtrace import Ui_TrickplayBacktrace

class TrickplayDebugger(QWidget):
    
    def __init__(self, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayDebugger()
        self.ui.setupUi(self)
        
class TrickplayBacktrace(QWidget):
    def __init__(self, parent = None, f = 0):
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayBacktrace()
        self.ui.setupUi(self)
        
