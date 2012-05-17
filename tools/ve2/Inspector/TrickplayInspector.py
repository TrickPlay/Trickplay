from PyQt4.QtGui import *
from PyQt4.QtCore import *

#import connection

#from TrickplayPropertyModel import TrickplayPropertyModel
#from TrickplayPropertyTree import TrickplayPropertyTree
from TrickplayElementModel import TrickplayElementModel
from Data import BadDataException, modelToData, summarizeSource

from PropertyIter import *#PropertyIter
from TrickplayElement import TrickplayElement
from Data import dataToModel

from UI.Inspector import Ui_TrickplayInspector



class TrickplayInspector(QWidget):
    
    def __init__(self, main = None, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
        
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayInspector()
        self.ui.setupUi(self)
        
        # Ignore signals while updating elements internally
        self.preventChanges = False

        self.main = main
        self.curLayerGid = None
        self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector :" , None, QApplication.UnicodeUTF8))
        self.layerGid = {}
        
        # Models
        self.inspectorModel = TrickplayElementModel(self)
        #self.propertyModel = TrickplayPropertyModel()
        
        self.ui.inspector.setModel(self.inspectorModel)

        #self.ui.property.setModel(self.propertyModel)

        self.setHeaders(self.inspectorModel, ['UI Element', 'Name'])
        self.ui.property.setHeaderLabels(['Property', 'Value'])
        #self.setHeaders(self.propertyModel, ['Property', 'Value'])
        
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
        QObject.connect(self.ui.property, SIGNAL("itemChanged(QTreeWidgetItem*, int)"), 
                        self.propertyItemChanged)
        """
        QObject.connect(self.ui.property, SIGNAL("itemExpanded(QTreeWidgetItem*)"), 
                        self.propertyItemExpanded)
        QObject.connect(self.ui.property, SIGNAL("itemClicked(const QTreeWidgetItem &, int)"),
                        self.propertyDataChanged)
        QObject.connect(self.ui.property, SIGNAL("itemChanged(const QTreeWidgetItem &, int)"), 
                        self.propertyDataChanged)
        QObject.connect(self.ui.property, SIGNAL("itemSelectionChanged()"), 
                        self.propertyDataChanged)
        QObject.connect(self.ui.property, 
                        SIGNAL("currentItemChanged(const QTreeWidgetItem& , const QTreeWidgetItem &)"), 
                        self.propertyDataChanged)
        """
        #QObject.connect(self.propertyModel,
                        #SIGNAL("dataChanged(const QModelIndex&,const QModelIndex&)"),
                        #self.propertyDataChanged)
        
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
        self.main._emulatorManager.getUIInfo() 
        #self.propertyModel.empty()
        
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
            #print('Found', result['gid'], result['name'])
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
    
    def propertyFill(self, data):
        self.ui.property.clear()
        self.ui.property.setColumnCount(2)
        items = []
        for p in PropertyIter(None):
            if data.has_key(str(p)) == True:
                i = QTreeWidgetItem() 
                p = str(p)
                #i.setText (0, p[:1].upper()+p[1:])
                i.setText (0, p)
                i.setText (1, str(data[str(p)]))
                if p == "source":
                    i.setText (1, summarizeSource(data[str(p)]))

                if p in NESTED_PROP_LIST: # is 'z_rotation' :
                    z = data[str(p)]
                    if type(z) ==  list :
                        idx = 0
                        for sp in PropertyIter(p):
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            j.setText (0, sp)
                            #j.setText (0, sp[:1].upper()+sp[1:])
                            j.setText (1, str(z[idx]))
                            j.setFlags(j.flags() ^Qt.ItemIsEditable)
                            idx += 1
                elif p is not "source" and p is not "gid":
                    i.setFlags(i.flags() ^Qt.ItemIsEditable)

                items.append(i)

        self.ui.property.addTopLevelItems(items)

    # "selectionChanged(QItemSelection, QItemSelection)"
    def selectionChanged(self, selected, deselected):    
        """
        Re-populate the property view every time a new UI element
        is selected in the inspector view.
        """
        if not self.preventChanges:
            self.preventChanges = True
            
            index = self.selected(self.ui.inspector)
            item = self.inspectorModel.itemFromIndex(index)
            data = item.TPJSON()
            
            if data.has_key('gid') == True:
                if data['name'][:5] == "Layer":
                    self.curLayerGid = int(data['gid'])
                    self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector : "+"Layer"+str(self.curLayerGid), None, QApplication.UnicodeUTF8))
                    #print("[VE] selectionChanged curLayerGid : ", self.curLayerGid)
                elif self.layerGid[int(data['gid'])] : 
                    self.curLayerGid = self.layerGid[int(data['gid'])] 
                    self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector : "+"Layer"+str(self.curLayerGid), None, QApplication.UnicodeUTF8))

            self.propertyFill(data)
            
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
                #if self.sendData(item['gid'], 'visible', checkState):        
                    item['is_visible'] = checkState
                    #item['visible'] = checkState
                    #self.propertyModel.fill(item.TPJSON())
            
            self.preventChanges = False
    
    # "dataChanged(const QModelIndex &, const QModelIndex &)"

    def propertyItemExpanded(self, item):
        print("propertyItemExpanded")

    def updateParentItem(self,pItem, n, value):
        #while self.ui.property.indexOfTopLevelItem(item) < 0 :
        pNewValueString = ""
        pValueString = pItem.text(1)
        pValueString = pValueString[:len(pValueString) - 1]
        pValueString = pValueString[1:]
        pValueString = pValueString.split(",")
        for i in range(0, len(pValueString)):
            if i == n :
                pValueString[i] = str(value)
                
            pNewValueString = pNewValueString + pValueString[i]
            if i < len(pValueString) - 1 :
                pNewValueString = pNewValueString+', ' 

        pItem.setText(1, '['+pNewValueString+']')

        return '{'+pNewValueString+'}'

    def getGid (self):
        g_item = self.ui.property.findItems("gid", Qt.MatchExactly, 0)
        return int(g_item[0].text(1))

    def getParentInfo(self, item):
        n = self.ui.property.indexFromItem(item).row()
        while self.ui.property.indexOfTopLevelItem(item) < 0 :
            item = self.ui.property.itemAbove(item) 
        return n, item

    def is_this_subItem(self, item):
        if self.ui.property.indexOfTopLevelItem(item) < 0 :
            return True
        else:
            return False

    def propertyItemChanged(self, item, col):
        if str(item.text(0)) in NESTED_PROP_LIST :
            return
        if self.is_this_subItem(item) is True:
            n, pItem = self.getParentInfo(item)
            tValue = self.updateParentItem(pItem, n, str(item.text(1)))
            self.sendData(self.getGid(), str(pItem.text(0)), tValue)
            #self.sendData(self.getGid(), str(pItem.text(0))+str(item.text(0)), str(item.text(1)))
        else :
            self.sendData(self.getGid(), str(item.text(0)), str(item.text(1)))

    def oopropertyDataChanged(self, topLeft, bottomRight):
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
        if not property in NESTED_PROP_LIST:
            try:    
                property, value = modelToData(property, value)
            except BadDataException, (e):
                print("Error >> Invalid data entered", e.value)
                return False

        #TODO : modelToData should be changed this way .. ? 
        #if property in ["label", "name"] : #STRING_PROP_LIST:
            #value = "'"+str(value)+"'"
        #print('Sending:', gid, property, value)
        self.main._emulatorManager.setUIInfo(gid, property, value) 
        return True
        
        #connection.send({'gid': gid, 'properties' : {property : value}})
        
    def clearTree(self):
        """
        Make sure no old data remains in the tree
        """
        old = self.preventChanges
        
        if not old:
            self.preventChanges = True
        
        self.inspectorModel.empty()
        #self.propertyModel.empty()
        
        if not old:
            self.preventChanges = False

        self.LayerGids = {}
        self.curLayerGid = None
        self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector :" , None, QApplication.UnicodeUTF8))
            
            
