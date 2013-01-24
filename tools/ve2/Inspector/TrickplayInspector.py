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
from UI.PickerItems import Ui_PickerItemTable
from UI.Neighbors import Ui_Neighbors

multiSelect = 'false'

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


class DnDTreeView(QTreeView):
    def __init__(self, parent=None, insp= None):
        super(DnDTreeView, self).__init__(parent)
        if insp :
            self.insp = insp
        self.viewport().installEventFilter(self)


    def dragMoveEvent(self, event):
        event.setDropAction(Qt.MoveAction)
        self.insp.inspectorModel.preventChanges = True
        if event.answerRect().x() < 99 : 
            event.accept()
        else :
            event.ignore()
        #print event.answerRect().y()

    def eventFilter(self, sender, event):
        #print "Event Filter"
        if event.type() == QEvent.Drop:
            dropIndex = self.indexAt(event.pos())
            the_item= self.insp.inspectorModel.itemFromIndex(dropIndex)
            if the_item.text() in ['Widget_Rectangle', "Group", "Button","ButtonPicker","ProgressBar",
            "ProgressSpinner","OrbittingDots","Slider","TextInput", "ToastAlert", "ToggleButton","Widget_Text",
            "Widget_Image"]:
                print the_item.text() , "is not a container UI"
                event.ignore()
                self.insp.inspectorModel.preventChanges = False
                return True

            if not dropIndex.parent().isValid() == True: 
                print("Drop Event Ignored ... ")
                event.ignore()
                self.insp.inspectorModel.preventChanges = False
                return True

        return False
            
        #if event.type() == QEvent.ChildRemoved:
            #print "Tree item Removed"
        #if event.type() == QEvent.dataChanged or event.type() == QEvent.selectionChanged or event.type() == QEvent.ChildRemoved:

    """
    def dropEvent(self, event):
        event.accept()
    def eventFilter(self, sender, event):
        print "Event Filter"
    def dropEvent(self, event):
        dropIndex = self.indexAt(event.pos())
        if dropIndex.parent().isValid() : 
            event.accept()

    def dragMoveEvent(self, event):
        event.setDropAction(Qt.MoveAction)
        event.accept()
        #print event.answerRect().x()
        #print event.answerRect().y()

    def dropEvent(self, event):
        dropIndex = self.indexAt(event.pos())
        if dropIndex.parent().isValid() : 
            event.accept()
    def dragEnterEvent(self, event):
        event.accept()

    def dragMoveEvent(self, event):
        #event.setDropAction(Qt.MoveAction)
        event.accept()
        print event.answerRect().x()
        print event.answerRect().y()

    def dropEvent(self, event):
        tree = event.source()
        print tree.currentIndex().row(), "*"
        print tree.currentIndex().column(), "*"
        print tree.currentIndex().child(0,0).row(), "*"
        print tree.currentIndex().child(0,0).column(), "*"
        #event.setDropAction(Qt.CopyAction)
        #event.setDropAction(Qt.MoveAction)
        #event.acceptProposedAction()

        #print "dropEvent : y ", event.pos().y()
        #event.proposedAction()
        #event.dropAction()
    """

class DnDTableWidget(QTableWidget):
    def __init__(self, parent=None, pickerTable = None):
        super(DnDTableWidget, self).__init__(parent)
        if parent :
            self.sendData = pickerTable.sendItemsData
        self.setAcceptDrops(True)
        self.setDragEnabled(True)
        
    def dragEnterEvent(self, event):
        event.accept()

    def dragMoveEvent(self, event):
        event.setDropAction(Qt.MoveAction)
        event.accept()

    def dropEvent(self, event):
        table = event.source ()
        orgItem = table.selectedItems()[0]
        orgIdx = table.indexFromItem(orgItem).row()
        newItem = table.itemAt(event.pos())
        newText = newItem.text()
        newIdx = table.indexFromItem(newItem).row()
        newItem.setText(orgItem.text())
        orgItem.setText(newText)
        table.setCurrentItem(newItem)
        self.sendData()


class SlotItem(QGraphicsRectItem):
    SIZE = 10
    def __init__(self, parent, pos, name):
        self.parent = parent
        self.name = name
        QGraphicsRectItem.__init__(self)
        self.setRect(pos.x(), pos.y(), self.SIZE, self.SIZE)
        self.setBrush(Qt.white)
        self.setAcceptHoverEvents(True)

    #def hoverEnterEvent(self, event):
    def mousePressEvent(self, event):
        if self.brush().color() != Qt.red and str(self.parent.insp.ppp[:6]) != 'screen' :
            self.parent.resetAnchorPoint()
            self.parent.sendAnchorPointSetCommand(self.name)
            self.setBrush(Qt.red)
        QGraphicsRectItem.mousePressEvent(self, event)

