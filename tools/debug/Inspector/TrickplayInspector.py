from PyQt4.QtGui import *
from PyQt4.QtCore import *

import sys
import connection

from TrickplayPropertyModel import TrickplayPropertyModel
from TrickplayElementModel import TrickplayElementModel
from data import BadDataException, modelToData

Qt.Subtitle = Qt.UserRole + 2

class TrickplayInspector():
    
    def __init__(self, inspectorView, propertyView):
        """
        Initialize inspector with two QTreeViews
        """
        
        # Ignore signals while updating elements internally
        self.preventChanges = False
        
        # Views
        self.ui = {
            'inspector' : inspectorView,
            'property' : propertyView
        }
        
        # Models
        self.inspectorModel = TrickplayElementModel()
        self.propertyModel = TrickplayPropertyModel()
        
        self.ui['inspector'].setModel(self.inspectorModel)
        self.ui['property'].setModel(self.propertyModel)
        
        self.setHeaders(self.inspectorModel, ['UI Element', 'Name'])
        self.setHeaders(self.propertyModel, ['Property', 'Value'])
        
        # QTreeView selectionChanged signal doesn't seem to work here...
        # Use the selection model instead
        QObject.connect(self.ui['inspector'].selectionModel(),
                        SIGNAL('selectionChanged(QItemSelection, QItemSelection)'),
                        self.selectionChanged)
        
        # For changing checkboxes (visibility)
        QObject.connect(self.inspectorModel,
                        SIGNAL("dataChanged(const QModelIndex &, const QModelIndex &)"),
                        self.inspectorDataChanged)
        
        # For changing UI Element properties
        QObject.connect(self.propertyModel,
                        SIGNAL("dataChanged(const QModelIndex&,const QModelIndex&)"),
                        self.propertyDataChanged)
        
    def refresh(self):
        """
        Fill the inspector with Trickplay UI element data
        """
        
        self.preventChanges = True
        
        self.inspectorModel.empty()
        self.inspectorModel.fill()
        
        self.preventChanges = False
        
    def setHeaders(self, model, headers):
        """
        Set headers for a given model
        """
        
        model.setHorizontalHeaderLabels(headers)
        
    def selected(self, view = None):
        """
        Return the selected index from the view given or None
        """
        
        view = view or self.ui['inspector']
        
        try:
            i = view.selectionModel().selection()
            return i.indexes()[0]
            
        except:
            return None
    
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
    
    # "selectionChanged(QItemSelection, QItemSelection)"
    def selectionChanged(self, selected, deselected):    
        """
        Re-populate the property view every time a new UI element
        is selected in the inspector view.
        """
        
        if not self.preventChanges:
            
            self.preventChanges = True
            
            index = self.selected(self.ui['inspector'])
            item = self.inspectorModel.itemFromIndex(index)
            data = item.TPJSON()
            
            self.propertyModel.fill(data)
            
            self.preventChanges = False
    
    # "dataChanged(const QModelIndex &, const QModelIndex &)"
    def inspectorDataChanged(self, topLeft, bottomRight):
        """
        Change UI Element visibility using checkboxes
        """     
          
        if not self.preventChanges:
            
            self.preventChanges = True
            
            item = topLeft.model().itemFromIndex(topLeft)
            
            # Only nodes in the first column have checkboxes
            if 0 == item.column():
                
                checkState = bool(item.checkState())
                
                if self.sendData(item['gid'], 'is_visible', checkState):        
                    item['is_visible'] = checkState
                    self.propertyModel.fill(item.TPJSON())
            
            self.preventChanges = False
    
    # "dataChanged(const QModelIndex &, const QModelIndex &)"
    def propertyDataChanged(self, topLeft, bottomRight):
        """
        Change UI Element properties
        """
        
        if not self.preventChanges:
            
            self.preventChanges = True
            
            model = topLeft.model() 
            item = model.itemFromIndex(topLeft)
            
            gid = item['gid']
            
            # For example, if changing { 'size' : { 'w' : 100 , 'h' : 200 } },
            # then subtitle would be 'size' and title would be 'w' or 'h'
            title = model.title(item)
            subtitle = model.subtitle(item)
            
            value = model.prepareData(item)
            if self.sendData(gid, subtitle + title, value): 
                model.updateData(item)
            else:
                model.revertData(item)
                print('Error >> Unable to send data to Trickplay')
                
            self.preventChanges = False
        
    def sendData(self, gid, property, value):
        """
        Update a UI Element property
        """
    
        try:    
            property, value = modelToData(property, value)
        
        except BadDataException, (e):
            print("BadDataException",  e.value)
            return False  
            
        print('Sending:', gid, property, value)
        
        return connection.send({'gid': gid,
                                'properties' : {property : value}})

    #def refresh(self):
    #    """
    #    TODO, At some point, perhaps refresh each node istead of redrawing
    #    the entire tree. Not yet though, because we'll probably change
    #    nodes so that they're only retreived when expanded.
    #    """
    #    
    #    self.preventChanges = True
    #    
    #    gid = None
    #    try:
    #        gid = self.selectedGid()
    #    except IndexError:
    #        gid = 1
    #    
    #    self.clearTree()
    #    self.inspectorModel.initialize(None, True)
    #
    #    row = self.inspectorModel.matchChild(gid, role = Qt.Gid, column = -1)
    #    if len(row) > 0:
    #        self.selectRow(row[0])
    #    
    #    self.preventChanges = False
        
    def clearTree(self):
        """
        Make sure no old data remains in the tree
        """
        
        old = self.preventChanges
        
        if not old:
            self.preventChanges = True
        
        self.inspectorModel.empty()
        
        if not old:
            self.preventChanges = False