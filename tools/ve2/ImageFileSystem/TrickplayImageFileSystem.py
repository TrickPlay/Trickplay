import re, os, json
from PyQt4.QtGui import *
from PyQt4.QtCore import *
#import connection
from UI.VirtualFileSystem import Ui_VirtualFileSystem
from UI.NewFolder import Ui_newFolderDialog

multiSelect = 'false'


class StitcherThread(QThread):
    def __init__(self, imageTree, itemWhatsThis, emptyPath) :
        QThread.__init__(self)
        self.imageTree = imageTree
        self.itemWT = itemWhatsThis
        self.emptyPath = emptyPath
        self.runState = 0

    def run(self):
        self.runState = 1
        if self.imageTree.isDir(self.itemWT) == True:
            for imageData in self.imageTree.data:
                for imageFile in imageData['sprites']:
                    id = imageFile['id']
                    if id.find(self.itemWT) == 0 :
                        self.imageTree.idsToRemove = self.imageTree.idsToRemove+id+" "

            self.imageTree.idsToRemove = self.imageTree.idsToRemove[:len(self.imageTree.idsToRemove) - 1]
            print("stitcher "+self.emptyPath+" -m "+str(os.path.join(self.imageTree.main.path, "assets/images/images.json"))+" -g "+ self.imageTree.idsToRemove + " -o "+str(os.path.join(self.imageTree.main.path, "assets/images"))+"/images")
            self.imageTree.main.stitcher.start("stitcher \""+self.emptyPath+"\" -m \""+str(os.path.join(self.imageTree.main.path, "assets/images/images.json"))+"\" -g "+ self.imageTree.idsToRemove +" -o \""+str(os.path.join(self.imageTree.main.path, "assets/images"))+"/images\"")
        else :
            
            fileCnt = 0 
            for imageData in self.imageTree.data:
                for imageFile in imageData['sprites']:
                    id = imageFile['id']
                    if id.find(self.imageTree.getDir(self.itemWT)) == 0 : 
                        fileCnt = fileCnt + 1

            print("stitcher "+self.emptyPath+" -m "+str(os.path.join(self.imageTree.main.path, "assets/images/images.json"))+" -g "+ self.itemWT + " -o "+str(os.path.join(self.imageTree.main.path, "assets/images"))+"/images")

            self.imageTree.main.stitcher.start("stitcher \""+self.emptyPath+"\" -m \""+str(os.path.join(self.imageTree.main.path, "assets/images/images.json"))+"\" -g "+ self.itemWT+" -o \""+str(os.path.join(self.imageTree.main.path, "assets/images"))+"/images\"") 

            if fileCnt == 1 :
                orgId = "}\n\t],"
                newFolderInfo = "},\n\t\t{ \"x\": 0, \"y\": 0, \"w\": 0, \"h\": 0, \"id\": \""+self.imageTree.getDir(self.itemWT)+"\" }\n\t],"
                self.imageTree.imageJsonItemSub(orgId, newFolderInfo) 

    def stop(self):
        self.runState = 0



