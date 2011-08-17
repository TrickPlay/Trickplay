from PyQt4.QtGui import *
from PyQt4.QtCore import *

import sys

from element import Element, ROW
from model import ElementModel, pyData, modelToData, dataToModel, summarize
from data import modelToData, dataToModel, BadDataException
import connection

T = 0  # Title
V = 1  # Value
A = -1 # All

class Inspector():
    
    def __init__(self, inspectorView, propertyView):
        """
        Initialize inspector with two QTreeViews
        """
        
        # Ignore signals while updating elements internally
        self.preventChanges = False
        
        self.ui = {
            'inspector' : inspectorView,
            'property' : propertyView
        }
        
        # Models
        self.inspectorModel = ElementModel()
        self.propertyModel = ElementModel()
        
        
    def selected(self, view = None):
        """
        Return the selected index from the view given or None
        """
        
        view = view or self.ui['inspector']
        
        try:
            i = view.selectionModel().selection()
            i = view.model().mapSelectionToSource(i)
            return i.indexes()[0]
            
        except:
            return None
        
    def selectedGid(self):
        """
        Return the gid of the selected index or 1 if no index is selected
        """
        
        i = self.selected()
        
        gid = 1
        if i:
            gid = self.inspectorModel.itemFromIndex(i).pyData(Qt.Gid)
            
        return gid
    
    def search(self, text = '', model = None):
        """
        Search for a node by Gid or Name
        """
        
        model = model or self.inspectorModel
        
        # Search by gid if possible, otherwise name
        r = None
        try:
            t = int(t)
            r = Qt.Gid
        except:
            r = Qt.Name
        
        i = model.invisibleRootItem().child(0, 0)
        
        row = self.inspectorModel.matchChild(t, role = r, flags = Qt.MatchRecursive, column = -1)
        
        if len(row) > 0:
            row = row[0]
            self.selectRow(row)
            
        else:
            
            print('UI Element not found')
            
    def selectRow(self, row):
        """
        Select a row of the inspector model (as the result of a search)
        """
        
        index = row[T].index()
            
        proxyIndex = self.inspectorProxyModel.mapFromSource(index)
        
        proxyValue = self.inspectorProxyModel.mapFromSource(row[V].index())
        
        self.ui['inspector'].scrollTo(proxyIndex, 3)        
        self.inspectorSelectionModel.select(
            QItemSelection(proxyIndex, proxyValue),
            QItemSelectionModel.SelectCurrent)
        
    
    # SIGNAL
    def selectionChanged(self,  a,  b):    
        """
        Re-populate the property view every time a new UI element
        is selected in the inspector view.
        """
        
        s = self.selected()
        
        self.updatePropertyList(s)
        
    def updatePropertyList(self, inspectorElementIndex):
        """
        Remove and re-append the list of UI Element properties in the property view
        """

        r = self.propertyModel.invisibleRootItem()
        
        r.setData(inspectorElementIndex,  Qt.Pointer)
        
        r.removeRows(0, r.rowCount())
    
        self.inspectorModel.copyAttrs(inspectorElementIndex, r)

    
    def sendData(self,  gid,  title,  value):
        """
        Update a UI Element in the app given its gid
        """
    
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
    
    
    def inspectorDataChanged(self, topLeft, bottomRight):
        """
        Handle hiding/showing using the checkboxes
        """     
    
        if not self.preventChanges:
                        
            self.preventChanges = True
            
            item = topLeft.model().itemFromIndex(topLeft)
            
            # A change in the checkbox is a change in the title column
            if T == item.column():
                
                checkState = bool(item.checkState())
                
                gid = item.pyData(Qt.Gid)
                
                # After data is sent, update the model
                if self.sendData(gid, 'is_visible', checkState):
                    
                    propertyValueIndex = self.inspectorModel.findAttr(item.index(), 'is_visible')[1]
                    
                    item.model().itemFromIndex(propertyValueIndex).setData(checkState, 0)
                    
                    self.updatePropertyList(item.index())
            
            self.preventChanges = False
    
    # SIGNAL        
    def dataChanged(self,  topLeft,  bottomRight):
        """
        Update Trickplay app when data is changed (by the user) in the property view
        """
        
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
    
    
    def createTree(self):
        """
        Initialize models, proxy models, selection models, and connections
        """
        
        # Set up Inspector
        self.inspectorModel.initialize(["UI Element",  "Name"],  False)
        
        self.inspectorModel.setItemPrototype(Element())

        # Inspector Proxy Model
        self.inspectorProxyModel= QSortFilterProxyModel()
        
        self.inspectorProxyModel.setSourceModel(self.inspectorModel)
        
        self.inspectorProxyModel.setFilterRole(0)

        self.inspectorProxyModel.setFilterRegExp(QRegExp("(Group|Image|Text|Rectangle|Clone|Canvas|Bitmap)"))
        
        self.ui['inspector'].setModel(self.inspectorProxyModel)
        
        self.ui['inspector'].header().setMovable(False)
        
        #self.ui['inspector'].header().resizeSection(0, 200)
        
        # Inspector Selection Model
        self.inspectorSelectionModel = QItemSelectionModel(self.inspectorProxyModel)
        
        self.ui['inspector'].setSelectionMode(QAbstractItemView.SingleSelection)
        
        self.ui['inspector'].setSelectionModel(self.inspectorSelectionModel)
        
        # Set up Property
        self.ui['property'].setModel(self.propertyModel)
        
        self.propertyModel.initialize(["Property",  "Value"],  False)
        
        self.ui['property'].header().setMovable(False)
        
        self.propertySelectionModel = QItemSelectionModel(self.propertyModel)
        
        self.ui['property'].setSelectionModel(self.propertySelectionModel)

        # Property Proxy Model
        self.propertyProxyModel= QSortFilterProxyModel()
        
        self.propertyProxyModel.setSourceModel(self.propertyModel)
        
        self.propertyProxyModel.setFilterRole(0)
        
        self.propertyProxyModel.setDynamicSortFilter(True)

        #self.propertyProxyModel.setFilterRegExp(QRegExp("(opacity|is_visible|scale|clip|anchor_point|position|x|y|z|size|h|w|source|src|tile|border_color|border_width|color|text|a|r|g|b)"))
        
        self.ui['property'].setModel(self.propertyProxyModel)
        
        # Connections
        self.inspectorSelectionModel.connect(self.inspectorSelectionModel, SIGNAL("selectionChanged(QItemSelection, QItemSelection)"), self.selectionChanged)
        
        self.inspectorModel.connect(self.inspectorModel, SIGNAL("dataChanged(const QModelIndex&,const QModelIndex&)"), self.inspectorDataChanged)
        
        self.propertyModel.connect(self.propertyModel, SIGNAL("dataChanged(const QModelIndex&,const QModelIndex&)"), self.dataChanged)
        
        
    def refresh(self):
        """
        TODO, At some point, perhaps refresh each node istead of redrawing
        the entire tree. Not yet though, because we'll probably change
        nodes so that they're only retreived when expanded.
        """
        
        self.preventChanges = True
        
        gid = None
        try:
            gid = self.selectedGid()
        except IndexError:
            gid = 1
        
        self.clearTree()
        self.inspectorModel.initialize(None, True)

        row = self.inspectorModel.matchChild(gid, role = Qt.Gid, column = -1)
        if len(row) > 0:
            self.selectRow(row[0])
        
        self.preventChanges = False
        
    def clearTree(self):
        """
        Make sure no old data remains in the tree
        """
        
        old = self.preventChanges
        
        if not old:
            self.preventChanges = True
        
        self.inspectorModel.invisibleRootItem().removeRow(0)
        
        if not old:
            self.preventChanges = False