class DiagramScene(QGraphicsScene):
    def __init__(self, insp, data):
        QGraphicsScene.__init__(self)

        self.insp = insp
        self.gid = data['gid']
        self.curAp = data['anchor_point']
        self.curSz = data['size']
        
        self.drawAnchorPointSetter()
        self.findCurrentAnchorPoint()
        self.setCurrentAnchorPoint()

    def drawAnchorPointSetter(self):
        self.topLeft = SlotItem(self, QPointF(-200,-30), "tl")
        self.middleLeft = SlotItem(self, QPointF(-200,-15), "ml") 
        self.bottomLeft = SlotItem(self, QPointF(-200,0), "bl")

        self.topCenter = SlotItem(self, QPointF(-185,-30), "tc")
        self.middleCenter = SlotItem(self, QPointF(-185,-15), "mc") 
        self.bottomCenter = SlotItem(self, QPointF(-185,0), "bc")

        self.topRight = SlotItem(self, QPointF(-170,-30), "tr")
        self.middleRight = SlotItem(self, QPointF(-170,-15), "mr") 
        self.bottomRight = SlotItem(self, QPointF(-170,0), "br")

        self.addItem(self.topLeft)
        self.addItem(self.middleLeft)
        self.addItem(self.bottomLeft)

        self.addItem(self.topCenter)
        self.addItem(self.middleCenter)
        self.addItem(self.bottomCenter)

        self.addItem(self.topRight)
        self.addItem(self.middleRight)
        self.addItem(self.bottomRight)

        hiddenItem = SlotItem(self, QPointF(0,0), "")
        hiddenItem.hide()
        self.addItem(hiddenItem)

    def resetAnchorPoint(self):
        self.topLeft.setBrush(Qt.white)
        self.middleLeft.setBrush(Qt.white)
        self.bottomLeft.setBrush(Qt.white)

        self.topCenter.setBrush(Qt.white)
        self.middleCenter.setBrush(Qt.white)
        self.bottomCenter.setBrush(Qt.white)

        self.topRight.setBrush(Qt.white)
        self.middleRight.setBrush(Qt.white)
        self.bottomRight.setBrush(Qt.white)

    def findCurrentAnchorPoint(self):
        if self.curAp[0] < self.curSz[0]/2:
            self.h_pos = 0
        elif self.curAp[0] > self.curSz[0]/2:
            self.h_pos = 2 
        else :
            self.h_pos = 1

        if self.curAp[1] < self.curSz[1]/2:
            self.v_pos = 0
        elif self.curAp[1] > self.curSz[1]/2:
            self.v_pos = 2 
        else :
            self.v_pos = 1

    def sendAnchorPointSetCommand(self, name):
        if self.insp.editable == False :
            return
        if name == "tl" :
            anchorStr = '{0,0,0}'
        elif name == "ml" : 
            anchorStr = '{0,'+str(self.curSz[1]/2)+'}'
        elif name == "bl" : 
            anchorStr = '{0,'+str(self.curSz[1])+'}'
        elif name == "tc" : 
            anchorStr = '{'+str(self.curSz[0]/2)+',0}'
        elif name == "mc" : 
            anchorStr = '{'+str(self.curSz[0]/2)+','+str(self.curSz[1]/2)+'}'
        elif name == "bc" : 
            anchorStr = '{'+str(self.curSz[0]/2)+','+str(self.curSz[1])+'}'
        elif name == "tr" : 
            anchorStr = '{'+str(self.curSz[0])+',0}'
        elif name == "mr" : 
            anchorStr = '{'+str(self.curSz[0])+','+str(self.curSz[1]/2)+'}'
        elif name == "br" : 
            anchorStr = '{'+str(self.curSz[0])+','+str(self.curSz[1])+'}'

        self.insp.main._emulatorManager.setUIInfo(self.gid, 'anchor_point', anchorStr)

    def setCurrentAnchorPoint(self):
        if self.h_pos == 0 and self.v_pos == 0 :
            self.topLeft.setBrush(Qt.red)
        elif self.h_pos == 0 and self.v_pos == 1 :
            self.middleLeft.setBrush(Qt.red)
        elif self.h_pos == 0 and self.v_pos == 2  : 
            self.bottomLeft.setBrush(Qt.red)
        elif self.h_pos == 1 and self.v_pos == 0  : 
            self.topCenter.setBrush(Qt.red)
        elif self.h_pos == 1 and self.v_pos == 1  : 
            self.middleCenter.setBrush(Qt.red)
        elif self.h_pos == 1 and self.v_pos == 2  : 
            self.bottomCenter.setBrush(Qt.red)
        elif self.h_pos == 2 and self.v_pos == 0  : 
            self.topRight.setBrush(Qt.red)
        elif self.h_pos == 2 and self.v_pos == 1 :
            self.middleRight.setBrush(Qt.red)
        elif self.h_pos == 2 and self.v_pos == 2  : 
            self.bottomRight.setBrush(Qt.red)

        

class AnchorPointGraphicSchene(QWidget): 
    #def __init__(self, parent, gid, currentAnchor, currentSize) :
    def __init__(self, parent, data):
        QWidget.__init__(self,parent)
        
        if parent : 
            self.insp = parent

        self.scene = DiagramScene(parent, data)
        #self.scene.setCurrentAnchorPoint()

        self.view = QGraphicsView(self.scene)
        self.view.setRenderHint(QPainter.Antialiasing)
        layout = QVBoxLayout()
        layout.addWidget(self.view)
        layout.setSpacing(0)
        layout.setContentsMargins(0,0,0,0)
        self.setLayout(layout)
    
