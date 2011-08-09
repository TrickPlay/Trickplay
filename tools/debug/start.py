#!/usr/bin/env python

import sys
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from TreeView import Ui_MainWindow

import connection
from editor import LuaEditor
from element import Element, ROW
from model import ElementModel, pyData, modelToData, dataToModel, summarize
from data import modelToData, dataToModel, BadDataException

# Allow keyboard interrupt with ^C
signal.signal(signal.SIGINT, signal.SIG_DFL)


class StartQT4(QMainWindow):
    
    def __init__(self, parent=None):

        # Main window setup
        QWidget.__init__(self, parent)
        
        self.ui = Ui_MainWindow()
        
        self.ui.setupUi(self)
        
        # Buttons
        QObject.connect(self.ui.button_Refresh, SIGNAL("clicked()"), self.refresh)
        
        QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        
        QObject.connect(self.ui.button_Search, SIGNAL("clicked()"),  self.search)
        
        self.ui.lineEdit.setPlaceholderText("Search by GID or Name")
        
        self.createFileSystem()
        
        self.editor = LuaEditor()
        
        # Models
        self.inspectorModel = ElementModel()
        
        self.propertyModel = ElementModel()
        
        self.createTree()
         
        self.preventChanges = False
        
        QObject.connect(self.ui.rootDirPushButton, SIGNAL("clicked()"), self.setRootDir)
        
        
    def setRootDir(self):
        
        self.ui.fileSystem.setRootIndex(self.fileModel.index(self.ui.rootDirLineEdit.text()))
        
    
    """
    Set up the file system model
    """
    def createFileSystem(self):
        
        self.fileModel = QFileSystemModel()
        
        QObject.connect(self.ui.fileSystem, SIGNAL('doubleClicked( QModelIndex )'), self.openInEditor)
        
        self.ui.fileSystem.setModel(self.fileModel)
        
        p = QDir.homePath() #+ '/tp/apps'
        
        self.ui.rootDirLineEdit.setText(p)
        
        self.fileModel.setRootPath(p)
        
        self.ui.fileSystem.setRootIndex(self.fileModel.index(QDir.homePath()))
        
        header = self.ui.fileSystem.header()
        
        for i in range(1,4):
            
            header.hideSection(header.logicalIndex(i))
        
            
    def openInEditor(self, fileIndex):
        
        name = fileIndex.data(QFileSystemModel.FileNameRole)
        
        name = name.toString()
        
        path = self.fileModel.filePath(fileIndex)
        
        self.editor.setText(open(path).read())
        
        self.ui.editor.addTab(self.editor, name)
        
    """
    Search for a node by Gid or Name
    """
    def search(self):
        
        t = self.ui.lineEdit.text()
        
        r = Qt.Name
        
        #print(t)
        
        try:
        
            t = int(t)
            
            r = Qt.Gid
        
        except ValueError:
            
            pass
        
        #print(type(t),t,r)   
        
        i = self.inspectorModel.invisibleRootItem().child(0,0)
        
        row = self.inspectorModel.matchChild(t, role = r, flags = Qt.MatchRecursive, column = -1)
        
        if len(row) > 0:
            
            row = row[0]
            
            self.selectRow(row)
            
        else:
            
            print('UI Element not found')

    
    """
    Select row
    """
    def selectRow(self, row):
    
        index = row[ROW['T']].index()
            
        proxyIndex = self.inspectorProxyModel.mapFromSource(index)
        
        proxyValue = self.inspectorProxyModel.mapFromSource(row[ROW['V']].index())
        
        self.ui.inspector.scrollTo(proxyIndex, 3)
        
        self.inspectorSelectionModel.select(QItemSelection(proxyIndex, proxyValue), QItemSelectionModel.SelectCurrent)
        
    
    """
    Get current selected index
    """
    def getSelected(self):
        
        try:
        
            i = self.inspectorSelectionModel.selection()
            
            i = self.inspectorProxyModel.mapSelectionToSource(i)
            
            return i.indexes()[0]
        
        # TODO, make this better    
        except:
        
            return None


    def getSelectedGid(self):
        
        i = self.inspectorSelectionModel.selection()
        
        i = self.inspectorProxyModel.mapSelectionToSource(i)
        
        selected = i.indexes()[0]
        
        gid = 1
        
        if selected:
        
            gid = self.inspectorModel.itemFromIndex(selected).pyData(Qt.Gid)
            
        return gid
    

    """
    Re-populate the property view every time a new UI element
    is selected in the inspector view.
    """
    def selectionChanged(self,  a,  b):
        
        s = self.getSelected()
        
        self.updatePropertyList(s)
        
        
    """
    Remove and re-append the list of UI Element properties in the property view
    """
    def updatePropertyList(self, inspectorElementIndex):
        
        r = self.propertyModel.invisibleRootItem()
        
        r.setData(inspectorElementIndex,  Qt.Pointer)
        
        r.removeRows(0, r.rowCount())
    
        self.inspectorModel.copyAttrs(inspectorElementIndex, r)
        
        
    """
    Update a UI Element in the app given its gid
    """
    def sendData(self,  gid,  title,  value):
    
        try:
                    
            modelToData(title, value)
        
        except BadDataException, (e):
            
            print("BadDataException",  e.value)
            
            return False
            
        # Convert the data to proper format for sending
        title, value = modelToData(title, value)
        
        print('Sending:', gid, title, value)
        
        connection.send({'gid': gid, 'properties' : {title : value}})
        
        return True
        
        
    """
    Handle hiding/showing using the checkboxes
    """    
    def inspectorDataChanged(self, topLeft, bottomRight):
        
        if not self.preventChanges:
                        
            self.preventChanges = True
            
            item = topLeft.model().itemFromIndex(topLeft)
            
            # A change in the checkbox is a change in the title column
            if ROW['T'] == item.column():
                
                checkState = bool(item.checkState())
                
                gid = item.pyData(Qt.Gid)
                
                # After data is sent, update the model
                if self.sendData(gid, 'is_visible', checkState):
                    
                    propertyValueIndex = self.inspectorModel.findAttr(item.index(), 'is_visible')[1]
                    
                    item.model().itemFromIndex(propertyValueIndex).setData(checkState, 0)
                    
                    #row = item['is_visible']
                    
                    #row[1].setData(checkState, Qt.DisplayRole)
                    
                    self.updatePropertyList(item.index())
            
            self.preventChanges = False
        
    """
    Update Trickplay app when data is changed (by the user) in the property view
    """
    def dataChanged(self,  topLeft,  bottomRight):
        
        if not self.preventChanges:
            
            self.preventChanges = True
                
            r = self.propertyModel.invisibleRootItem()
            
            propertyValueIndex = topLeft
            
            # Get the index of the UI Element in the inspector
            inspectorElementIndex = r.data(Qt.Pointer).toPyObject()
            
            gid = pyData(inspectorElementIndex, Qt.Gid)
            
            value = pyData(propertyValueIndex, 0)
            
            title = None
            
            nested = pyData(propertyValueIndex, Qt.Nested)
            
            propertySummaryValueItem = None
            
            # If the data is nested, figure out the full name and indexes
            if (nested):
                
                parentProperty = propertyValueIndex.parent()
                
                parentPropertyTitle = r.child(parentProperty.row(), 0)
                
                propertySummaryValueItem = r.child(parentProperty.row(), 1)
                
                childPropertyTitle = propertyValueIndex.parent().child(propertyValueIndex.row(), 0)
                
                parentTitle = pyData(parentPropertyTitle, 0)
                
                childTitle = pyData(childPropertyTitle, 0)
                
                title = parentTitle + childTitle
                
                nested = (parentTitle, childTitle)
                
                m = parentPropertyTitle.model()
                
                value = m.dataStructure(m.getPair(parentPropertyTitle))[parentTitle]
                
            else:
            
                propertyTitleIndex = r.child(propertyValueIndex.row(), 0)
                
                inspectorIndexPair = self.inspectorModel.findAttr(inspectorElementIndex,  pyData(propertyTitleIndex, 0))
                
                title = pyData(propertyTitleIndex, 0)
            
            # Verify data sent OK before making any changes to model
            if self.sendData(gid, title, value):
                
                # Update the checkbox
                if "is_visible" == title:
                    
                    if value:
                        
                        value = 2
                    
                    inspectorElementIndex.model().itemFromIndex(inspectorElementIndex).setCheckState(value)
                    
                # Update the data in the inspector
                valueItem = None
                
                if not nested:
                    
                    valueItem = self.inspectorModel.itemFromIndex(inspectorIndexPair[1])
                    
                else:
                    
                    parentPair = self.inspectorModel.findAttr(inspectorElementIndex, nested[0])
                    
                    parentTitleIndex = parentPair[0]
                    
                    parentValueItem = self.inspectorModel.itemFromIndex(parentPair[1])
                    
                    parentValueItem.setData(summarize(value, nested[0]), 0)
                    
                    propertySummaryValueItem.setData(summarize(value, nested[0]), 0)
                    
                    childValueIndex = self.inspectorModel.findAttr(parentTitleIndex, nested[1])[1]
                    
                    valueItem = self.inspectorModel.itemFromIndex(childValueIndex)
                    
                    value = value[nested[1]]
                
                print("Changed item data from",  pyData(valueItem, 0))
                    
                valueItem.setData(value,  0)
                
                print("Changed item data to  ",  pyData(valueItem, 0))
                    
            self.preventChanges = False
    
    
    """
    Initialize models, proxy models, selection models, and connections
    """
    def createTree(self):

        # Set up Inspector
        self.inspectorModel.initialize(["UI Element",  "Name"],  True)
        
        self.inspectorModel.setItemPrototype(Element())

        # Inspector Proxy Model
        self.inspectorProxyModel= QSortFilterProxyModel()
        
        self.inspectorProxyModel.setSourceModel(self.inspectorModel)
        
        self.inspectorProxyModel.setFilterRole(0)

        self.inspectorProxyModel.setFilterRegExp(QRegExp("(Group|Image|Text|Rectangle|Clone|Canvas|Bitmap)"))
        
        self.ui.inspector.setModel(self.inspectorProxyModel)
        
        self.ui.inspector.header().setMovable(False)
        
        #self.ui.inspector.header().resizeSection(0, 200)
        
        # Inspector Selection Model
        self.inspectorSelectionModel = QItemSelectionModel(self.inspectorProxyModel)
        
        self.ui.inspector.setSelectionMode(QAbstractItemView.SingleSelection)
        
        self.ui.inspector.setSelectionModel(self.inspectorSelectionModel)
        
        # Set up Property
        self.ui.property.setModel(self.propertyModel)
        
        self.propertyModel.initialize(["UI Element Property",  "Value"],  False)
        
        self.ui.property.header().setMovable(False)
        
        self.propertySelectionModel = QItemSelectionModel(self.propertyModel)
        
        self.ui.property.setSelectionModel(self.propertySelectionModel)

        # Property Proxy Model
        self.propertyProxyModel= QSortFilterProxyModel()
        
        self.propertyProxyModel.setSourceModel(self.propertyModel)
        
        self.propertyProxyModel.setFilterRole(0)
        
        self.propertyProxyModel.setDynamicSortFilter(True)

        #self.propertyProxyModel.setFilterRegExp(QRegExp("(opacity|is_visible|scale|clip|anchor_point|position|x|y|z|size|h|w|source|src|tile|border_color|border_width|color|text|a|r|g|b)"))
        
        self.ui.property.setModel(self.propertyProxyModel)
        
        # Connections
        self.inspectorSelectionModel.connect(self.inspectorSelectionModel, SIGNAL("selectionChanged(QItemSelection, QItemSelection)"), self.selectionChanged)
        
        self.inspectorModel.connect(self.inspectorModel, SIGNAL("dataChanged(const QModelIndex&,const QModelIndex&)"), self.inspectorDataChanged)
        
        self.propertyModel.connect(self.propertyModel, SIGNAL("dataChanged(const QModelIndex&,const QModelIndex&)"), self.dataChanged)
        
        
    def refresh(self):
        
        self.preventChanges = True
        
        # TODO, At some point, perhaps refresh each node istead of redrawing
        # the entire tree. Not yet though, because we'll probably change
        # nodes so that they're only retreived when expanded.
        
        # self.inspectorModel.refreshRoot()
        
        gid = None
        
        try:
        
            gid = self.getSelectedGid()
        
        except IndexError:
            
            gid = 1
        
        self.inspectorModel.invisibleRootItem().removeRow(0)
        
        self.inspectorModel.initialize(None, True)
        
        row = self.inspectorModel.matchChild(gid, role = Qt.Gid, column = -1)
        
        if len(row) > 0:
        
            self.selectRow(row[0])
        
        self.preventChanges = False
        
        
    def exit(self):
        
        sys.exit()


def main(argv):
    
    try:
    
        app = QApplication(argv)
        
        myapp = StartQT4()
        
        myapp.show()
        
        sys.exit(app.exec_())
    
    except KeyboardInterrupt:
        
        pass


if __name__ == "__main__":
    
    main(sys.argv)