try:
    _fromUtf8 = QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class DnDTreeWidget(QTreeWidget):
     def __init__(self, parent=None):
         QTreeWidget.__init__(self, parent)
         self.fileSystem = parent
         self.setSelectionMode(self.ExtendedSelection)
         self.setDragDropMode(self.InternalMove)
         self.setDragEnabled(True)
         self.setDropIndicatorShown(True)

     def dropEvent(self, event):
         if event.source() == self:
             QAbstractItemView.dropEvent(self, event)

     def dropMimeData(self, parent, row, data, action):
         if action == Qt.MoveAction:
             return self.moveSelection(parent, row)
         return False

     def moveSelection(self, parent, position):
	    # save the selected items
         dropTo = None
         dragFrom = None

         if parent :
            #print parent.whatsThis(0), "To"
            dropTo =  parent.whatsThis(0)
            if dropTo[len(dropTo)-1:] != "/":
                return False
         else:
            dropTo = ""

         selection = [QPersistentModelIndex(i)
                      for i in self.selectedIndexes()]
         parent_index = self.indexFromItem(parent)
         if parent_index in selection:
             return False
         # save the drop location in case it gets moved
         target = self.model().index(position, 0, parent_index).row()
         #print position, parent_index, target, "***"

         if target < 0:
             target = position
         # remove the selected items
         taken = []
         for index in reversed(selection):
             item = self.itemFromIndex(QModelIndex(index))
             if item is None or item.parent() is None:
                 #print item.whatsThis(0), "Look 111"
                 taken.append(self.takeTopLevelItem(index.row()))
             else:
                 if self.fileSystem.isThisUniq(item.text(0), dropTo) == False :
                    return False
                 taken.append(item.parent().takeChild(index.row()))
         #print taken[0].whatsThis(0), "From"
         dragFrom =  taken[0]#.whatsThis(0)
         if self.fileSystem.dragNdrop(dragFrom, dropTo) == False :
            return False

         # insert the selected items at their new positions
         while taken:
             if position == -1:
                 # append the items if position not specified
                 if parent_index.isValid():
                     parent.insertChild(
                         parent.childCount(), taken.pop(0))
                 else:
                     self.insertTopLevelItem(
                         self.topLevelItemCount(), taken.pop(0))
             else:
		# insert the items at the specified position
                 if parent_index.isValid():
                     parent.insertChild(min(target,
                         parent.childCount()), taken.pop(0))
                 else:
                     self.insertTopLevelItem(min(target,
                         self.topLevelItemCount()), taken.pop(0))

         return True


