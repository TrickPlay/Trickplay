from PyQt4.QtGui import *
from PyQt4.QtCore import *
#import connection

from TrickplayElementModel import TrickplayElementModel
from Data import BadDataException, modelToData, summarizeSource
from PropertyIter import *#PropertyIter
from TrickplayElement import TrickplayElement
from Data import dataToModel
from UI.Inspector import Ui_TrickplayInspector


class MyDelegate(QItemDelegate):
    def __init__(self):
        QItemDelegate.__init__(self)
    def sizeHint(self, option, index):
        return QSize(32,15)

class MyStyle (QWidget):
    def __init__ (self, parent):
        QWidget.__init__ (self, parent)
        self.setGeometry(QtCore.QRect(0, 0, 100, 15))
        lo = QHBoxLayout()
        self._cbFoo = QComboBox()
        for x in ["ABC", "DEF", "GHI", "JKL"]:
            self._cbFoo.addItem(x)
        lo.addWidget (self._cbFoo, 3)
        self.setLayout (lo)

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
        self.curLayerName = None
        self.curLayerGid = None
        self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector:" , None, QApplication.UnicodeUTF8))
        self.layerName = {}
        self.layerGid = {}
        self.screens = {"_AllScreens":[],"Default":[]}
        self.cbStyle_textChanged = False
        self.screen_textChanged = False
        self.addItemToScreens = False
        
        # Models
        self.inspectorModel = TrickplayElementModel(self)
        self.ui.inspector.setModel(self.inspectorModel)
        self.ui.inspector.setStyleSheet("QTreeView { background: lightYellow; alternate-background-color: white; }")
        self.ui.inspector.setIndentation(10)

        #ScreenInspector
        self.ui.screenCombo.addItem("Default")
        self.currentScreenName = "Default"
        self.ui.screenCombo.setStyleSheet("QComboBox{padding-top: 0px;padding-bottom:1px;font-size:12px;}")
        self.ui.deleteScreen.setStyleSheet("QComboBox{padding-top: 0px;padding-bottom:1px;}")
        QObject.connect(self.ui.deleteScreen, SIGNAL('clicked()'), self.removeScreen)
        QObject.connect(self.ui.screenCombo, SIGNAL('currentIndexChanged(int)'), self.screenChanged)
        QObject.connect(self.ui.screenCombo, SIGNAL('activated(int)'), self.screenActivated)
        QObject.connect(self.ui.screenCombo, SIGNAL('editTextChanged(const QString)'), self.screenEditTextChanged)

        #self.ui.property.setModel(self.propertyModel)

        self.setHeaders(self.inspectorModel, ['UI Element', 'Name'])
        self.ui.property.setHeaderLabels(['Property', 'Value'])
        self.ui.property.setIndentation(10)
        
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
        QObject.connect(self.ui.property, SIGNAL("itemSelectionChanged()"), 
                        self.itemSelectionChanged)
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
        self.main._emulatorManager.getStInfo() 
        
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
    
    def propertyFill(self, data, styleIndex=None):
        
        readonly_list = ["baseline", "selected_text", "base_size", "loaded", "tags"]
        engine_widget_list = ["Widget_Text", "Widget_Rectangle", "Widget_Image", "Widget_Clone", "Widget_Group"]

        self.cbStyle_textChanged = False
        self.ui.property.clear()
        self.ui.property.setStyleSheet("QTreeWidget { background: lightYellow; alternate-background-color: white; }")
        self.ui.property.setColumnCount(2)
        items = []
        n = 0 
        style_n = 0 

        for p in PropertyIter(None):

            p = str(p)

            if str(data["type"]) in engine_widget_list and p == "style":
                pass
            elif data.has_key(p) == True:
                i = QTreeWidgetItem() 
                #i.setText (0, p[:1].upper()+p[1:])
                i.setText (0, p)
                i.setText (1, str(data[p]))
                if p == "source":
                    #i.setText (1, summarizeSource(data[p]))
                    i.setText (1, str(data[p]))
                    i.setFlags(i.flags() ^Qt.ItemIsEditable)
                if p == "style":
                        style_n = n
                        self.cbStyle = QComboBox()
                        idx = 0
                        cbStyle_idx = 0
                        for x in self.inspectorModel.styleData[0]:
                            self.cbStyle.addItem(x)
                            if x == str(data[p]):
                                cbStyle_idx = idx 
                            idx = idx + 1

                        if styleIndex is not None:
                            self.cbStyle.setCurrentIndex(styleIndex)
                        else:
                            self.cbStyle.setCurrentIndex(cbStyle_idx)
                        QObject.connect(self.cbStyle, SIGNAL('currentIndexChanged(int)'), self.styleChanged)
                        QObject.connect(self.cbStyle, SIGNAL('activated(int)'), self.styleActivated)
                        QObject.connect(self.cbStyle, SIGNAL('editTextChanged(const QString)'), self.editTextChanged)
                
                # readonly properties :: 

                #if p == "baseline" or p == "selected_text" :
                if p in readonly_list:
                    pass
                elif p == "text" and type(data[p]) is not list:
                    i.setFlags(i.flags() ^Qt.ItemIsEditable)

                elif p in NESTED_PROP_LIST: # is 'z_rotation' :
                    z = data[p]
                    if p == "items" and data["type"] == "ButtonPicker":
                        print type(z)
                        print type(z)
                        print type(z)
                        print type(z)
                        print type(z)

                    if type(z) ==  list :
                        idx = 0
                        for sp in PropertyIter(p):
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            j.setText (0, sp)
                            #j.setText (0, sp[:1].upper()+sp[1:])
                            j.setText (1, str(z[idx]))
                            #if p ~= "base_size": #read_only 
                            if not p in readonly_list :
                                j.setFlags(j.flags() ^Qt.ItemIsEditable)
                            idx += 1
                    else:
                        #find Style name from combo box  
                        self.style_name = str(self.cbStyle.itemText(self.cbStyle.currentIndex()))
                        z = self.inspectorModel.styleData[0][self.style_name]
                        for sp in PropertyIter(p):
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            j.setText (0, sp)
                            q = z[sp]
                            for ssp in PropertyIter(sp):
                                if ssp in NESTED_PROP_LIST and  ssp is not 'size':
                                    k = QTreeWidgetItem(j) 
                                    k.setText (0, ssp)
                                    r = q[ssp]
                                    for sssp in PropertyIter(ssp):
                                        m = QTreeWidgetItem(k)
                                        sssp = str(sssp)
                                        m.setText(0,sssp)
                                        m.setText(1,str(r[sssp]))
                                        m.setFlags(k.flags() ^Qt.ItemIsEditable)
                                else :
                                    l = QTreeWidgetItem(j)
                                    l.setText(0,ssp)
                                    l.setText(1,str(q[ssp]))
                                    l.setFlags(l.flags() ^Qt.ItemIsEditable)
                elif p is not "source" and p is not "gid":
                    i.setFlags(i.flags() ^Qt.ItemIsEditable)

                items.append(i)
                n = n + 1

        self.ui.property.addTopLevelItems(items)
        if style_n is not 0 : 
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(style_n), 1, self.cbStyle)
            self.ui.property.itemWidget(self.ui.property.topLevelItem(style_n),1).setStyleSheet("QComboBox{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

        self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name'])+")", None, QApplication.UnicodeUTF8))

    def screen_json(self):
        #[{"Default":["Layer1","Layer2"], "New":["Layer2"]}]
        scrJSON = '[{'
        
        n = 0 
        for scrName in self.screens:
            if n > 0 : 
                scrJSON = scrJSON + "," 
            scrJSON = scrJSON + '\"' + scrName + '\": [\"' + '\",\"'.join(self.screens[scrName]) + '\"]'
            n = n + 1

        scrJSON = scrJSON + "," + '\"' + "currentScreenName" + '\": \"'+self.currentScreenName+'\"'
        scrJSON = scrJSON + '}]'

        return scrJSON

    def itemSelectionChanged(self):
        if self.cbStyle :
            self.cbStyle.setEditable (False)

    def removeScreen(self):
        if self.currentScreenName is not "Default":
            curIdx = self.ui.screenCombo.currentIndex()
            del self.screens[self.currentScreenName]
            self.ui.screenCombo.removeItem(curIdx)
        else:
            pass 
            #TODO:Error Message ..

    def screenActivated(self, index):
        if self.screen_textChanged == True :
            self.ui.screenCombo.setEditable (False)
            self.screen_textChanged = False 
        else:
            self.old_screen_name = self.currentScreenName
            self.ui.screenCombo.setEditable (True)

    def screenEditTextChanged(self, str):
        if self.screen_textChanged == False :
            self.old_screen_name = self.currentScreenName
        self.screen_textChanged = True

    def screenChanged(self, index):
        if index < 0 or self.addItemToScreens is True:
            return
        self.screen_textChanged = True
        self.currentScreenName = str(self.ui.screenCombo.itemText(index))
        if self.screens.has_key(self.currentScreenName) == False :
            if self.old_screen_name == "":
                return
            self.screens[self.currentScreenName] = []
            for layerName in self.screens[self.old_screen_name][:]:
                self.screens[self.currentScreenName].append(layerName)
            if self.old_screen_name == "Default":
                curIdx = self.ui.screenCombo.currentIndex()
                del self.screens[self.old_screen_name]
                self.ui.screenCombo.removeItem(curIdx-1)
        else:
            # show the screen items 
            for theLayer in self.screens["_AllScreens"][:] :
                # the layer is in this selected screen and if it is not checked 
                theItem = self.search(theLayer, 'name')
                if theItem is None:
                    return

                if self.screens[self.currentScreenName].count(theLayer) > 0 and theItem.checkState() == Qt.Unchecked:
                    self.sendData(theItem['gid'], "is_visible", True)
                    theItem.setCheckState(Qt.Checked)
                # the layer is not in this selected screen and if it is checked 
                elif not self.screens[self.currentScreenName].count(theLayer) > 0 and theItem.checkState() == Qt.Checked:
                    self.sendData(theItem['gid'], "is_visible", False)
                    theItem.setCheckState(Qt.Unchecked)

            self.curLayerGid = theItem['gid'] 
            self.ui.inspector.setCurrentIndex(theItem.index())
                    
    def styleActivated(self, index):
        self.cbStyle.setEditable (True)

    def editTextChanged(self, str):
        if self.cbStyle_textChanged == False :
            self.old_name = self.style_name
        self.cbStyle_textChanged = True

    def styleChanged(self, index):
        print ("styleChanged")
        self.style_name = str(self.cbStyle.itemText(self.cbStyle.currentIndex()))
        if self.cbStyle_textChanged == True:
            self.main._emulatorManager.chgStyleName(self.getGid(), self.style_name, self.old_name) 
            self.cbStyle_textChanged = False
        else:
            self.sendData(self.getGid(), "style", self.style_name)
        self.main._emulatorManager.repStInfo() 

    def selectionChanged(self, selected, deselected):    
        """
        Re-populate the property view every time a new UI element
        is selected in the inspector view.
        """
        self.ui.screenCombo.setEditable (False)

        if not self.preventChanges:
            self.preventChanges = True
            
            index = self.selected(self.ui.inspector)
            item = self.inspectorModel.itemFromIndex(index)
            sdata = self.inspectorModel.styleData
            self.curData = item.TPJSON()
            
            if self.curData.has_key('gid') == True:
                if self.curData['name'][:5] == "Layer":
                    self.curLayerName = self.curData['name']
                    self.curLayerGid = self.curData['gid']
                    self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name'])+")", None, QApplication.UnicodeUTF8))
                elif self.layerName[int(self.curData['gid'])] : 
                    self.curLayerName = self.layerName[int(self.curData['gid'])] 
                    self.curLayerGid = self.layerGid[int(self.curData['gid'])] 
                    self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name']+")"), None, QApplication.UnicodeUTF8))

            self.propertyFill(self.curData)
            
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
                    if item['name'][:5] == "Layer":
                        if checkState == True :
                            if not self.screens[self.currentScreenName].count(item['name']) > 0 :
                                self.screens[self.currentScreenName].append(item['name'])
                        else:
                            index = 0 
                            for layerName in self.screens[self.currentScreenName][:]:
                                if layerName == item['name']:
                                    del self.screens[self.currentScreenName][index]
                                    break
                                index = index + 1 
            
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
                if str(value) == "True" : 
                    pValueString[i] =  "true"
                elif str(value) == "False" :
                    pValueString[i] =  "false"
                else:
                    pValueString[i] = str(value)
            else :
                if str(pValueString[i]) == "True" : 
                    pValueString[i] =  "true"
                elif str(pValueString[i]) == "False" :
                    pValueString[i] =  "false"
                
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

    def is_this_style(self, item):
        if self.is_this_subItem(item) is True:
            pitem = item.parent()
            style_property = []
            while pitem is not None:
                style_property.append(pitem.text(0)) 
                pitem = pitem.parent()
            
            if style_property[len(style_property)-1] == "style":
                if not item.text(0) in NESTED_PROP_LIST:
                    try:    
                        property, value = modelToData(item.text(0), item.text(1))
                    except BadDataException, (e):
                        print("Error >> Invalid data entered", e.value)
                        return True

                self.main._emulatorManager.setStyleInfo(self.style_name, item.text(0), style_property[0], style_property[1], value)
                return True
        return False
                

        
    def propertyItemChanged(self, item, col):
        
        if self.is_this_style(item) is True:
            return

        if str(item.text(0)) in NESTED_PROP_LIST and str(item.text(0)) != "text" :
            return

        if self.is_this_subItem(item) is True:
            n, pItem = self.getParentInfo(item)
            tValue = self.updateParentItem(pItem, n, str(item.text(1)))
            self.sendData(self.getGid(), str(pItem.text(0)), tValue)
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
        if not property in NESTED_PROP_LIST or property == 'style' or property == 'text':
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

        self.LayerName = {}
        self.curLayerName = None
        self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector:" , None, QApplication.UnicodeUTF8))
            
            