class Neighbors(QWidget):
    def __init__(self, parent, gid) :
        QWidget.__init__(self,parent)
        
        if parent :
            self.insp = parent
            self.trickplay = parent.main._emulatorManager.trickplay

        self.gid = gid
        self.ui = Ui_Neighbors()
        self.ui.setupUi(self)

        self.resize(200,100)
        self.setMinimumSize(200,100)

        QObject.connect(self.ui.upButton, SIGNAL("toggled(bool)"),  self.toggled)
        QObject.connect(self.ui.downButton, SIGNAL("toggled(bool)"),  self.toggled)
        QObject.connect(self.ui.enterButton, SIGNAL("toggled(bool)"),  self.toggled)
        QObject.connect(self.ui.rightButton, SIGNAL("toggled(bool)"),  self.toggled)
        QObject.connect(self.ui.leftButton, SIGNAL("toggled(bool)"),  self.toggled)

        #self.tbDic = {'up': self.ui.upButton, 'down': self.ui.downButton, 'enter': self.ui.enterButton, 'left': self.ui.leftButton, 'right': self.ui.rightButton,  }
        self.keyDic = {'up': 'keys.Up', 'down': 'keys.Down', 'enter': 'keys.Return', 'left': 'keys.Left', 'right': 'keys.Right'}
        self.selIconDic = {'up': self.insp.icon_up_selected, 'down': self.insp.icon_down_selected, 'enter': self.insp.icon_enter_selected, 'left': self.insp.icon_left_selected, 'right': self.insp.icon_right_selected }
        self.iconDic = {'up': self.insp.icon_up, 'down': self.insp.icon_down, 'enter': self.insp.icon_enter, 'left': self.insp.icon_left, 'right': self.insp.icon_right}

    def findCheckedButton(self):
        if self.ui.upButton.isChecked() == True :
            return self.ui.upButton
        elif self.ui.downButton.isChecked() == True :
            return self.ui.downButton
        elif self.ui.leftButton.isChecked() == True :
            return self.ui.leftButton
        elif self.ui.rightButton.isChecked() == True :
            return self.ui.rightButton
        elif self.ui.enterButton.isChecked() == True :
            return self.ui.enterButton

    def toggled(self, checked):
        #print ("toggled", checked)
        if checked == True:
            #self.tbDic(self.findCheckedButton().whatsThis()) 
            self.findCheckedButton().setEnabled(False)
            #_VE_.focusSettingMode()
            inputCmd = str("_VE_.focusSettingMode("+self.keyDic[str(self.findCheckedButton().whatsThis())]+")")
            print inputCmd
            self.trickplay.write(inputCmd+"\n")
            self.trickplay.waitForBytesWritten()
        else :
            if self.findCheckedButton():
                if self.findCheckedButton().text() != "empty":
                    self.findCheckedButton().setIcon(self.selIconDic[str(self.findCheckedButton().whatsThis())])
                else:
                    self.findCheckedButton().setText("  ")
                    self.findCheckedButton().setIcon(self.iconDic[str(self.findCheckedButton().whatsThis())])
                self.findCheckedButton().setEnabled(True)
                self.findCheckedButton().setChecked(False)
            #self.findCheckedButton().setIcon(red)

class PickerItemTable(QWidget):
    def __init__(self, parent, gid) :
        QWidget.__init__(self,parent)
        
        if parent :
            self.insp = parent

        self.gid = gid
        self.tableSet = False
        self.ui = Ui_PickerItemTable()
        self.ui.setupUi(self)
        self.ui.itemTable = DnDTableWidget(self.ui.itemTable, self)

        self.resize(200,100)
        self.setMinimumSize(200,100)

        self.ui.itemTable.setVerticalScrollMode(QAbstractItemView.ScrollPerItem)
        self.ui.itemTable.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        self.ui.itemTable.setColumnCount(1)
        
        self.ui.itemTable.horizontalHeader().setStretchLastSection(True)
        self.ui.itemTable.horizontalHeader().setVisible(False)
        self.ui.itemTable.verticalHeader().setVisible(False)
        self.ui.itemTable.setShowGrid(False)

        QObject.connect(self.ui.itemTable, SIGNAL("itemChanged(QTableWidgetItem*)"), self.pickerItemChanged)
        QObject.connect(self.ui.deleteItem, SIGNAL("pressed()"), self.deleteItemHandler)
        QObject.connect(self.ui.addItem, SIGNAL("pressed()"), self.addItemHandler)

        #self.insp.main._emulatorManager.setUIInfo(self.gid, 'items', "{'AA','BB'}") 

    def pickerItemChanged(self, item):
        if self.tableSet == True:
            self.sendItemsData()
        return 

    def sendItemsData(self):
        itemList = []
        rCnt = self.ui.itemTable.rowCount()
        for r in range(0, rCnt) : 
            item = self.ui.itemTable.item(r, 0)
            itemList.append(str(item.text()))
        value = "{'"+"', '".join(itemList)+"'}" 

        self.insp.main._emulatorManager.setUIInfo(self.gid, 'items', value)


    def getItemList(self):
        itemList = []
        rCnt = self.ui.itemTable.rowCount()
        for r in range(0, rCnt) : 
            item = self.ui.itemTable.item(r, 0)
            itemList.append(str(item.text()))
        return "{'"+"', '".join(itemList)+"'}" 

        
    def deleteItemHandler(self):
        item = self.ui.itemTable.selectedItems()
        if item :
            selectedItemIdx = self.ui.itemTable.indexFromItem(item[0])
            self.ui.itemTable.removeRow(selectedItemIdx.row())
        else :
            self.ui.itemTable.removeRow(self.ui.itemTable.rowCount() - 1)
        
        self.sendItemsData()

        #self.insp.main._emulatorManager.setUIInfo(self.gid, 'items', self.getItemList())

    def addItemHandler(self):
        idx = self.ui.itemTable.rowCount()
        self.ui.itemTable.setRowCount(idx+1)
        newitem = QTableWidgetItem()
        newitem.setText("item"+str(idx+1))
        self.ui.itemTable.setItem(0, idx, newitem)
        self.sendItemsData()

        #self.insp.main._emulatorManager.setUIInfo(self.gid, 'items', self.getItemList())
        
    def populateItemTable(self, itemList):
        
        self.tableSet = False
        idx = 0
        for iStr in itemList:
            self.ui.itemTable.setRowCount(idx + 1)
            newitem = QTableWidgetItem()
            newitem.setText(iStr)
            vh = self.ui.itemTable.verticalHeader()
            vh.setDefaultSectionSize(18)
            self.ui.itemTable.setItem(0, idx, newitem)
            idx = idx + 1
        self.tableSet = True