class TrickplayImageFileSystem(QWidget):
    
    def __init__(self, main = None, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
        
        QWidget.__init__(self, parent)
        
        self.ui = Ui_VirtualFileSystem()
        self.ui.setupUi(self)
              
        self.main = main
        
        self.ui.fileSystemTree = DnDTreeWidget(self)
        self.ui.fileSystemTree.setObjectName(_fromUtf8("fileSystemTree"))
        #self.ui.fileSystemTree.headerItem().setText(0, _fromUtf8("1"))
        self.ui.fileSystemTree.header().setVisible(False)
        self.ui.fileSystem.addWidget(self.ui.fileSystemTree, 0, 0, 1, 1)

        #self.ui.fileSystemTree.setHeaderLabels(['Name'])
        self.ui.fileSystemTree.setIndentation(10)
        self.ui.fileSystemTree.setStyleSheet("QTreeWidget { background: lightYellow; alternate-background-color: white; }")
        # id changed 
        QObject.connect(self.ui.fileSystemTree, SIGNAL("itemChanged(QTreeWidgetItem*, int)"), self.fileItemChanged)

        # tool button handlers 
        QObject.connect(self.ui.importButton, SIGNAL('clicked()'), self.importAsset)
        QObject.connect(self.ui.deleteButton, SIGNAL('clicked()'), self.removeAsset)
        QObject.connect(self.ui.newFolderButton, SIGNAL('clicked()'), self.createNewFolder)
        
        self.ui.fileSystemTree.setSortingEnabled(True)
        self.ui.fileSystemTree.sortItems(0, Qt.AscendingOrder)
        self.ui.fileSystemTree.setContextMenuPolicy(Qt.CustomContextMenu)
        self.createContextMenu()
        QObject.connect(self.ui.fileSystemTree, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)

        self.idCnt = 0 
        self.orgCnt = 0 
        self.imageCommand = ""

    def isDir(self, orgId) :
        if orgId[len(orgId)-1:] == "/":
            return True
        else:
            return False
        
    def getLastDir(self, id) :
        folder = ""
        while re.search("\/", id):
            n = re.search("\/", id).end()
            folder = id[:n-1]
            id = id[n:]
        if folder :
            return folder+"/"
        else :
            return ""

    def getDir(self, id) :
        dirVal = ""
        while re.search("\/", id):
            n = re.search("\/", id).end()
            folder = id[:n-1]
            dirVal=dirVal+folder+"/"
            id = id[n:]

        return dirVal
        
    def isOnTop(self, id):
        if self.isDir(id) == True and id.count("/") == 1 :
            return True
        if self.isDir(id) == False and id.count("/") == 0 :
            return True
        return False
            
    def isSameDir(self, id, id2):
        if self.getDir(id) == self.getDir(id2) : 
            return True
        return False

    def isThisUniq(self, dragId, dropTo):

        if self.isDir(dropTo) == True or dropTo == "":
            for imageData in self.data:
                for imageFile in imageData['sprites']:
                    id = imageFile['id']
                    if dropTo == "" and id[:len(dragId)] == dragId :
                        print dropTo+dragId, "is existing"
                        return False
                        
                    if id.find(dropTo+dragId) == 0 :
                        print dropTo+dragId, "is existing"
                        return False
        else:
            return True

    def imageJsonItemSub(self, org, new) :
        if self.main._emulatorManager.fscontentMoveBlock == True :
            return
        f = open(self.main.imageJsonFile)
        jsonFileContents = f.read()

        f = open(self.main.imageJsonFile, 'w')
        f.write(jsonFileContents.replace(org, new))
        f.close()

        self.main.sendLuaCommand("imageNameChange", '_VE_.imageNameChange("'+org+'", "'+new+'")')
        self.imageCommand = "replace"
        self.main.sendLuaCommand("buildVF", '_VE_.buildVF()')

    def dragNdrop(self, dragFrom, dropTo):
        dragFromText = dragFrom.text(0)
        dragFrom = dragFrom.whatsThis(0)

        #print "Drag From : %s"%dragFrom
        #print "Drop To : %s"%dropTo
        
        #Dir -> Dir
        if self.isOnTop(dragFrom) == True :
            org = dragFrom
            new = dropTo+dragFrom
        elif self.isDir(dragFrom) == True :
            org = dragFrom
            new = dropTo+self.getLastDir(dragFrom)
        elif self.isDir(dragFrom) == False :
            org = dragFrom
            new = dropTo+dragFromText

        #print "Org Id : %s "%org
        #print "New Id : %s "%new

        if org != new :
            self.imageJsonItemSub(org, new) 
        return True

    def createContextMenu(self):
        # Toolbar font 
        font = QFont()
        font.setPointSize(9)
    
        # Popup Menu
        self.popMenu = QMenu( self)
        self.popMenu.setFont(font)
        self.popMenu.addAction( '&Add To Screen', self.insertImage )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Create New Folder', self.createNewFolder)
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Delete', self.removeAsset )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Import New Assets', self.importAsset )
        
    def contextMenu(self, point):
        self.popMenu.exec_( self.ui.fileSystemTree.mapToGlobal(point) )

    def importAsset(self) :
        self.main.importAssets()

    def removeAsset(self) :
        self.main.importCmd = "remove"
        item = self.ui.fileSystemTree.currentItem()
        itemWhatsThis = item.whatsThis(0)
        emptyPath = str(os.path.join(self.main.path, "assets/sounds/"))
        self.idsToRemove = ""

        self.sTread = StitcherThread(self, itemWhatsThis, emptyPath)

        self.ui.fileSystemTree.currentItem().removeChild(item)
        self.idCnt = self.idCnt - 1
        self.sTread.run()

    def insertImage(self) :
        
        item = self.ui.fileSystemTree.currentItem()
        source = item.whatsThis(0)
        if self.isDir(source) == False :
            #print ("Insert Image : %s"%source)
            self.main.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self.main._inspector.curLayerGid)+"', 'Image', "+"'"+str(source)+"')")
        else:
            print ("Error : Dir is selected")
        """
            spriteSheet = SpriteSheet { map = "assets/image/images.json" }
            image = WidgetImage{ sheet = spriteSheet, id = "ee/ff.png" }
        """
        
    def createNewFolder(self) :
        #if self.main._emulatorManager.fscontentMoveBlock == True :
            #return
        item = self.ui.fileSystemTree.currentItem()
        if item == None :
            newFolderParent = self.getDir(self.topWhatsThis)
            orgId = str(self.topWhatsThis)
        else :
            newFolderParent = self.getDir(item.whatsThis(0))
            orgId = str(item.whatsThis(0))

        self.dialog = QDialog()
        self.ndirUi = Ui_newFolderDialog()
        self.ndirUi.setupUi(self.dialog)
        self.dialog.setGeometry(self.main.ui.fileSystemDock.geometry().x() + 400, self.main.ui.fileSystemDock.geometry().y() + 200, self.dialog.geometry().width(), self.dialog.geometry().height())
        if self.dialog.exec_():
			dir_name = self.ndirUi.folder_name.text()
			new_path = newFolderParent+dir_name+"/"
			#orgId = str(item.whatsThis(0))
			if self.isDir(orgId) == True: 
			    orgId = "}\n\t],"
			    newFolderInfo = "},\n\t\t{ \"x\": 0, \"y\": 0, \"w\": 0, \"h\": 0, \"id\": \""+new_path+"\" }\n\t],"
			else:
			    newFolderInfo = orgId+"\" },\n\t\t{ \"x\": 0, \"y\": 0, \"w\": 0, \"h\": 0, \"id\": \""+new_path

			self.imageJsonItemSub(orgId, newFolderInfo) 
            
    def fileItemChanged(self, item, col):
        orgId = str(item.whatsThis(0))
        newId = self.getDir(orgId)+str(item.text(0))

        self.imageJsonItemSub(orgId, newId) 

    def buildImageTree(self,  data, styleIndex=None):
        # Clear Image File System Tree
        self.orgCnt = self.idCnt 

        self.ui.fileSystemTree.clear()
        self.idCnt = 0 

        #self.ui.fileSystemTree.setColumnCount(2)
        items = []
        folders = {}
        self.data = data

        for imageData in data:
            cnt = 0
            
            for imageFile in imageData['sprites']:
                id = imageFile['id']
                i = {}
                idx = 1
                folderIdx = ""
                    
                while re.search("\/", id):
                    n = re.search("\/", id).end()
                    folder = id[:n-1]
                    folderIdx = folderIdx+folder+":"
                    if idx > 1:
                        folderColIdx = 0 
                        folderParent = i[idx-1]
                    else:
                        folderColIdx = 1 
                        folderParent = None

                    if folders.has_key(folderIdx) == True :
                        i[idx] = folders[folderIdx][folderColIdx] 
                    else : 
                        i[idx] = QTreeWidgetItem(folderParent)
                        i[idx].setText (0, folder)  
                        temp = i[idx].font(0)
                        temp.setBold(True)
                        #i[idx].setFont (0, i[idx].font(0))  
                        i[idx].setFont (0, temp)  
                        i[idx].setWhatsThis(0, folderIdx.replace(":", "/"))

                    idx = idx + 1
                    id = id[n:]

                    if folders.has_key(folderIdx) == False :
                        folders[folderIdx] = {}
                        folders[folderIdx][0] = i[idx - 1]                    
                        folders[folderIdx][1] = i[1]                    

                fileName = id    
                if idx > 1 :
                    if len(id) > 0:
                        j = QTreeWidgetItem(folders[folderIdx][0]) 
                        j.setText (0, fileName)  
                        j.setFlags(j.flags() ^Qt.ItemIsEditable)
                        j.setWhatsThis(0, imageFile['id'])
                    else :
                        folders[folderIdx][0].setText(0, folders[folderIdx][0].text(0)+" [%s items]"%str(folders[folderIdx][0].childCount()))
                        #print folders[folderIdx][0].text(0)+"[%s items folder]"%str(folders[folderIdx][0].childCount())
                        if folders[folderIdx][0].childCount() == 0 :
                            j = QTreeWidgetItem(folders[folderIdx][0]) 
                            j.setText (0, "(Emplty)")  
                            j.setWhatsThis(0, imageFile['id'])
                    self.ui.fileSystemTree.addTopLevelItem(folders[folderIdx][1]) # top level item

                else :
                    j = QTreeWidgetItem()
                    j.setText (0, fileName) 
                    j.setFlags(j.flags() ^Qt.ItemIsEditable)
                    j.setWhatsThis(0, imageFile['id'])
                    self.topWhatsThis = imageFile['id']
                    self.ui.fileSystemTree.addTopLevelItem(j)
                cnt = cnt + 1
                self.idCnt = self.idCnt + cnt

        return 
        
                    
