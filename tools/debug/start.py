import sys
import urllib
import urllib2
import json
from PyQt4 import QtCore, QtGui
from TreeView import Ui_MainWindow
from TreeModel import *

class StartQT4(QtGui.QMainWindow):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        QtCore.QObject.connect(self.ui.button_Refresh, QtCore.SIGNAL("clicked()"), self.refresh)
        
        node = NamedElement("Screen",  [])
        self.model = NamedModel([node])
        
        #i = self.model.index(0, 0, QModelIndex())
        #print(self.model.parent(index))
        #print(self.model.data(i, Qt.DisplayRole))
        self.ui.Inspector.setModel(self.model)
        
        i = self.model.index(0,0,QModelIndex())
        row = self.model.rowCount(QModelIndex())
        
        #self.model._createNode(2)
        
    def refresh(self):
        getTrickplayData()
        #sys.exit("Successfully Exited")
        
def getTrickplayData():
    r = urllib2.Request("http://localhost:8888/debug/ui")
    f = urllib2.urlopen(r)
    return decode(f.read())

def decode(input):
    return json.loads(input)

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    myapp = StartQT4()
    myapp.show()
    sys.exit(app.exec_())
    
#QtCore.QAbstractItemModel.insertRow(1)
