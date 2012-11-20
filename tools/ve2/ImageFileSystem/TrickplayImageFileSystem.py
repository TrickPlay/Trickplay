import re, os, json
from PyQt4.QtGui import *
from PyQt4.QtCore import *
#import connection
from UI.VirtualFileSystem import Ui_VirtualFileSystem
from UI.NewFolder import Ui_newFolderDialog

multiSelect = 'false'


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
                 print item.whatsThis(0), "Look 111"
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
        self.ui.fileSystemTree.headerItem().setText(0, _fromUtf8("1"))
        self.ui.fileSystem.addWidget(self.ui.fileSystemTree, 0, 0, 1, 1)

        self.ui.fileSystemTree.setHeaderLabels(['Name'])
        self.ui.fileSystemTree.setIndentation(10)
        self.ui.fileSystemTree.setStyleSheet("QTreeWidget { background: lightYellow; alternate-background-color: white; }")
        # id changed 
        QObject.connect(self.ui.fileSystemTree, SIGNAL("itemChanged(QTreeWidgetItem*, int)"), self.fileItemChanged)

        # tool button handlers 
        QObject.connect(self.ui.importButton, SIGNAL('clicked()'), self.importAsset)
        QObject.connect(self.ui.deleteButton, SIGNAL('clicked()'), self.removeAsset)
        QObject.connect(self.ui.newFolderButton, SIGNAL('clicked()'), self.createNewFolder)
        
        self.ui.fileSystemTree.setContextMenuPolicy(Qt.CustomContextMenu)
        self.createContextMenu()
        QObject.connect(self.ui.fileSystemTree, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)

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
        self.main.sendLuaCommand("buildVF", '_VE_.buildVF()')

    def dragNdrop(self, dragFrom, dropTo):
        dragFromText = dragFrom.text(0)
        dragFrom = dragFrom.whatsThis(0)

        print "Drag From : %s"%dragFrom
        print "Drop To : %s"%dropTo
        
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

        print "Org Id : %s "%org
        print "New Id : %s "%new
        if org != new :
            self.imageJsonItemSub(org, new) 

        """
        if self.isOnTop(dragFrom) == True :
            #if self.isDir(dropTo) == False and self.isOnTop(dropTo) == True :
                #print ("same level 111 ")
            #else :
            org = dragFrom
            new = dropTo+dragFrom
            self.imageJsonItemSub(org, new) 
            # TODO : (1) need to delete empty dropTo/ if dropTo was empty 
            print ("case1")
        else :
            if self.isOnTop(dropTo) == True :
                if self.isDir(dragFrom) == False : 
                    org = dragFrom
                    new = dragFromText
                    self.imageJsonItemSub(org, new) 
                    # TODO : (2) need to create empty dragFrom folder / if dragFrom is empty 
                    print ("case2")
                else : 
                    for imageData in self.data:
                        for imageFile in imageData['sprites']:
                            id = imageFile['id']
                            if id[:len(dragFrom)] == dragFrom :
                                org = id 
                                new = id[len(dragFrom):]
                                self.imageJsonItemSub(org, new) 
                                print ("case3")
            elif self.isSameDir(dragFrom, dropTo) == True:
                print ("same level 222 ")
            else :
                print ("case4")
                if self.isDir(dragFrom) == False :
                    org = dragFrom
                    new = dragFromText
                    self.imageJsonItemSub(org, new) 
                    
            #"""
        return True

    def createContextMenu(self):
        # Toolbar font 
        font = QFont()
        font.setPointSize(9)
    
        # Popup Menu
        self.popMenu = QMenu( self)
        self.popMenu.setFont(font)
        self.popMenu.addAction( '&Import New Assets', self.importAsset )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Create New Folder', self.createNewFolder)
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Delete', self.removeAsset )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Insert Image To Screen', self.insertImage )
        
    def contextMenu(self, point):
        self.popMenu.exec_( self.ui.fileSystemTree.mapToGlobal(point) )

    def importAsset(self) :
        self.main.importAssets()

    def removeAsset(self) :
        item = self.ui.fileSystemTree.currentItem()
        itemWhatsThis = item.whatsThis(0)
        emptyPath = str(os.path.join(self.main.path, "assets/sounds/"))
        #idsToRemove = []
        idsToRemove = ""

        if self.isDir(item.whatsThis(0)) == True:
            for imageData in self.data:
                for imageFile in imageData['sprites']:
                    id = imageFile['id']
                    if id.find(item.whatsThis(0)) == 0 :
                        idsToRemove = idsToRemove+id+" "

            idsToRemove = idsToRemove[:len(idsToRemove) - 1]
            print("stitcher "+emptyPath+" -j "+str(os.path.join(self.main.path, "assets/images/images.json"))+" -f "+ idsToRemove + " -o "+str(os.path.join(self.main.path, "assets/images"))+"/images")
            self.main.stitcher.start("stitcher "+emptyPath+" -j "+str(os.path.join(self.main.path, "assets/images/images.json"))+" -f "+ idsToRemove +" -o "+str(os.path.join(self.main.path, "assets/images"))+"/images")
        else :
            
            fileCnt = 0 
            for imageData in self.data:
                for imageFile in imageData['sprites']:
                    id = imageFile['id']
                    if id.find(self.getDir(item.whatsThis(0))) == 0 : 
                        fileCnt = fileCnt + 1

            print("stitcher "+emptyPath+" -j "+str(os.path.join(self.main.path, "assets/images/images.json"))+" -f "+ item.whatsThis(0) + " -o "+str(os.path.join(self.main.path, "assets/images"))+"/images")
            self.main.stitcher.start("stitcher "+emptyPath+" -j "+str(os.path.join(self.main.path, "assets/images/images.json"))+" -f "+ item.whatsThis(0)+" -o "+str(os.path.join(self.main.path, "assets/images"))+"/images")

            if fileCnt == 1 :
                orgId = "}\n\t],"
                newFolderInfo = "},\n\t\t{ \"x\": 0, \"y\": 0, \"w\": 0, \"h\": 0, \"id\": \""+self.getDir(itemWhatsThis)+"\" }\n\t],"
                self.imageJsonItemSub(orgId, newFolderInfo) 
                """
                f = open(self.main.imageJsonFile)
                jsonFileContents = f.read()
                f.close()
                f = open(self.main.imageJsonFile, 'w')
                f.write(jsonFileContents.replace(orgId, newFolderInfo))
                f.close()
                self.main.sendLuaCommand("buildVF", '_VE_.buildVF()')
                """

    def insertImage(self) :
        
        item = self.ui.fileSystemTree.currentItem()
        source = item.whatsThis(0)
        if self.isDir(source) == False :
            print ("Insert Image : %s"%source)
        else:
            print ("Error : Dir is selected")

        """
        item = self.ui.fileSystemTree.currentItem()
        source = item.whatsThis(0)

        self.main.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self.main._inspector.curLayerGid)+", 'Image', "+"'"+str(source)+"')")

            spriteSheet = SpriteSheet { map = "assets/image/images.json" }
            image = WidgetImage{ sheet = spriteSheet, id = "ee/ff.png" }
        """
        
    def createNewFolder(self) :
        #if self.main._emulatorManager.fscontentMoveBlock == True :
            #return
        item = self.ui.fileSystemTree.currentItem()
        newFolderParent = self.getDir(item.whatsThis(0))

        self.dialog = QDialog()
        self.ndirUi = Ui_newFolderDialog()
        self.ndirUi.setupUi(self.dialog)
        if self.dialog.exec_():
			dir_name = self.ndirUi.folder_name.text()
			new_path = newFolderParent+dir_name+"/"
			orgId = str(item.whatsThis(0))
			if self.isDir(orgId) == True: #[len(orgId)-1:] == "/":
			    orgId = "}\n\t],"
			    newFolderInfo = "},\n\t\t{ \"x\": 0, \"y\": 0, \"w\": 0, \"h\": 0, \"id\": \""+new_path+"\" }\n\t],"
			else:
			    newFolderInfo = orgId+"\" },\n\t\t{ \"x\": 0, \"y\": 0, \"w\": 0, \"h\": 0, \"id\": \""+new_path

			self.imageJsonItemSub(orgId, newFolderInfo) 
			"""
			f = open(self.main.imageJsonFile)
			jsonFileContents = f.read()
			f.close()
			f = open(self.main.imageJsonFile, 'w')
			f.write(jsonFileContents.replace(orgId, newFolderInfo))
			f.close()
			self.main.sendLuaCommand("buildVF", '_VE_.buildVF()')
			"""
            
    def fileItemChanged(self, item, col):
        #if self.main._emulatorManager.fscontentMoveBlock == True :
            #return
        #print "fileItemChanged"
        orgId = str(item.whatsThis(0))
        newId = self.getDir(orgId)+str(item.text(0))

        self.imageJsonItemSub(orgId, newId) 

        """
        #jsonFileContents = os.read(self.main.imageJsonFile)
        f = open(self.main.imageJsonFile)
        jsonFileContents = f.read()

        #os.write(self.main.imageJsonFile, jsonFileContents.replace(orgId, newId))
        f = open(self.main.imageJsonFile, 'w')
        f.write(jsonFileContents.replace(orgId, newId))
        f.close()
        """

    def buildImageTree(self,  data, styleIndex=None):

        # Clear Image File System Tree
        self.ui.fileSystemTree.clear()

        #self.ui.fileSystemTree.setColumnCount(2)
        # Init variables 
        items = []
        folders = {}
        self.data = data

        for imageData in data:
            #folders = {}
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
                        if folders.has_key(folderIdx) == True :
                            i[idx] = folders[folderIdx][0] 
                        else : 
                            i[idx] = QTreeWidgetItem(i[idx-1])
                            i[idx].setText (0, folder)  
                            i[idx].setWhatsThis(0, folderIdx.replace(":", "/"))
                    else :
                        if folders.has_key(folderIdx) == True :
                            i[idx] = folders[folderIdx][1] # top level item 
                        else:
                            i[idx] = QTreeWidgetItem()
                            i[idx].setText (0, folder)  
                            i[idx].setWhatsThis(0, folderIdx.replace(":", "/"))

                    idx = idx + 1
                    id = id[n:]

                    if folders.has_key(folderIdx) == False :
                        folders[folderIdx] = {}
                        folders[folderIdx][0] = i[idx - 1]                    
                        folders[folderIdx][1] = i[1]                    

                """
                if folders.has_key(folderIdx) == False and idx > 1:
                    folders[folderIdx] = {}
                    folders[folderIdx][0] = i[idx - 1]                    
                    folders[folderIdx][1] = i[1]                    
                """

                fileName = id    
                if idx > 1 :
                    if len(id) > 0:
                        j = QTreeWidgetItem(folders[folderIdx][0]) 
                        j.setText (0, fileName)  
                        j.setFlags(j.flags() ^Qt.ItemIsEditable)
                        j.setWhatsThis(0, imageFile['id'])
                    self.ui.fileSystemTree.addTopLevelItem(folders[folderIdx][1]) # top level item
                else :
                    j = QTreeWidgetItem()
                    j.setText (0, fileName) 
                    j.setFlags(j.flags() ^Qt.ItemIsEditable)
                    j.setWhatsThis(0, imageFile['id'])
                    self.ui.fileSystemTree.addTopLevelItem(j)
                cnt = cnt + 1

                    
        return 
        
                    
