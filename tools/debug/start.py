#!/usr/bin/env python

""" 

Features to add:

1.   Two views, one for UI elements and oen for properties
2.   Checkboxes for hide/show
3.   Drag and drop UI elements?

"""

import sys,  pprint

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from TreeView import Ui_MainWindow

from delegate import InspectorDelegate
import connection
from model import ElementModel
from dataTypes import BadDataException

# Custom ItemDataRoles

Qt.Pointer = Qt.UserRole + 1
Qt.Value = Qt.UserRole + 2
Qt.Element = Qt.UserRole + 3
Qt.ItemDepth = Qt.UserRole + 4
    
class StartQT4(QMainWindow):
    def __init__(self, parent=None):

        # Main window setup
        QWidget.__init__(self, parent)
        
        self.ui = Ui_MainWindow()
        
        self.ui.setupUi(self)
        
        # Buttons
        QObject.connect(self.ui.button_Refresh, SIGNAL("clicked()"), self.refresh)
        
        QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        
        # Models
        self.inspectorModel = ElementModel()
        
        self.propertyModel = ElementModel()
        
        #self.model.connect(self.model, SIGNAL('itemChanged( QStandardItem * )'), self.itemChanged)
        
        # Delegates
        self.inspectorDelegate = InspectorDelegate()
        
        #self.inspectorDelegate.connect(self.delegate,  SIGNAL('closeEditor( QWidget * , QAbstractItemDelegate::EndEditHint )'),  self.editorClosed)
        
        self.ui.inspector.setItemDelegate(self.inspectorDelegate)

        self.createTree()
        
        self.lastChanged = None
        
    def editorClosed(self,  lineEditor,  hint):
        
        return
        
        if self.lastChanged:
            
            lastChanged = self.lastChanged
            self.lastChanged = None
            
            attrName = lastChanged[0]
            attrValue = lastChanged[1]
            gid = lastChanged[2]
            
            # Do a check to see if widget's text is the same as
            # lastChanged's text. If user closes editor but hasn't made a change,
            # don't send any data.
            if lineEditor.displayText() == attrValue:
                try:
                    params = connection.clean(attrName,  attrValue)
                    print("Params:",  params)
                    connection.send({'gid': gid, 'properties' : {params[0] : params[1]}})
                except BadDataException,  (e):
                    try:
                        print("Value entered:" + repr(attrValue))
                    except:
                        print("Value entered: could not represent value.")
                    print(e.value)
            else:
                print("No changed was made. Editor closed.")
                
        else:
            print("No change has been made since the program started.")
            
    def selectionChanged(self,  a,  b):
        
        print("SelectionChanged",  a,  b)
        
        i = self.inspectorSelectionModel.selection()
        
        i = self.inspectorProxyModel.mapSelectionToSource(i)
        
        #s = self.ui.inspector.selectedIndexes()[0]
        
        #print(s.data(0).toString())
        
        # TODO store index with Activated signal for editing?
        
        #s = self.inspectorModel.itemFromIndex(i)
        
        #print(s)
        
        #print("Data",  s)
        
        s = i.indexes()[0]
        
        #print(s)
        
        #a = s.internalPointer()
        
        #b = self.propertyModel.createIndex(0, 0, a)
        
        #c = self.propertyModel.itemFromIndex(b)
        
        #print(c)
        
        r = self.propertyModel.invisibleRootItem()
        
        r.setData(s,  Qt.Pointer)
        
        r.removeRows(0, r.rowCount())
           
        self.inspectorModel.copyAttrs(s, r)
        
#        self.propertySM.select(i,  QItemSelectionModel.SelectCurrent)
#        
#        s = self.ui.propertyView.selectedIndexes()[0]
#        
#        #TODO: find better way to collapse by deselection perhaps?
#        self.ui.propertyView.collapseAll()
#        self.ui.propertyView.setExpanded(s,  True)
#        self.ui.propertyView.scrollTo(s,  1)
        
        

    def itemChanged(self,  valueItem):
        
        return
        
        row = valueItem.row()
        parent = valueItem.parent()
        attrItem = parent.child(row)
        gidNode = self.findNode('gid',  self.model.indexFromItem(parent))[1].data()
        gid = int(gidNode.toUInt()[0])
        #print("GID:",  int(gidNode.toUInt()[0]))
        #print(valueItem.data(0).toPyObject(),  attrItem.data(0).toPyObject())
        
        self.lastChanged = (str(attrItem.data(0).toString()), str(valueItem.data(0).toString()), gid)
        
        print("Changed: " + repr(self.lastChanged))
        
    def createTree(self):

        # Set up Inspector
        self.inspectorModel.initialize(["UI Element",  "Name"],  True)
        
        #self.ui.inspector.setModel(self.inspectorModel)
        
        # Inspector Proxy Model
        self.inspectorProxyModel= QSortFilterProxyModel()
        
        self.inspectorProxyModel.setSourceModel(self.inspectorModel)
        
        self.inspectorProxyModel.setFilterRole(0)

        self.inspectorProxyModel.setFilterRegExp(QRegExp("(Group|Image|Text|Rectangle|Clone)"))
        
        self.ui.inspector.setModel(self.inspectorProxyModel)
        
        # Inspector Selection Model
        self.inspectorSelectionModel = QItemSelectionModel(self.inspectorProxyModel)
        
        self.inspectorSelectionModel.connect(self.inspectorSelectionModel, SIGNAL("selectionChanged(QItemSelection, QItemSelection)"), self.selectionChanged)

        self.ui.inspector.setSelectionMode(QAbstractItemView.SingleSelection)
        
        self.ui.inspector.setSelectionModel(self.inspectorSelectionModel)
        
        # Set up Property
        self.ui.property.setModel(self.propertyModel)
        
        self.propertyModel.initialize(["UI Element Property",  "Value"],  False)
        
        self.propertySelectionModel = QItemSelectionModel(self.propertyModel)
        
        self.ui.property.setSelectionModel(self.propertySelectionModel)

        # Property Proxy Model
        self.propertyProxyModel= QSortFilterProxyModel()
        
        self.propertyProxyModel.setSourceModel(self.propertyModel)
        
        self.propertyProxyModel.setFilterRole(0)

        self.propertyProxyModel.setFilterRegExp(QRegExp(""))
        
        self.ui.property.setModel(self.propertyProxyModel)
        
        # Property Selection Model
        
        return
        
        # propertyView
        
        #self.ui.propertyView.setItemDelegate(self.delegate)
        
        self.inspectorSelectionModel = QItemSelectionModel(self.proxyModel)
        
        self.ui.inspector.setSelectionMode(QAbstractItemView.SingleSelection)
        
        self.ui.inspector.setSelectionModel(self.inspectorSelectionModel)
        
        self.inspectorSelectionModel.connect(self.inspectorSelectionModel, SIGNAL("selectionChanged(QItemSelection, QItemSelection)"), self.selectionChanged)
        
    def refresh(self):
        self.inspectorModel.refreshRoot()
        
    def exit(self):
        sys.exit()

def main(argv):
    
    app = QApplication(argv)
    myapp = StartQT4()
    myapp.show()
    sys.exit(app.exec_())
    
if __name__ == "__main__":
    
    main(sys.argv)

