import re, os

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
    
    def boolValChanged (self,state):
        print state

    def propertyFill(self, data, styleIndex=None):
        
        # Clear Property Inspector 
        self.ui.property.clear()
        self.ui.property.setStyleSheet("QTreeWidget { background: lightYellow; alternate-background-color: white; }")
        self.ui.property.setColumnCount(2)

        # Init variables 
        self.cbStyle_textChanged = False
        items = []
        n = 0 
        style_n = 0 
        source_n = 0 
        
        source_button = None

        boolCheckBox = {}
        boolNumber = {}
        boolHandlers = {}


        def boolPropertyFill(propName, propOrder, data, gid=None) :
            def makeBoolHandler(gid, prop_name):
                def handler(state):
                    if not self.preventChanges:
                        self.preventChanges = True

                        if state == 2 :
                            boolVal = 'true'
                        else:
                            boolVal = 'false'

                        if type(prop_name) == list:
                            self.main._emulatorManager.setStyleInfo(self.style_name, prop_name[0], prop_name[1], prop_name[2], boolVal)
                        else :
                            self.sendData(gid, prop_name, boolVal)
                    self.preventChanges = False
                return handler
    
            bool_checkbox = QCheckBox()
            if type(propName) == list:
                boolValue = str(data[propName[0]])
            else:
                boolValue = str(data[propName]) 

            if boolValue == "True" :
                bool_checkbox.setCheckState(Qt.Checked)
            else:
                bool_checkbox.setCheckState(Qt.Unchecked)
    
            if type(propName) == list:
                strPropName = ' '.join(propName)
                boolCheckBox[strPropName] = bool_checkbox
                boolNumber[strPropName] = propOrder
                boolHandlers[strPropName] = makeBoolHandler(gid, propName)
                QObject.connect(bool_checkbox, SIGNAL('stateChanged(int)'), boolHandlers[strPropName])
            else :
                boolCheckBox[propName] = bool_checkbox
                boolNumber[propName] = propOrder
                boolHandlers[propName] = makeBoolHandler(str(data["gid"]), propName)
                QObject.connect(bool_checkbox, SIGNAL("stateChanged(int)"), boolHandlers[propName])
                
        fontPushButton = {}
        fontNumber = {}
        fontHandlers = {}
    
        def fontPropertyFill(propName, propOrder, data, gid = None) :
            def makeFontHandler(gid, defaultFont, prop_name):
                def handler():
                    if not self.preventChanges:
                        self.preventChanges = True
                        fontDialog = QFontDialog()
                        fontDialog.setCurrentFont(defaultFont)
                        font, ok = fontDialog.getFont(defaultFont)
                        if ok:
                            family = font.family()
                            size = font.pointSize()
                            fontString = "%s"%family+" %i"%size+"px"
                            if type(prop_name) == list:
                                self.main._emulatorManager.setStyleInfo(self.style_name, prop_name[0], prop_name[1], prop_name[2],"'"+fontString+"'")
                            else:
                                self.sendData(gid, prop_name, fontString)
                    self.preventChanges = False
                return handler

            if type(propName) == list:
                fontStr = str(data[propName[0]])
            else:
                fontStr = str(data[propName])
            fontSize = int(re.search('[0-9]+', fontStr).group(0))
            fontFamily =str(fontStr[:int(fontStr.find(str(fontSize))) - 1])

            # QPushButton for font setting
            font_pushbutton = QPushButton()
            # Default Font
            defaultFont = QFont()
            defaultFont.setPointSize(fontSize) 
            defaultFont.setFamily(fontFamily) 

            # Font Button
            buttonFont = QFont()
            buttonFont.setPointSize(9) 
            buttonFont.setFamily(fontFamily)
            
            font_pushbutton.setText(fontStr)
            #font_pushbutton.setFont(buttonFont)

            if type(propName) == list:
                strPropName = ' '.join(propName)
                fontHandlers[strPropName] = makeFontHandler(gid, defaultFont, propName)
                QObject.connect(font_pushbutton, SIGNAL('clicked()'), fontHandlers[strPropName])
                fontPushButton[strPropName] = font_pushbutton
                fontNumber[strPropName] = propOrder
            else:
                fontHandlers[propName] = makeFontHandler(str(data["gid"]), defaultFont, propName)
                QObject.connect(font_pushbutton, SIGNAL('clicked()'), fontHandlers[propName])
                fontPushButton[propName] = font_pushbutton
                fontNumber[propName] = propOrder
    
        colorPushButton = {}
        colorNumber = {}
        colorHandlers = {}

        def colorPropertyFill(propName, propOrder, data, gid=None) :

            def makeColorHandler(gid, currentColor, prop_name):
                def handler():
                    if not self.preventChanges:
                        self.preventChanges = True
                        colorDialog = QColorDialog()
                        colorDialog.setCurrentColor(currentColor)
                        color = colorDialog.getColor()
                        if color.isValid():
                            #color to color string needed 
                            colorStr = '{'+str(color.red())+','+str(color.green())+','+str(color.blue())+','+str(color.alpha())+'}'
                            if type(prop_name) == list:
                                self.main._emulatorManager.setStyleInfo(self.style_name, prop_name[0], prop_name[1], prop_name[2],colorStr)
                            else:
                                self.sendData(gid, prop_name, colorStr)
                    self.preventChanges = False
                return handler

            if type(propName) == list:
                colorStr = str(data[propName[0]])
            else:
                colorStr = str(data[propName])
                    
            # QPushButton for font setting
            color_pushbutton = QPushButton()
            color_pushbutton.setText(colorStr)

            # Current Color 
            colorStr = colorStr[:len(colorStr)-1]
            colorStr = colorStr[1:]
            colorStr = colorStr.replace(","," ")
            colorList = colorStr.split()

            currentColor = QColor()

            currentColor.setRed(int(colorList[0]))
            currentColor.setGreen(int(colorList[1]))
            currentColor.setBlue(int(colorList[2]))

            if len(colorList) == 4:
                currentColor.setAlpha(int(colorList[3]))
            
            if type(propName) == list:
                strPropName = ' '.join(propName)
                colorHandlers[strPropName] = makeColorHandler(gid, currentColor, propName)
                QObject.connect(color_pushbutton, SIGNAL('clicked()'), colorHandlers[strPropName])
                colorPushButton[strPropName] = color_pushbutton
                colorNumber[strPropName] = propOrder
            else :
                colorHandlers[propName] = makeColorHandler(str(data["gid"]), currentColor, propName)
                QObject.connect(color_pushbutton, SIGNAL('clicked()'), colorHandlers[propName])
                colorPushButton[propName] = color_pushbutton
                colorNumber[propName] = propOrder

        comboBox = {}
        comboNumber = {}
        comboHandlers = {}

        def comboPropertyFill(propName, propOrder, data, gid=None) :
            # QComboBox 
            comboProp = QComboBox()

            def makeComboHandler(gid, combo, prop_name):
                def handler(index):
                    currentPropVal = str(combo.itemText(combo.currentIndex()))                    
                    if not self.preventChanges:
                        self.preventChanges = True
                        if type(prop_name) == list:
                            self.main._emulatorManager.setStyleInfo(self.style_name, prop_name[0], prop_name[1], prop_name[2], '"'+currentPropVal+'"')
                        else:
                            self.sendData(gid, prop_name, currentPropVal)
                    self.preventChanges = False
                    comboProp.setEditable(False)
                return handler

            def comboActivated(index):
                comboProp.setEditable (True)

            idx = 0 
            current_idx = 0
            if type(propName) == list:
                comboValue = str(data[propName[0]])
                pname = propName[0]
            else:
                comboValue = str(data[propName])
                pname = propName

            if pname == "source":
                #comboProp.setEditable(True)
                if len(self.main._emulatorManager.clonelist) > 0 :
                    clone_idx = 0
                    for i in self.main._emulatorManager.clonelist:
                        if i == str(data['name']):
                            del self.main._emulatorManager.clonelist[clone_idx]
                        clone_idx = clone_idx + 1
                                
                    COMBOBOX_PROP_VALS[pname] = self.main._emulatorManager.clonelist
                else:
                    pass
            
            for i in COMBOBOX_PROP_VALS[pname]:
                if pname == 'direction':
                    idx = 0
                    for j in COMBOBOX_PROP_VALS[pname][str(data['type'])]:
                        comboProp.addItem(j)
                        if j == comboValue:
                            current_idx = idx
                        idx = idx + 1
                    break
                else:
                    comboProp.addItem(i)
                    if i == comboValue:
                        current_idx = idx
                idx = idx + 1

            comboProp.setCurrentIndex(current_idx)

            #QObject.connect(self.cbStyle, SIGNAL('currentIndexChanged(int)'), self.styleChanged)
            #QObject.connect(self.cbStyle, SIGNAL('activated(int)'), self.styleActivated)
            #QObject.connect(self.cbStyle, SIGNAL('editTextChanged(const QString)'), self.editTextChanged)

            if type(propName) == list:
                strPropName = ' '.join(propName)
                comboBox[strPropName] = comboProp
                comboNumber[strPropName] = propOrder
                comboHandlers[strPropName] = makeComboHandler(gid, comboProp, propName)
                QObject.connect(comboProp, SIGNAL('currentIndexChanged(int)'), comboHandlers[strPropName])
            else :
                comboBox[propName] = comboProp
                comboNumber[propName] = propOrder
                comboHandlers[propName] = makeComboHandler(str(data["gid"]), comboProp, propName)
                QObject.connect(comboProp, SIGNAL('currentIndexChanged(int)'), comboHandlers[propName])

            QObject.connect(comboProp, SIGNAL('activated(int)'), comboActivated)

        for p in PropertyIter(None):

            p = str(p)

            # skip style item creation 
            if str(data["type"]) in NO_STYLE_WIDGET and p == "style" :
                pass

            elif data.has_key(p) == True:

                # Text Inputs

                i = QTreeWidgetItem() 

                i.setText (0, p)  # first col : property name
                #i.setText (0, p[:1].upper()+p[1:])

                #if p in TEXT_PROP or p in READ_ONLY or p in COMBOBOX_PROP :
                if p in TEXT_PROP or p in READ_ONLY :
                    i.setText (1, str(data[p])) # second col : property value (text input field) 
                    if not  p in READ_ONLY :
                        i.setFlags(i.flags() ^Qt.ItemIsEditable)

                if p in READ_ONLY:
                    pass

                elif p == "style": 
                        style_n = n
                        idx = 0
                        cbStyle_idx = 0
                        self.cbStyle = QComboBox()
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

                elif p == "source":
                    layers =  "','".join (self.screens[self.currentScreenName])
                    layers = "{'"+layers+"'}"
                    inputCmd = str("_VE_.printInstanceName("+layers+")")
                    self.main._emulatorManager.trickplay.write(inputCmd+"\n")
                    self.main._emulatorManager.trickplay.waitForBytesWritten()
                    comboPropertyFill(p, n, data)

                elif p == "src":
                    source_n = n
                    def openFileChooser():
                        if not self.preventChanges:
                            self.preventChanges = True
                            path = QFileDialog.getOpenFileName(None, 'Set Image Source', str(os.path.join(self.main.path, 'assets/images')), "*.jpg *.gif *.png")
                            if len(path) > 0 :
                                path = os.path.basename(str(path))
                                self.sendData(int(data['gid']), 'src', path)
                            self.preventChanges = False

                    source_button = QPushButton()
                    source_button.setText(str(data[p]))
                    QObject.connect(source_button, SIGNAL('clicked()'), openFileChooser)
                elif p in BOOL_PROP:
                    boolPropertyFill(p, n, data) 
                elif p in COLOR_PROP: 
                    colorPropertyFill(p, n, data) 
                elif p in FONT_PROP:
                    fontPropertyFill(p, n, data) 
                elif p in COMBOBOX_PROP: 
                    comboPropertyFill(p, n, data) 
                    

                if p in NESTED_PROP_LIST: 
                    z = data[p]
                    """
                    if p == "items" and data["type"] == "ButtonPicker":
                        print type(z)
                        print type(z)
                        print type(z)
                    """
                    if type(z) ==  list : #size, x_rotation, ... 
                        idx = 0
                        for sp in PropertyIter(p):
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            j.setText (0, sp)
                            #j.setText (0, sp[:1].upper()+sp[1:])
                            j.setText (1, str(z[idx]))
                            #if p ~= "base_size": #read_only 
                            if not p in READ_ONLY :
                                j.setFlags(j.flags() ^Qt.ItemIsEditable)
                            idx += 1
                    elif not str(data["type"]) in NO_STYLE_WIDGET :
                        #find Style name from combo box  
                        self.style_name = str(self.cbStyle.itemText(self.cbStyle.currentIndex()))
                        z = self.inspectorModel.styleData[0][self.style_name]
                        
                        c1 = 0 
                        for sp in PropertyIter(p): #'arrow', 'border', 'fill_colors', 'text
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            j.setText (0, sp)
                            q = z[sp]
                            c2 = 0 
                            for ssp in PropertyIter(sp): #colors, corner_radius, width, alignment, font, justify, wrap, x-yoffset
                                if ssp in NESTED_PROP_LIST and  ssp is not 'size':
                                    k = QTreeWidgetItem(j) 
                                    k.setText (0, ssp)
                                    r = q[ssp]
                                    c3 = 0
                                    for sssp in PropertyIter(ssp): #activation, default, focus 
                                        m = QTreeWidgetItem(k)
                                        sssp = str(sssp)
                                        m.setText(0,sssp)
                                        if sssp in ['activation', 'default', 'focus']:
                                            colNums = [n,c1,c2,c3]
                                            colNames = [sssp, ssp, sp, 'style']
                                            colorPropertyFill(colNames, colNums, r, int(data['gid'])) 
                                        else:
                                            m.setText(1,str(r[sssp]))
                                            m.setFlags(k.flags() ^Qt.ItemIsEditable)
                                        c3 = c3 + 1
                                else:
                                    l = QTreeWidgetItem(j)
                                    l.setText(0,ssp)
                                    colNums = [n,c1,c2]
                                    colNames = [ssp,sp,'style']
                                    if ssp in ['activation', 'default', 'focus']:
                                        colorPropertyFill(colNames, colNums, q, int(data['gid'])) 
                                    elif ssp == "font":
                                        fontPropertyFill(colNames, colNums, q, int(data['gid'])) 
                                    elif ssp == "alignment":
                                        comboPropertyFill(colNames, colNums, q, int(data['gid'])) 
                                    elif ssp in ['justify', 'wrap']:
                                        boolPropertyFill(colNames, colNums, q, int(data['gid'])) 
                                    else:
                                        l.setText(1,str(q[ssp]))
                                        l.setFlags(l.flags() ^Qt.ItemIsEditable)
                                c2 = c2 + 1 
                            c1 = c1 + 1 

                items.append(i)
                n = n + 1

        self.ui.property.addTopLevelItems(items)

        if colorPushButton :
            for n, cb in colorPushButton.iteritems() :
                if type(colorNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(colorNumber[n])), 1, cb)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(colorNumber[n])),1).setStyleSheet("QPushButton{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                else:
                    if len(colorNumber[n]) < 4:
                        self.ui.property.setItemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]), 1, cb)
                        self.ui.property.itemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]),1).setStyleSheet("QPushButton{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                    else:
                        self.ui.property.setItemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]).child(colorNumber[n][3]), 1, cb)
                        self.ui.property.itemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]).child(colorNumber[n][3]),1).setStyleSheet("QPushButton{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                    

        if fontPushButton :
            for n, pb in fontPushButton.iteritems() :
                if type(fontNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(fontNumber[n])), 1, pb)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(fontNumber[n])),1).setStyleSheet("QPushButton{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                else:
                    if len(fontNumber[n]) < 4:
                        self.ui.property.setItemWidget(self.ui.property.topLevelItem(fontNumber[n][0]).child(fontNumber[n][1]).child(fontNumber[n][2]), 1, pb)
                        self.ui.property.itemWidget(self.ui.property.topLevelItem(fontNumber[n][0]).child(fontNumber[n][1]).child(fontNumber[n][2]),1).setStyleSheet("QPushButton{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                
        if boolCheckBox :
            for n, b in boolCheckBox.iteritems() :
                if type(boolNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(boolNumber[n])), 1, b)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(boolNumber[n])),1).setStyleSheet("QCheckBox{padding-top:-20;padding-bottom:-20px}")
                else:
                    if len(boolNumber[n]) < 4:
                        self.ui.property.setItemWidget(self.ui.property.topLevelItem(boolNumber[n][0]).child(boolNumber[n][1]).child(boolNumber[n][2]), 1, b)
                        self.ui.property.itemWidget(self.ui.property.topLevelItem(boolNumber[n][0]).child(boolNumber[n][1]).child(boolNumber[n][2]),1).setStyleSheet("QCheckBox{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

        if comboBox :
            for n, cb in comboBox.iteritems() :
                if type(comboNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(comboNumber[n])), 1, cb)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(comboNumber[n])),1).setStyleSheet("QComboBox{font-size:12px;padding-top:-20;padding-bottom:-20px}")
                else:
                    if len(comboNumber[n]) < 4:
                        self.ui.property.setItemWidget(self.ui.property.topLevelItem(comboNumber[n][0]).child(comboNumber[n][1]).child(comboNumber[n][2]), 1, cb)
                        self.ui.property.itemWidget(self.ui.property.topLevelItem(comboNumber[n][0]).child(comboNumber[n][1]).child(comboNumber[n][2]),1).setStyleSheet("QComboBox{font-size:12px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

        # substitude style property text input to style combo

        if source_n is not 0 : 
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(source_n), 1, source_button)
            self.ui.property.itemWidget(self.ui.property.topLevelItem(source_n),1).setStyleSheet("QPushButton{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

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

    def handle_style(self, item):
        if self.is_this_subItem(item) is True: #if it is Style 
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

                #print(self.style_name, item.text(0), style_property[0], style_property[1], value)
                #('Default', PyQt4.QtCore.QString(u'corner_radius'), PyQt4.QtCore.QString(u'border'), PyQt4.QtCore.QString(u'style'), 5.0)
                self.main._emulatorManager.setStyleInfo(self.style_name, item.text(0), style_property[0], style_property[1], value)
                return True
        return False
                

        
    def propertyItemChanged(self, item, col):
        
        if self.handle_style(item) is True:
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
            
            
