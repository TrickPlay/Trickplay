import re, os, json
from PyQt4.QtGui import *
from PyQt4.QtCore import *
#import connection
from UI.VirtualFileSystem import Ui_VirtualFileSystem
from UI.NewFolder import Ui_newFolderDialog

multiSelect = 'false'

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

class TrickplayImageFileSystem(QWidget):
    
    def __init__(self, main = None, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
        
        QWidget.__init__(self, parent)
        
        self.ui = Ui_VirtualFileSystem()
        self.ui.setupUi(self)
              
        self.main = main
        
        self.ui.fileSystemTree.setHeaderLabels(['Name'])
        self.ui.fileSystemTree.setIndentation(10)
        self.ui.fileSystemTree.setStyleSheet("QTreeWidget { background: lightYellow; alternate-background-color: white; }")
        # id changed 
        QObject.connect(self.ui.fileSystemTree, SIGNAL("itemChanged(QTreeWidgetItem*, int)"), self.fileItemChanged)

        # tool button handlers 
        QObject.connect(self.ui.importButton, SIGNAL('clicked()'), self.importAsset)
        QObject.connect(self.ui.deleteButton, SIGNAL('clicked()'), self.removeAsset)
        QObject.connect(self.ui.newFolderButton, SIGNAL('clicked()'), self.createNewFolder)
        
        self.setContextMenuPolicy(Qt.CustomContextMenu)
        self.createContextMenu()
        QObject.connect(self.ui.fileSystemTree, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)

    def isDir(self, orgId) :
        if orgId[len(orgId)-1:] == "/":
            return True
        else:
            return False
        
    def getDir(self, id) :
        dirVal = ""
        while re.search("\/", id):
            n = re.search("\/", id).end()
            folder = id[:n-1]
            dirVal=dirVal+folder+"/"
            id = id[n:]

        return dirVal
        
    def createContextMenu(self):
        # Toolbar font 
        font = QFont()
        font.setPointSize(9)
    
        # Popup Menu
        self.popMenu = QMenu( self)
        self.popMenu.setFont(font)
        self.popMenu.addAction( '&Create New Folder', self.createNewFolder)
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Delete', self.removeAsset )
        self.popMenu.addSeparator()
        self.popMenu.addAction( '&Import New Assets', self.importAsset )
        
    def contextMenu(self, point):
        self.popMenu.exec_( self.view.mapToGlobal(point) )

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
                f = open(self.main.imageJsonFile)
                jsonFileContents = f.read()
                f.close()
                f = open(self.main.imageJsonFile, 'w')
                f.write(jsonFileContents.replace(orgId, newFolderInfo))
                f.close()
                self.main.sendLuaCommand("buildVF", '_VE_.buildVF()')

    def insertImage(self) :
        item = self.ui.fileSystemTree.currentItem()
        source = item.whatsThis(0)

        self.main.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self.main._inspector.curLayerGid)+",
        'Image', "+"'"+str(source)+"')")

        """
            spriteSheet = SpriteSheet { map = "assets/image/images.json" }
            image = WidgetImage{ sheet = spriteSheet, id = "ee/ff.png" }
        """
        
    def createNewFolder(self) :
        if self.main._emulatorManager.fscontentMoveBlock == True :
            return
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
			f = open(self.main.imageJsonFile)
			jsonFileContents = f.read()
			f.close()
			f = open(self.main.imageJsonFile, 'w')
			f.write(jsonFileContents.replace(orgId, newFolderInfo))
			f.close()
			self.main.sendLuaCommand("buildVF", '_VE_.buildVF()')
            
    def fileItemChanged(self, item, col):
        if self.main._emulatorManager.fscontentMoveBlock == True :
            return
        #print "fileItemChanged"
        orgId = str(item.whatsThis(0))
        newId = self.getDir(orgId)+str(item.text(0))

        #jsonFileContents = os.read(self.main.imageJsonFile)
        f = open(self.main.imageJsonFile)
        jsonFileContents = f.read()

        #os.write(self.main.imageJsonFile, jsonFileContents.replace(orgId, newId))
        f = open(self.main.imageJsonFile, 'w')
        f.write(jsonFileContents.replace(orgId, newId))
        f.close()

    def buildImageTree(self,  data, styleIndex=None):

        # Clear Image File System Tree
        self.ui.fileSystemTree.clear()

        #self.ui.fileSystemTree.setColumnCount(2)
        # Init variables 
        items = []
        folders = {}
        self.data = data

        for imageData in data:
            folders = {}
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

                if folders.has_key(folderIdx) == False and idx > 1:
                    folders[folderIdx] = {}
                    folders[folderIdx][0] = i[idx - 1]                    
                    folders[folderIdx][1] = i[1]                    

                fileName = id    
                if idx > 1 :
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
        
                    
