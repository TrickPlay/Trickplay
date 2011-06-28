import sys
from PyQt4 import QtCore, QtGui
from TreeView import Ui_MainWindow
from TreeModel import *

class StartQT4(QtGui.QMainWindow):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        QtCore.QObject.connect(self.ui.button_Refresh, QtCore.SIGNAL("clicked()"), self.exit)
        
        node = NamedElement("Screen",  [])
        self.model = NamesModel([node])
        
        i = self.model.index(0, 0, QModelIndex())
        #print(self.model.parent(index))
        print(self.model.data(i, Qt.DisplayRole))
        self.ui.Inspector.setModel(self.model)
        
    def exit(self):
        sys.exit("Successfully Exited")
        


if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    myapp = StartQT4()
    myapp.show()
    sys.exit(app.exec_())