class TrickplayInspector(QWidget):
    
    def __init__(self, main = None, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
        
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayInspector()
        self.ui.setupUi(self)
              
        self.ui.inspector = DnDTreeView(self.ui.ObjectInspector, self)
        
        self.ui.inspector.setDragEnabled(True)
        self.ui.inspector.setDragDropMode(QAbstractItemView.InternalMove)
        self.ui.inspector.setDefaultDropAction(Qt.MoveAction)
        self.ui.inspector.setSelectionMode(QAbstractItemView.ExtendedSelection)
        self.ui.inspector.setIndentation(10)
        #self.ui.inspector.setSelectionMode(QAbstractItemView.MultiSelection)

        self.ui.gridLayout_3.addWidget(self.ui.inspector, 2, 0, 1, 1)

        # Ignore signals while updating elements internally
        self.preventChanges = False

        self.main = main
        self.curLayerName = None
        self.curLayerGid = None
        self.curItemGid = None
        #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector:" , None, QApplication.UnicodeUTF8))
        self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector:", None, QApplication.UnicodeUTF8)) 
        self.layerName = {}
        self.layerGid = {}
        self.screens = {"_AllScreens":[],"Default":[]}
        self.cbStyle_textChanged = False
        self.cbStyle = None
        self.screen_textChanged = False
        self.addItemToScreens = False
        
        # Models
        self.inspectorModel = TrickplayElementModel(self)
        self.ui.inspector.setModel(self.inspectorModel)
        self.ui.inspector.setStyleSheet("QTreeView { background: lightYellow; alternate-background-color: white; }")
        #self.ui.inspector.setRowHidden(1, self.inspectorModel.root, True)

        #ScreenInspector
        self.ui.screenCombo.addItem("Default")
        self.currentScreenName = "Default"
        self.ui.screenCombo.setStyleSheet("QComboBox{padding-top: 0px;padding-bottom:1px;font-size:12px;padding-left:10px;}")
        self.ui.deleteScreen.setStyleSheet("QComboBox{padding-top: 0px;padding-bottom:1px;}")
        QObject.connect(self.ui.deleteScreen, SIGNAL('clicked()'), self.removeScreen)
        QObject.connect(self.ui.screenCombo, SIGNAL('currentIndexChanged(int)'), self.screenChanged)
        QObject.connect(self.ui.screenCombo, SIGNAL('activated(int)'), self.screenActivated)
        QObject.connect(self.ui.screenCombo, SIGNAL('editTextChanged(const QString)'), self.screenEditTextChanged)

        #self.ui.property.setModel(self.propertyModel)

        self.setHeaders(self.inspectorModel, ['UI Element', 'Name'])
        self.ui.property.setHeaderLabels(['Property', 'Value'])
        self.ui.property.setIndentation(10)
        
        self.itemWidget = None
        self.editable = True
        self.selectedItemCount = 1

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

        #icon 
        self.icon_up = QIcon()
        self.icon_up.addPixmap(QPixmap(self.main.apath+"/Assets/up-gray.png"), QIcon.Normal, QIcon.Off)
        self.icon_up.addPixmap(QPixmap(self.main.apath+"/Assets/up-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_up_selected = QIcon()
        self.icon_up_selected.addPixmap(QPixmap(self.main.apath+"/Assets/up-red.png"), QIcon.Normal, QIcon.Off)
        self.icon_up_selected.addPixmap(QPixmap(self.main.apath+"/Assets/up-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_down = QIcon()
        self.icon_down.addPixmap(QPixmap(self.main.apath+"/Assets/down-gray.png"), QIcon.Normal, QIcon.Off)
        self.icon_down.addPixmap(QPixmap(self.main.apath+"/Assets/down-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_down_selected = QIcon()
        self.icon_down_selected.addPixmap(QPixmap(self.main.apath+"/Assets/down-red.png"), QIcon.Normal, QIcon.Off)
        self.icon_down_selected.addPixmap(QPixmap(self.main.apath+"/Assets/down-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_enter = QIcon()
        self.icon_enter.addPixmap(QPixmap(self.main.apath+"/Assets/enter-gray.png"), QIcon.Normal, QIcon.Off)
        self.icon_enter.addPixmap(QPixmap(self.main.apath+"/Assets/enter-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_enter_selected = QIcon()
        self.icon_enter_selected.addPixmap(QPixmap(self.main.apath+"/Assets/enter-red.png"), QIcon.Normal, QIcon.Off)
        self.icon_enter_selected.addPixmap(QPixmap(self.main.apath+"/Assets/enter-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_left = QIcon()
        self.icon_left.addPixmap(QPixmap(self.main.apath+"/Assets/left-gray.png"), QIcon.Normal, QIcon.Off)
        self.icon_left.addPixmap(QPixmap(self.main.apath+"/Assets/left-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_left_selected = QIcon()
        self.icon_left_selected.addPixmap(QPixmap(self.main.apath+"/Assets/left-red.png"), QIcon.Normal, QIcon.Off)
        self.icon_left_selected.addPixmap(QPixmap(self.main.apath+"/Assets/left-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_right = QIcon()
        self.icon_right.addPixmap(QPixmap(self.main.apath+"/Assets/right-gray.png"), QIcon.Normal, QIcon.Off)
        self.icon_right.addPixmap(QPixmap(self.main.apath+"/Assets/right-blue.png"), QIcon.Disabled, QIcon.Off)

        self.icon_right_selected = QIcon()
        self.icon_right_selected.addPixmap(QPixmap(self.main.apath+"/Assets/right-red.png"), QIcon.Normal, QIcon.Off)
        self.icon_right_selected.addPixmap(QPixmap(self.main.apath+"/Assets/right-blue.png"), QIcon.Disabled, QIcon.Off)



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
            self.selectItem(result, "f")
                
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
            self.selectItem(result, "f")
        else:
            print('[TrickplayInspector] UI Element not found')
            
    
    def search(self, value, property, start = None):
        """
        Search for a node by one of its properties
        """
        
        return self.inspectorModel.search(property, value, start)
            
    def clearItem(self, item):
            
        topLeft = item.index()
        bottomRight = item.partner().index()
        
        self.ui.inspector.scrollTo(topLeft, 3)
        self.ui.inspector.selectionModel().select( QItemSelection(topLeft, bottomRight), QItemSelectionModel.Clear)

    def selectItem(self, item, shift):
    #def selectItem(self, item):
        """
        Select a row of the inspector model (as the result of a search)
        """
        topLeft = item.index()
        bottomRight = item.partner().index()
        
        self.ui.inspector.scrollTo(topLeft, 3)
        
        if shift and shift == "t" :
            self.ui.inspector.selectionModel().select(
                QItemSelection(topLeft, bottomRight),
                QItemSelectionModel.Select)
        else:
            self.ui.inspector.selectionModel().select(
                QItemSelection(topLeft, bottomRight),
                QItemSelectionModel.SelectCurrent)
    
    def boolValChanged (self,state):
        print state

    def propertyFill(self, data, styleIndex=None):
        
        if str(data['name']) == 'screen':
            self.editable = False

        self.ppp = str(data['name'])

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
        items_n = 0 
        anchor_n = 0 
        skinItem = None 
        neighbors_n = 0 
        
        source_button = None

        boolCheckBox = {}
        boolNumber = {}
        boolHandlers = {}


        if data['type'] == "Tab" :
            #for p in ['gid', 'name', 'type', 'index', 'label', 'neighbors']:
            for p in ['gid', 'name', 'type', 'index', 'label']:
                if p != 'neighbors':
                    i = QTreeWidgetItem() 
                    i.setText (0, p)  # first col : property name
                    i.setText (1, str(data[p])) # second col : property value (text input field) 
                    if p == 'label' and self.editable == True:
                        i.setFlags(i.flags() ^Qt.ItemIsEditable)
                    items.append(i)
                else:
                    break

            self.ui.property.addTopLevelItems(items)
            return 
            
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
        colorValue = {}
        colorNumber = {}
        colorHandlers = {}

        def colorPropertyFill(propName, propOrder, data, gid=None) :

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
            
            pix = QPixmap(10,10)
            pix.fill(currentColor)
            icon = QIcon(pix)
            color_pushbutton.setIcon(icon)

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
                                self.main._emulatorManager.setStyleInfo(self.style_name, prop_name[0], prop_name[1], prop_name[2], colorStr)
                            else:
                                self.sendData(gid, prop_name, colorStr)
                            #color_pushbutton.setIcon(QIcon(QPixmap(10,10).fill(color)))
                            pix = QPixmap(10,10)
                            pix.fill(color)
                            icon = QIcon(pix)
                            color_pushbutton.setIcon(icon)
                        self.preventChanges = False
                return handler

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

            elif p is 'gid': 
                i = QTreeWidgetItem() 
                i.setText (0, p)  # first col : property name
                i.setText (1, str(data[p])) # second col : property value (text input field) 
                items.append(i)
                n = n + 1
                gidItem  = i

            elif data.has_key(p) == True and not (p == "items" and data["type"] == "MenuButton") : # and p is not 'gid': 
                # Text Inputs

                i = QTreeWidgetItem() 
                i.setText (0, p)  # first col : property name
                #i.setText (0, p[:1].upper()+p[1:])

                #if p in TEXT_PROP or p in READ_ONLY or p in COMBOBOX_PROP :
                if p in TEXT_PROP or p in READ_ONLY :
                    i.setText (1, str(data[p])) # second col : property value (text input field) 
                    if not  p in READ_ONLY and self.editable is True:
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
                                self.sendData((data['gid']), 'src', path)
                            self.preventChanges = False

                    source_button = QPushButton()
                    source_button.setText(str(data[p]))
                    QObject.connect(source_button, SIGNAL('clicked()'), openFileChooser)

                elif p == "items":
                    if data["type"] != "MenuButton": 
                        items_n = n
                        itemList = data[p] 

                        self.itemWidget = PickerItemTable(self, data['gid'])
                        self.itemWidget.populateItemTable(itemList)
                elif p == "neighbors":
                    neighbors_n = n 

                    self.neighbors = Neighbors(self, data['gid'])
                    
                    self.neighbors.ui.upButton.setToolButtonStyle(Qt.ToolButtonTextUnderIcon)
                    if data['neighbors'].has_key('Up') :
                        self.neighbors.ui.upButton.setIcon(self.icon_up_selected)
                        self.neighbors.ui.upButton.setText(data['neighbors']['Up'])
                    else : 
                        self.neighbors.ui.upButton.setIcon(self.icon_up)
                        #self.neighbors.ui.upButton.setFont(font)
                        #self.neighbors.ui.upButton.setEnabled(False)

                    self.neighbors.ui.downButton.setToolButtonStyle(Qt.ToolButtonTextUnderIcon)
                    if data['neighbors'].has_key('Down'):
                        self.neighbors.ui.downButton.setText(data['neighbors']['Down'])
                        self.neighbors.ui.downButton.setIcon(self.icon_down_selected)
                    else :
                        self.neighbors.ui.downButton.setIcon(self.icon_down)

                    self.neighbors.ui.enterButton.setToolButtonStyle(Qt.ToolButtonTextUnderIcon)
                    if data['neighbors'].has_key('Return'): #['Return'] :
                        self.neighbors.ui.enterButton.setText(data['neighbors']['Return'])
                        self.neighbors.ui.enterButton.setIcon(self.icon_enter_selected)
                    else :
                        self.neighbors.ui.enterButton.setIcon(self.icon_enter)

                    self.neighbors.ui.rightButton.setToolButtonStyle(Qt.ToolButtonTextUnderIcon)
                    if data['neighbors'].has_key('Right'): #['Right'] :
                        self.neighbors.ui.rightButton.setText(data['neighbors']['Right'])
                        self.neighbors.ui.rightButton.setIcon(self.icon_right_selected)
                    else :
                        self.neighbors.ui.rightButton.setIcon(self.icon_right)

                    self.neighbors.ui.leftButton.setToolButtonStyle(Qt.ToolButtonTextUnderIcon)
                    if data['neighbors'].has_key('Left'): #['Left'] :
                        self.neighbors.ui.leftButton.setText(data['neighbors']['Left'])
                        self.neighbors.ui.leftButton.setIcon(self.icon_left_selected)
                    else :
                        self.neighbors.ui.leftButton.setIcon(self.icon_left)

                elif p == "anchor_point":
                    anchor_n = n
                    #self.anchor = AnchorPointGraphicSchene(self, data['gid'], data['anchor_point'], data['size'])
                    self.anchor = AnchorPointGraphicSchene(self, data)
                elif p in BOOL_PROP:
                    boolPropertyFill(p, n, data) 
                elif p in COLOR_PROP: 
                    colorPropertyFill(p, n, data) 
                elif p in FONT_PROP:
                    fontPropertyFill(p, n, data) 
                elif p in COMBOBOX_PROP: 
                    comboPropertyFill(p, n, data) 

                if p in NESTED_PROP_LIST and not ( p == "text" and  data['type'] == "TextInput" ): 
                    z = data[p]
                    if p == "items" and data["type"] == "ButtonPicker":
                        pass
                    elif type(z) ==  list : #size, x_rotation, ... 
                        idx = 0
                        for sp in PropertyIter(p):
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            j.setText (0, sp)
                            #j.setText (0, sp[:1].upper()+sp[1:])
                            j.setText (1, str(z[idx]))
                            #if p ~= "base_size": #read_only r: 'color
                            if not p in READ_ONLY and self.editable is True :
                                j.setFlags(j.flags() ^Qt.ItemIsEditable)
                            idx += 1

                    elif not str(data["type"]) in NO_STYLE_WIDGET and self.cbStyle is not None:
                        #find Style name from combo box  
                        self.style_name = str(self.cbStyle.itemText(self.cbStyle.currentIndex()))
                        z = self.inspectorModel.styleData[0][self.style_name]
                        
                        c1 = 0 
                        for sp in PropertyIter(p): #'arrow', 'border', 'fill_colors', 'text
                            j = QTreeWidgetItem(i) 
                            sp = str(sp)
                            if sp == 'spritesheet_map' :
                                skinItem = j
                                skin_idx = 0
                                self.skinCB = QComboBox()
                                self.skinCB.addItem(z[sp])
                                sp = 'skin'

                                #QObject.connect(self.cbStyle, SIGNAL('currentIndexChanged(int)'), self.skinChanged)
                                #QObject.connect(self.cbStyle, SIGNAL('activated(int)'), self.skinActivated)
                                #QObject.connect(self.cbStyle, SIGNAL('editTextChanged(const QString)'), self.skinEditTextChanged)


                            j.setText (0, sp)
                            try : 
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
                                                colorPropertyFill(colNames, colNums, r, (data['gid'])) 
                                            else:
                                                m.setText(1,str(r[sssp]))
                                                if self.editable == True:
                                                    m.setFlags(k.flags() ^Qt.ItemIsEditable)
                                            c3 = c3 + 1
                                    else:
                                        l = QTreeWidgetItem(j)
                                        l.setText(0,ssp)
                                        colNums = [n,c1,c2]
                                        colNames = [ssp,sp,'style']
                                        if ssp in ['activation', 'default', 'focus']:
                                            colorPropertyFill(colNames, colNums, q, (data['gid'])) 
                                        elif ssp == "font":
                                            fontPropertyFill(colNames, colNums, q, (data['gid'])) 
                                        elif ssp == "alignment":
                                            comboPropertyFill(colNames, colNums, q, (data['gid'])) 
                                        elif ssp in ['justify', 'wrap']:
                                            boolPropertyFill(colNames, colNums, q, (data['gid'])) 
                                        else:
                                            l.setText(1,str(q[ssp]))
                                            if self.editable == True:
                                                l.setFlags(l.flags() ^Qt.ItemIsEditable)
                                    c2 = c2 + 1 
                                c1 = c1 + 1 
                            except:
                                pass
 

                items.append(i)
                n = n + 1

        self.ui.property.addTopLevelItems(items)
        self.ui.property.setItemHidden(gidItem, True)

        #if self.neighbors :

        if neighbors_n > 0 :
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(neighbors_n), 1, self.neighbors)

        try :
            if self.skinCB :
                self.ui.property.setItemWidget(skinItem, 1, self.skinCB)
                self.ui.property.itemWidget(skinItem,1).setStyleSheet("QComboBox{font-size:12px;padding-top:-20;padding-bottom:-20px;width:40px}")
        except:
            pass
            
        if self.anchor :
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(anchor_n), 1, self.anchor)
            self.ui.property.itemWidget(self.ui.property.topLevelItem(anchor_n),1).setStyleSheet("QWidget{ background:lightYellow;margin:-5px;padding:-12px;border-width:2px}")

        if self.itemWidget and data["type"] == "ButtonPicker":
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(items_n), 1, self.itemWidget)
        if colorPushButton :
            for n, cb in colorPushButton.iteritems() :
                if type(colorNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(colorNumber[n])), 1, cb)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(colorNumber[n])),1).setStyleSheet("QPushButton{text-align:left; padding-left:2px; padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

                else:
                    if len(colorNumber[n]) < 4:
                        self.ui.property.setItemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]), 1, cb)
                        self.ui.property.itemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]),1).setStyleSheet("QPushButton{text-align:left; padding-left:2px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                    else:
                        try :
                            self.ui.property.setItemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]).child(colorNumber[n][3]), 1, cb)
                            self.ui.property.itemWidget(self.ui.property.topLevelItem(colorNumber[n][0]).child(colorNumber[n][1]).child(colorNumber[n][2]).child(colorNumber[n][3]),1).setStyleSheet("QPushButton{text-align:left; padding-left:2px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                        except : 
                            pass
                    
        if fontPushButton :
            for n, pb in fontPushButton.iteritems() :
                if type(fontNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(fontNumber[n])), 1, pb)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(fontNumber[n])),1).setStyleSheet("QPushButton{text-align:left; padding-left:2px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                else:
                    if len(fontNumber[n]) < 4:
                        try : 
                            self.ui.property.setItemWidget(self.ui.property.topLevelItem(fontNumber[n][0]).child(fontNumber[n][1]).child(fontNumber[n][2]), 1, pb)
                            self.ui.property.itemWidget(self.ui.property.topLevelItem(fontNumber[n][0]).child(fontNumber[n][1]).child(fontNumber[n][2]),1).setStyleSheet("QPushButton{text-align:left; padding-left:2px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                        except : 
                            pass
                
        if boolCheckBox :
            for n, b in boolCheckBox.iteritems() :
                if type(boolNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(boolNumber[n])), 1, b)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(boolNumber[n])),1).setStyleSheet("QCheckBox{padding-top:-20;padding-bottom:-20px}")
                else:
                    if len(boolNumber[n]) < 4:
                        try:
                            self.ui.property.setItemWidget(self.ui.property.topLevelItem(boolNumber[n][0]).child(boolNumber[n][1]).child(boolNumber[n][2]), 1, b)
                            self.ui.property.itemWidget(self.ui.property.topLevelItem(boolNumber[n][0]).child(boolNumber[n][1]).child(boolNumber[n][2]),1).setStyleSheet("QCheckBox{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                        except:
                            pass

        if comboBox :
            for n, cb in comboBox.iteritems() :
                if type(comboNumber[n]) is not list :
                    self.ui.property.setItemWidget(self.ui.property.topLevelItem(int(comboNumber[n])), 1, cb)
                    self.ui.property.itemWidget(self.ui.property.topLevelItem(int(comboNumber[n])),1).setStyleSheet("QComboBox{font-size:12px;padding-top:-20;padding-bottom:-20px;width:40px}")
                else:
                    if len(comboNumber[n]) < 4:
                        try:
                            self.ui.property.setItemWidget(self.ui.property.topLevelItem(comboNumber[n][0]).child(comboNumber[n][1]).child(comboNumber[n][2]), 1, cb)
                            self.ui.property.itemWidget(self.ui.property.topLevelItem(comboNumber[n][0]).child(comboNumber[n][1]).child(comboNumber[n][2]),1).setStyleSheet("QComboBox{font-size:12px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")
                        except:
                            pass

        # substitude style property text input to style combo

        if source_n is not 0 : 
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(source_n), 1, source_button)
            self.ui.property.itemWidget(self.ui.property.topLevelItem(source_n),1).setStyleSheet("QPushButton{text-align:left; padding-left:2px;padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

        if style_n is not 0 : 
            self.ui.property.setItemWidget(self.ui.property.topLevelItem(style_n), 1, self.cbStyle)
            self.ui.property.itemWidget(self.ui.property.topLevelItem(style_n),1).setStyleSheet("QComboBox{padding-top: -5px;padding-bottom:-5px;font-size:12px;}")

        #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name'])+")", None, QApplication.UnicodeUTF8))

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
        #if self.has_key("cbStyle") :
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
                if theItem is not None:

                    if self.screens[self.currentScreenName].count(theLayer) > 0 and theItem.checkState() == Qt.Unchecked:
                        self.sendData(theItem['gid'], "is_visible", True)
                        theItem.setCheckState(Qt.Checked)
                    # the layer is not in this selected screen and if it is checked 
                    elif not self.screens[self.currentScreenName].count(theLayer) > 0 and theItem.checkState() == Qt.Checked:
                        self.sendData(theItem['gid'], "is_visible", False)
                        theItem.setCheckState(Qt.Unchecked)

            if theItem :
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
        
        if self.preventChanges:
            return
            
        self.selectedItemCount = 0
        selectedList = selected.indexes()
        for selIdx in selectedList : 
            selItem = self.inspectorModel.itemFromIndex(selIdx)
            try :
                self.selectedItemCount += 1
            except:
                pass
        deselectedList = deselected.indexes()
        for deselIdx in deselectedList : 
            deselItem = self.inspectorModel.itemFromIndex(deselIdx)
            try :
                self.selectedItemCount -= 1
            except:
                pass

        if self.selectedItemCount  > 1 :
            multiSelect = 'true'
        else :
            multiSelect = 'false'

        for selIdx in selectedList : 
            selItem = self.inspectorModel.itemFromIndex(selIdx)
            try :
                inputCmd = str("_VE_.selectUIElement('"+str(selItem.TPJSON()['gid'])+"',"+multiSelect+")")
                inputCmd2 = str("_VE_.selectUIElement('"+str(selItem.TPJSON()['name'])+"',"+multiSelect+")")
                print inputCmd2
                self.main._emulatorManager.trickplay.write(inputCmd+"\n")
                self.main._emulatorManager.trickplay.waitForBytesWritten()
            except:
                pass
        deselectedList = deselected.indexes()
        for deselIdx in deselectedList : 
            deselItem = self.inspectorModel.itemFromIndex(deselIdx)
            try :
                #print (str(deselItem.TPJSON()['name'])+" deselected!!!")
                inputCmd = str("_VE_.deselectUIElement('"+str(deselItem.TPJSON()['gid'])+"',"+multiSelect+")")
                inputCmd2 = str("_VE_.deselectUIElement('"+str(deselItem.TPJSON()['name'])+"',"+multiSelect+")")
                print inputCmd2
                self.main._emulatorManager.trickplay.write(inputCmd+"\n")
                self.main._emulatorManager.trickplay.waitForBytesWritten()
            except:
                pass
            
        self.ui.screenCombo.setEditable (False)


        if not self.preventChanges:
            #print "selectionChanged..................."
            self.preventChanges = True
            
            index = self.selected(self.ui.inspector)
            if index :
                item = self.inspectorModel.itemFromIndex(index)

            try : 
                if not item.TPJSON() :
                    if item.tabdata :
                        tempdata = {}
                        tempdata['gid'] = item.tabdata['gid']
                        tempdata['name'] = item.tabdata['name']
                        tempdata['label'] = item.text() 
                        tempdata['type'] = "Tab"
                        tempdata['index'] = item.tabIndex
                        #tempdata['neighbors'] = item.tabdata['tabs'][item.tabIndex]['contents']['neighbors']
                        self.propertyFill(tempdata)
                        self.editable = True
                        self.curLayerName = self.layerName[(item.tabdata['gid'])] 
                        #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(item.tabdata['name'])+") : "+item.text(), None, QApplication.UnicodeUTF8))
                        self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector: "+str(self.curLayerName)+" ("+str(item.tabdata['name'])+") : "+item.text(), None, QApplication.UnicodeUTF8))
                    self.preventChanges = False
                    return
            except:
                #self.main._emulatorManager.getUIInfo() 
                #self.main._emulatorManager.getStInfo() 

                #TODO : find/store gid to set currentIndex after tree refresh

                #theItem = self.search(theLayer, 'name')
                #self.ui.inspector.setCurrentIndex(theItem.index())
                #self.ui.inspector.setCurrentIndex(self.prev_idx)

                self.preventChanges = False
                return

            sdata = self.inspectorModel.styleData
            self.curData = item.TPJSON()
                
            if self.curData.has_key('gid') == True:
                if self.curData.has_key('name') == False:
                    #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: gid : "+str(self.curData['gid']), None, QApplication.UnicodeUTF8))
                    self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector: gid : "+str(self.curData['gid']), None, QApplication.UnicodeUTF8))
                elif self.curData['name'][:5] == "Layer":
                    self.curLayerName = self.curData['name']
                    self.curLayerGid = self.curData['gid']
                    self.curItemGid = self.curData['gid']
                    #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name'])+")", None, QApplication.UnicodeUTF8))
                    self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name'])+")", None, QApplication.UnicodeUTF8))
                elif self.layerName[(self.curData['gid'])] : 
                    self.curLayerName = self.layerName[(self.curData['gid'])] 
                    self.curLayerGid = self.layerGid[(self.curData['gid'])] 
                    self.curItemGid = self.curData['gid']

                if multiSelect == "true":
                    #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: Multi Objects Selected", None, QApplication.UnicodeUTF8))
                    self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector: Multi Objects Selected", None, QApplication.UnicodeUTF8))
                    self.ui.property.clear()
                else :
                    #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name']+")"), None, QApplication.UnicodeUTF8))
                    self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector: "+str(self.curLayerName)+" ("+str(self.curData['name']+")"), None, QApplication.UnicodeUTF8))
                    self.propertyFill(self.curData)
                    self.editable = True

            
            self.preventChanges = False
    
    # "dataChanged(const QModelIndex &, const QModelIndex &)"
    def inspectorDataChanged(self, topLeft, bottomRight):
        """
        Change UI Element visibility using checkboxes
        """     
          
        ###print "inspectorDataChanged"
        #print "inspectorDataChanged"
        #print "inspectorDataChanged"
        #print "inspectorDataChanged"

        if not self.preventChanges:
            self.preventChanges = True

            #if not topLeft.model() :
                #return 

            item = topLeft.model().itemFromIndex(topLeft)

            #if not item.isEditable() :
                #return
            
            # Only nodes in the first column have checkboxes
            if 0 == item.column():
                
                checkState = bool(item.checkState())

                if self.inspectorModel.preventChanges == True :
                    self.preventChanges = False
                    return 

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
        return (g_item[0].text(1))

    def getType (self):
        g_item = self.ui.property.findItems("type", Qt.MatchExactly, 0)
        try :
            return g_item[0].text(1)
        except:
            return 

    def getIndex (self):
        g_item = self.ui.property.findItems("index", Qt.MatchExactly, 0)
        return g_item[0].text(1)

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
            if str(item.text(0)) == "label" and self.getType() == "Tab":
                self.main._emulatorManager.setUIInfo(self.getGid(), "label",  str(item.text(1)), self.getIndex()) 
            else:
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
        #self.main.ui.InspectorDock.setWindowTitle(QApplication.translate("MainWindow", "Inspector:" , None, QApplication.UnicodeUTF8))
        self.ui.inspectorTitle.setText(QApplication.translate("TrickplayInspector", "  Inspector:" , None, QApplication.UnicodeUTF8))
            
            
