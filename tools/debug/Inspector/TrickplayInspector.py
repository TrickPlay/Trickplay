from PyQt4.QtGui import *
from PyQt4.QtCore import *

import connection

from TrickplayPropertyModel import TrickplayPropertyModel
from TrickplayElementModel import TrickplayElementModel
from Data import BadDataException, modelToData

from UI.Inspector import Ui_TrickplayInspector



class TrickplayInspector(QWidget):
    
    def __init__(self, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
        
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayInspector()
        self.ui.setupUi(self)
        self.ui.refresh.setEnabled(False)
        self.ui.search.setEnabled(False)
        
        # Ignore signals while updating elements internally
        self.preventChanges = False
        
        # Searches find multiple items with the same name
        #self.lastSearchedText = None
        #self.lastSearchedItem = None
        
        # Models
        self.inspectorModel = TrickplayElementModel(self)
        self.propertyModel = TrickplayPropertyModel()
        
        self.ui.inspector.setModel(self.inspectorModel)
        self.ui.property.setModel(self.propertyModel)

        self.ui.lineEdit.setPlaceholderText("Search by GID or Name")        
        
        self.setHeaders(self.inspectorModel, ['UI Element', 'Name'])
        self.setHeaders(self.propertyModel, ['Property', 'Value'])
        
        # QTreeView selectionChanged signal doesn't seem to work here...
        # Use the selection model instead
        QObject.connect(self.ui.inspector.selectionModel(),
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
        
        QObject.connect(self.ui.refresh,
                        SIGNAL("clicked()"),
                        self.refresh)
        
        QObject.connect(self.ui.search,
                        SIGNAL("clicked()"),
                        self.userSearch)
        
        QObject.connect(self.ui.lineEdit,
                        SIGNAL('returnPressed()'),
                        self.userSearch)
        
        
    def refresh(self):
        """
        Fill the inspector with Trickplay UI element data
        """
        
        
        self.preventChanges = True
        # Reselect gid of last item selected
        gid = None
        try:
            index = self.selected(self.ui.inspector)
            item = self.inspectorModel.itemFromIndex(index)
            gid = item['gid']
        except:
            gid = 1
            
        # Get all new data
        self.inspectorModel.empty()
        self.inspectorModel.fill()
        self.propertyModel.empty()
        
        self.preventChanges = False
        
        # Find the last item after getting new data so that
        # both trees reflect the changes
        result = self.search(gid, 'gid')
        if result:
            self.selectItem(result)
                
    def setHeaders(self, model, headers):
        """
        Set headers for a given model
        """
        
        model.setHorizontalHeaderLabels(headers)
        
    def selected(self, view = None):
        """
        Return the selected index from the view given or None
        """
        
        view = view or self.ui.inspector
        
        try:
            i = view.selectionModel().selection()
            return i.indexes()[0]
            
        except:
            return None
    
    def userSearch(self):
        """
        Perform a search and select the item found
        
        TODO:
        If search is pressed multiple times with the same string, then
        search for the next item matching the search
        """
        
        text = self.ui.lineEdit.text()
        
        # Search by gid if possible, otherwise name
        property = None
        try:
            text = int(text)
            property = 'gid'
        except:
            property = 'name'
        
        #item = None
        #if self.lastSearchedText == text:
        #    item = self.lastSearchedItem
            
        result = self.search(text, property)
        
        if result:
            print('Found', result['gid'], result['name'])
            #self.lastSearchedText = text
            #self.lastSearchedItem = item
            self.selectItem(result)
        else:
            print('UI Element not found')
            
    
    def search(self, value, property, start = None):
        """
        Search for a node by one of its properties
        """
        
        return self.inspectorModel.search(property, value, start)
            
    def selectItem(self, item):
        """
        Select a row of the inspector model (as the result of a search)
        """
        
        topLeft = item.index()
        bottomRight = item.partner().index()
        
        self.ui.inspector.scrollTo(topLeft, 3)
        
        self.ui.inspector.selectionModel().select(
            QItemSelection(topLeft, bottomRight),
            QItemSelectionModel.SelectCurrent)
    
    # "selectionChanged(QItemSelection, QItemSelection)"
    def selectionChanged(self, selected, deselected):    
        """
        Re-populate the property view every time a new UI element
        is selected in the inspector view.
        """
        print (selected, deselected)
        
        if not self.preventChanges:
            
            self.preventChanges = True
            
            index = self.selected(self.ui.inspector)
            item = self.inspectorModel.itemFromIndex(index)
            data = item.TPJSON()
            
            print "-----------"
            print data
            print "-----------"
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
        Send changed properties to Trickplay device
        """
    
        try:    
            property, value = modelToData(property, value)
        
        except BadDataException, (e):
            print("Error >> Invalid data entered", e.value)
            return False
            
        print('Sending:', gid, property, value)
        
        return connection.send({'gid': gid,
                                'properties' : {property : value}})
        
    def clearTree(self):
        """
        Make sure no old data remains in the tree
        """
        
        old = self.preventChanges
        
        if not old:
            self.preventChanges = True
        
        self.inspectorModel.empty()
        self.propertyModel.empty()
        
        if not old:
            self.preventChanges = False
            
            
