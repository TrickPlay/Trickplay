from copy import deepcopy
from PyQt4.QtCore import *
from PyQt4.QtGui import *

from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply
from TrickplayElement import TrickplayElement

class TrickplayElementModel(QStandardItemModel):

    def __init__(self, inspector, parent=None):
        QWidget.__init__(self, parent)
        self.inspector = inspector
        self.main = inspector.main
        self.manager = QNetworkAccessManager()
        self.reply = None
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
        print "rai"
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            print "rai : contentBlock False"
            the_item= self.itemFromIndex(idx)
            if the_item :
                try:
                    self.newParentGid = the_item['gid']
                    if self.newParentGid == None and the_item.parent() and the_item.parent().parent()['type'] == "LayoutManager" :
                        if the_item.text()[:3] == "Row" : #Drop into Row
                            self.lmRow = int(the_item.text()[3:])
                            for x in range(0, the_item.rowCount()):
                                temp_item = the_item.takeChild(x)
                                if temp_item.text() == "Empty" :
                                    self.lmCol = int( x )
                                    break
                            if self.lmCol == "nil" :
                                self.lmCol = int( the_item.rowCount() )
                            self.newParentGid = the_item.parent()['gid']
                        else : #Drop into Empty Cell
                            self.lmCol = int(the_item.row()) # layout manager col number
                            self.lmRow = int(the_item.parent().text()[3:])
                            self.newParentGid = the_item.parent().parent()['gid'] #LayoutManager
                    elif the_item.parent()['type'] == "TabBar" :
                        self.tabIndex = the_item.row() + 1
                        self.newParentGid = the_item.parent()['gid']
                except:
                    self.newParentGid = None
                    print ("merong : newParentGid nil")

    def ri(self, idx, i , j):
        #idx is parent's idx
        pass
        """
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            the_item= self.itemFromIndex(idx)
            if the_item :
                try:
                    self.newParentGid = the_item['gid']
                except:

        """

    def rar(self, idx, i , j):
        print "rar"
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            print "rar : contentBlock false"
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
                    except:
                        self.newChildGid = None
                        print ("merong : newChildGid nil")


    def rr(self, idx, i , j):
        print "rr"
        if self.inspector.main._emulatorManager.contentMoveBlock == False :
            print "rr : contentblock false"
            the_item= self.itemFromIndex(idx)
            if self.newChildGid and self.newParentGid :
                if self.tabIndex is not "nil" :
                    if str(self.lmParentGid) != 'nil' :
                        self.main.sendLuaCommand("contentMove", "_VE_.contentMove('"+str(self.newChildGid)+"','"+str(self.newParentGid)+"',"+str(self.tabIndex)+","+str(self.lmCol)+","+self.lmChild+",'"+str(self.lmParentGid)+"')")
                    else:
                        self.main.sendLuaCommand("contentMove", "_VE_.contentMove('"+str(self.newChildGid)+"','"+str(self.newParentGid)+"',"+str(self.tabIndex)+","+str(self.lmCol)+","+self.lmChild+","+str(self.lmParentGid)+")")
                else:
                    if str(self.lmParentGid) != 'nil' :
                        self.main.sendLuaCommand("contentMove", "_VE_.contentMove('"+str(self.newChildGid)+"','"+str(self.newParentGid)+"',"+str(self.lmRow)+","+str(self.lmCol)+","+self.lmChild+",'"+str(self.lmParentGid)+"')")
                    else:
                        self.main.sendLuaCommand("contentMove", "_VE_.contentMove('"+str(self.newChildGid)+"','"+str(self.newParentGid)+"',"+str(self.lmRow)+","+str(self.lmCol)+","+self.lmChild+","+str(self.lmParentGid)+")")
            else:
                pass

            self.lmChild = "false"
            self.tabIndex = "nil"
            self.lmParentGid = "nil"


    def inspector_reply_finished(self, pdata=None, sdata=None):
        if pdata is not None :
            root = self.invisibleRootItem()
            child = None
            pdata = pdata[0]
            self.styleData = sdata

            for c in pdata["children"]:
                if c["name"] == "screen":
                    child = c
                    self.inspector.screenGid = c["gid"]
                    break

            if child is None:
                print( "Could not find screen element." )
            else:
                self.tpData = pdata
                self.insertElement(root, child, pdata, True)

            self.inspector.ui.inspector.expandAll()

            self.main.command = ""
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
            self.inspector.layerName[(gid)] = self.inspector.curLayerName
            self.inspector.layerGid[(gid)] = self.inspector.curLayerGid

        if "Texture" == title:
            title = "Image"
        elif "Widget_" == title[:7]:
            title = title[7:]

        # Set the name node to gid + name
        if '' != value:
            gs = str(gid)
            l = len(gs)
        else:
            value = ""

        node = TrickplayElement(title)
        node.setTPJSON(data)
        node.setTPParent(parentData)
        node.setFlags(node.flags() ^ Qt.ItemIsEditable)
        #print "[VE] Inspector :", node['gid'], node['name']

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
            node.setSelectable(False)
            node.partner().setSelectable(False)

        partner = node.partner()
        partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
        partner.setData(value, Qt.DisplayRole)

        self.inspector.main._emulatorManager.contentMoveBlock = True
        parent.appendRow([node, partner])
        self.inspector.main._emulatorManager.contentMoveBlock = False

        # Recurse through tabs
        try:
            tabs = data['tabs']
            for r in range (0, len(tabs)) :
                tempnode = TrickplayElement(tabs[r]['label'])
                tempnode.tabdata = data
                tempnode.tabIndex = r + 1
                tempnode.setFlags(tempnode.flags() ^ Qt.ItemIsEditable)
                partner = tempnode.partner()
                partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
                partner.setData("", Qt.DisplayRole)
                node.appendRow([tempnode, partner])
                for c in range (0, len(tabs[r]['contents']['children'])) :
                    self.insertElement(tempnode, tabs[r]['contents']['children'][c], data, False)

        # Element has no tabs
        except KeyError:
            pass

        # Recurse through cells
        try:
            cells = data['cells']
            for r in range (0, len(cells)) :
                tempnode = TrickplayElement("Row"+str(r))
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
                # keep the tree information :)
                self.node = node

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

        try :
            if item.TPJSON()[property] == value:
                return item
        except:
            pass

        # Check the item's children
        try:

            count = item.rowCount()
            if count > 0:
                for i in range(count):
                    result = self.recSearch(property, value, item.child(i))
                    if result:
                        return result

        except:
            pass

