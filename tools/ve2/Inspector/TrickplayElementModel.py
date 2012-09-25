from copy import deepcopy
from PyQt4.QtCore import *
from PyQt4.QtGui import *

from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply
from TrickplayElement import TrickplayElement
#from connection import *

class TrickplayElementModel(QStandardItemModel):
    
    def __init__(self, inspector, parent=None):
        QWidget.__init__(self, parent)
        self.inspector = inspector
        self.manager = QNetworkAccessManager()
        self.reply = None
        self.theBigestGid = None
        self.styleData = None
        self.preventChanges = False
        self.newChildGid = None
        self.newParentGid = None
        self.lmRow = "nil"
        self.lmCol = "nil"
        self.lmChild = "false"
        self.lmParentGid = "nil"
        self.tabIndex = "nil"

        QObject.connect(self, SIGNAL("rowsRemoved(const QModelIndex&, int, int)"), self.rr)
        QObject.connect(self, SIGNAL("rowsInserted (const QModelIndex&, int, int)"), self.ri)
        QObject.connect(self, SIGNAL("rowsAboutToBeRemoved(const QModelIndex&, int, int)"), self.rar)
        QObject.connect(self, SIGNAL("rowsAboutToBeInserted (const QModelIndex&, int, int)"), self.rai)

    def rai(self, idx, i , j):
        #print "rowsAboutInserted", i, j  #  at this level -- > it is going to be future parent's i==j th content 
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            the_item= self.itemFromIndex(idx)
            if the_item : 
                try:
                    self.newParentGid = the_item['gid']
                    print ("newParentGid", self.newParentGid)
                    if self.newParentGid == None and the_item.parent()['type'] == "LayoutManager" :
                        #print ("LayoutManager")
                        if the_item.text()[:3] == "Row" : #Drop into Row 
                            self.lmRow = int(the_item.text()[3:])
                            for x in range(0, the_item.rowCount()):
                                temp_item = the_item.takeChild(x)
                                print temp_item.text()
                                if temp_item.text() == "Empty" :
                                    self.lmCol = int( x ) 
                                    break
                            if self.lmCol == "nil" :
                                self.lmCol = int( the_item.rowCount() )
                            print "[", self.lmRow, self.lmCol ,"]"
                            self.newParentGid = the_item.parent()['gid'] #LayoutManager
                        else : #Drop into Empty Cell 
                            self.lmCol = int(the_item.row()) # layout manager col number 
                            self.lmRow = int(the_item.parent().text()[3:])
                            print "[", self.lmRow, self.lmCol ,"]"
                            self.newParentGid = the_item.parent().parent()['gid'] #LayoutManager
                    elif the_item.parent()['type'] == "TabBar" :
                        #print("TabBar")
                        self.tabIndex = the_item.row() + 1
                        self.newParentGid = the_item.parent()['gid']
                except:
                    self.newParentGid = None
                    print ("merong : newParentGid nil")
        #pass

    def ri(self, idx, i , j):
        #idx is parent's idx 
        #print "rowsInserted", i, j #  at this level -- > it is going to be future parent's i==j th content 
        pass
        """
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            the_item= self.itemFromIndex(idx)
            if the_item : 
                try:
                    self.newParentGid = the_item['gid']
                except:
                    
        """
        #print the_item['gid'], "inserted"
        #print the_item['gid'], "newParent"

    def rar(self, idx, i , j):
        #print "rowsAboutRemoved", i,j 
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            the_item= self.itemFromIndex(idx)
            if the_item :
                the_child_item = the_item.takeChild(i)

                # child's parent 
                if the_item['type'] == "MenuButton" :
                    self.lmChild = "true"
                    self.lmParentGid = the_item['gid']
                if the_item.parent() :
                    pType = the_item.parent()['type']
                    pGid = the_item.parent()['gid']

                    if pType == "LayoutManager":
                        self.lmChild = "true"
                        self.lmParentGid = pGid

                if the_child_item : 
                    try:
                        self.newChildGid = the_child_item['gid']
                        print("newChildGid", self.newChildGid)
                    except:
                        self.newChildGid = None
                        print ("merong : newChildGid nil")


    def rr(self, idx, i , j):
        #print "rowsRemoved"
        #self.preventChanges = False
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            the_item= self.itemFromIndex(idx)
            if self.newChildGid and self.newParentGid :
                if self.tabIndex is not "nil" :
                    inputCmd = str("_VE_.contentMove("+str(self.newChildGid)+","+str(self.newParentGid)+","+str(self.tabIndex)+","+str(self.lmCol)+","+self.lmChild+","+str(self.lmParentGid)+")") 
                else:
                    inputCmd = str("_VE_.contentMove("+str(self.newChildGid)+","+str(self.newParentGid)+","+str(self.lmRow)+","+str(self.lmCol)+","+self.lmChild+","+str(self.lmParentGid)+")") 
                print inputCmd
                self.inspector.main._emulatorManager.trickplay.write(inputCmd+"\n")
                self.inspector.main._emulatorManager.trickplay.waitForBytesWritten()
            else:
                print ("newChildGid or newParentGid is nil ...")

            self.lmChild = "false"
            self.lmRow = "nil"
            self.lmCol = "nil"
            self.tabIndex = "nil"
            self.lmParentGid = "nil"
            
    """
    #---------------------------------------------------------------------------
    #def supportedDropActions(self): 
        #return Qt.MoveAction 
    #---------------------------------------------------------------------------
    def mimeTypes(self):
        types = QStringList() 
        types.append('text/plain') 
        return types 

    def mimeData(self, index): 
        rc = ""
        theIndex = index[1] #<- for testing purposes we only deal with 1st item
        while theIndex.isValid():
            rc = rc + str(theIndex.row()) + ";" + str(theIndex.column())
            theIndex = self.parent(theIndex)
            if theIndex.isValid():
                rc = rc + ","
        mimeData = QMimeData()
        mimeData.setText(rc)
        return mimeData

    def nodeFromIndex(self, index):        
    ##return index.internalPointer() if index.isValid() else self.root        
        return index.model() if index.isValid() else self.parent()

    def dropMimeData(self, data, action, row, column, parentIndex):
       if action == Qt.IgnoreAction:
           return True
    
       print self.itemFromIndex(parentIndex).text() #Layer0
       print self.itemFromIndex(parentIndex).row() #0
       print self.itemFromIndex(parentIndex).column() #0 

       if data.hasText():
            ancestorL = str(data.text()).split(",") 
            ancestorL.reverse() #<- stored from the child up, we read from ancestor down
            print ancestorL
            pIndex = QModelIndex()
            for ancestor in ancestorL:
                srcRow = int(ancestor.split(";")[0])
                srcCol = int(ancestor.split(";")[1])
                itemIndex = self.index(srcRow, srcCol, pIndex)
                print self.itemFromIndex(itemIndex).text()
                pIndex = itemIndex

       dragNode = self.nodeFromIndex(pIndex)
       #parentNode = self.nodeFromIndex(parentIndex)
       newNode = deepcopy(dragNode)

       #newNode.setParent(parentNode)
       #self.insertRow(len(parentNode)-1, newNode)
       #self.insertRow(len(parentNode)-1, parentIndex)
       self.removeRow(row, parentIndex)
       return True
>>>>>>>>>>>>>>>>
        self.beginInsertRows(parentIndex, row-1, row)
        print parentIndex, row-1, row
        self.beginInsertRows(parentIndex, row-1, row)

       dragNode = mimedata.instance()
       parentNode = self.nodeFromIndex(parentIndex)

       # make a copy of the node being moved
       newNode = deepcopy(dragNode)
       newNode.setParent(parentNode)
       self.insertRow(len(parentNode)-1, parentIndex)
       self.emit(SIGNAL("dataChanged(QModelIndex,QModelIndex)"), parentIndex, parentIndex) 
       if (mimedata.hasFormat('compass/x-ets-qt4-instance')):
           self.removeRow(row, parentIndex)

    #---------------------------------------------------------------------------
    def insertRow(self, row, parent): 
        print "insertRow"
        return self.insertRows(row, 1, parent) 


    #---------------------------------------------------------------------------
    def insertRows(self, row, count, parent): 
        print "insertRows"
        self.beginInsertRows(parent, row, (row + (count - 1))) 
        self.endInsertRows() 
        return True 


    #---------------------------------------------------------------------------
    def removeRow(self, row, parentIndex): 
        print "removeRow"
        return self.removeRows(row, 1, parentIndex) 


    #---------------------------------------------------------------------------
    def removeRows(self, row, count, parentIndex): 
        self.beginRemoveRows(parentIndex, row, row) 
        #print "about to remove child at row:",row
        #print "which is under the parent named:",parentIndex.internalPointer().get_name()
        #print "and whose own name is:",parentIndex.internalPointer().get_child_at_row(row).get_name()
        #parentIndex.internalPointer().remove_child_at_row(row)
        self.endRemoveRows() 
        return True 

    """

    def inspector_reply_finished(self, pdata=None, sdata=None):
        if pdata is not None :
            root = self.invisibleRootItem()
            child = None
            pdata = pdata[0]
            self.styleData = sdata

            for c in pdata["children"]:
                if c["name"] == "screen":
                    child = c
                    break
                
            if child is None:
                print( "Could not find screen element." )
            else:
                self.tpData = pdata
                self.theBigestGid = 2
                self.insertElement(root, child, pdata, True)

            self.inspector.ui.inspector.expandAll()

            gid = None

            try:
                index = self.inspector.selected(self.ui.inspector)
                item = self.itemFromIndex(index)
                gid = item['gid']
            except:
                gid = 2

            # Find the last item after getting new data so that
            # both trees reflect the changes
            if self.inspector.main.command == "newLayer" or self.inspector.main.command == "insertUIElement" :
                result = self.inspector.search(self.theBigestGid , 'gid')
                if result: 
                    self.inspector.selectItem(result)
                else:
                    print("UI Element not found")
                self.inspector.main.command == ""
            else:
                result = self.inspector.search(gid, 'gid')
                if result:
                    self.inspector.selectItem(result)
    
            if not self.inspector.ui.screenCombo.findText(self.inspector.currentScreenName) < 0 :
                self.inspector.ui.screenCombo.setCurrentIndex( self.inspector.ui.screenCombo.findText(self.inspector.currentScreenName))                
            return


    def fill(self):
        """
        Get UI data from Trickplay and fill the tree with it.
        If no data is available, do nothing.
        """
        self.tpData = None
        self.getInspectorData()
            
    def insertElement(self, parent, data, parentData, screen):
        """
        Recursively add UI Elements to the tree
        """

        """
        Parent is the parent node
        
        Data is the property data for this node
        ParentData is a reference to the dictionary containing data
        """
        
        if data is None:
            return

        try:
            value = data["name"]
        except:
            value = ""

        title = data["type"]
        gid = data['gid']

        if value[:5] == "Layer":
            title = value
            value = ""
            self.inspector.curLayerName = title
            self.inspector.curLayerGid = data['gid']

            if not self.inspector.screens["_AllScreens"].count(title) > 0:
                self.inspector.screens["_AllScreens"].append(title)
                if self.inspector.currentScreenName is not None:
                    if not self.inspector.screens[self.inspector.currentScreenName].count(title) > 0:
                        self.inspector.screens[self.inspector.currentScreenName].append(title)

        else:
            self.inspector.layerName[int(gid)] = self.inspector.curLayerName
            self.inspector.layerGid[int(gid)] = self.inspector.curLayerGid

        if gid > self.theBigestGid:
            self.theBigestGid = gid 

        if "Texture" == title:
            title = "Image"
            
        # Set the name node to gid + name
        if '' != value:   
            gs = str(gid)
            l = len(gs)
            value =  gs + ' ' * 2 * (6 - l) + value 
        else:    
            value = str(gid)
        
        node = TrickplayElement(title)
        self.node = node
        node.setTPJSON(data)
        node.setTPParent(parentData)
        node.setFlags(node.flags() ^ Qt.ItemIsEditable)

        # Add a checkbox for everything but screen
        if not screen:
            
            node.setCheckable(True)
            
            checkState = Qt.Unchecked
            if data['is_visible']:
                checkState = Qt.Checked

            node.setCheckState(checkState)
        
        # Screen has no is_visible property because changing it
        # causes problems with key presses in the app
        else:    
            del(data['is_visible'])
        
        partner = node.partner()
        partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
        partner.setData(value, Qt.DisplayRole)
        
        parent.appendRow([node, partner])
        
        # Recurse through tabs
        try:
            tabs = data['tabs']
            for r in range (0, len(tabs)) :
                #tempnode = TrickplayElement("Tab"+str(r))
                tempnode = TrickplayElement(tabs[r]['label'])
                tempnode.tabdata = data
                tempnode.tabIndex = r + 1
                #self.node = tempnode
                tempnode.setFlags(tempnode.flags() ^ Qt.ItemIsEditable)
                partner = tempnode.partner()
                partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
                partner.setData("", Qt.DisplayRole)
                node.appendRow([tempnode, partner])
                #print r, (tabs[r]['contents'][1])
                for c in range (0, len(tabs[r]['contents']['children'])) :
                    self.insertElement(tempnode, tabs[r]['contents']['children'][c], data, False)

        # Element has no tabs
        except KeyError:
            pass

        # Recurse through cells
        try:
            cells = data['cells']
            #print ("Rows:", len(cells))
            #print ("Cols:", len(cells[0]))
            for r in range (0, len(cells)) :
                tempnode = TrickplayElement("Row"+str(r))
                #self.node = tempnode
                tempnode.setFlags(tempnode.flags() ^ Qt.ItemIsEditable)
                partner = tempnode.partner()
                partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
                partner.setData("", Qt.DisplayRole)
                node.appendRow([tempnode, partner])
                for c in range (0, len(cells[0])) :
                    if type(cells[r][c]) == dict:
                        self.insertElement(tempnode, cells[r][c], data, False)
                    else:
                        emptynode = TrickplayElement("Empty")
                        emptynode.setFlags(emptynode.flags() ^ Qt.ItemIsEditable)
                        partner = emptynode.partner()
                        partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
                        partner.setData("", Qt.DisplayRole)
                        tempnode.appendRow([emptynode, partner])

        # Element has no cells
        except KeyError:
            pass
        
        # Recurse through items
        try:
            if str(data['type']) == "MenuButton":
                items = data['items']
                for i in range(len(items)-1, -1, -1):
                    self.insertElement(node, items[i], data, False)
        
        # Element has no items
        except KeyError:
            pass
        
        # Recurse through contents
        try:
            contents = data['content']
            for i in range(len(contents)-1, -1, -1):
                self.insertElement(node, contents[i], data, False)
        
        # Element has no contents
        except KeyError:
            pass
        
        # Recurse through children
        try:
            children = data['children']
            for i in range(len(children)-1, -1, -1):
                self.insertElement(node, children[i], data, False)
        
        # Element has no children
        except KeyError:
            pass
        
    def empty(self):
        """
        Remove all nodes from the tree
        """
        
        self.invisibleRootItem().removeRow(0)
        
    def search(self, property, value, start = None):
        """
        Find an element where property == value
        """
        
        start = start or self.invisibleRootItem().child(0, 0)
        
        if start:
            return self.recSearch(property, value, start)
        else:
            return None
       
    def recSearch(self, property, value, item):
        
        if item[property] == None:
            return 

        if item[property] == value:
            return item
        
        # Check the item's children
        else:
            
            count = item.rowCount()
            if count > 0:
                for i in range(count):
                    result = self.recSearch(property, value, item.child(i))
                    if result:
                        return result
                        
            else:
                return None

