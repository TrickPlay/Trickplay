import os

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from wizard import Wizard
from UI.MainWindow import Ui_MainWindow
from Inspector.TrickplayInspector import TrickplayInspector
from ImageFileSystem.TrickplayImageFileSystem import TrickplayImageFileSystem
from EmulatorManager.TrickplayEmulatorManager import TrickplayEmulatorManager

class MainWindow(QMainWindow):
    
    def __init__(self, app, apath=None, parent = None):
        
        QWidget.__init__(self, parent)
        
        self.apath = apath

        self.debugger = QProcess()

        QObject.connect(self.debugger, SIGNAL('started()'), self.debug_started)
        QObject.connect(self.debugger, SIGNAL('finished(int)'), self.debug_finished)

        self.stitcher = QProcess()
        QObject.connect(self.stitcher, SIGNAL('started()'), self.import_started)
        QObject.connect(self.stitcher, SIGNAL('finished(int)'), self.import_finished)
        QObject.connect(self.stitcher, SIGNAL('readyReadStandardError()'), self.import_stdError)
        QObject.connect(self.stitcher, SIGNAL('readyRead()'), self.import_readyRead)

        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.windows = {"inspector":False, "images":False}
        self.inspectorWindowClicked()

        # Create Inspector
        self.ui.InspectorDock.toggleViewAction().setText("Inspector")
        self.ui.menuView.addAction(self.ui.InspectorDock.toggleViewAction())
        self.ui.InspectorDock.toggleViewAction().triggered.connect(self.inspectorWindowClicked)

        self._inspector = TrickplayInspector(self)
        self.ui.InspectorLayout.addWidget(self._inspector)
        
        # Create Image File System
        self.ui.fileSystemDock.toggleViewAction().setText("Images")
        self.ui.menuView.addAction(self.ui.fileSystemDock.toggleViewAction())
        self.ui.fileSystemDock.toggleViewAction().triggered.connect(self.imagesWindowClicked)

        self._ifilesystem = TrickplayImageFileSystem(self)
        self.ui.fileSystemLayout.addWidget(self._ifilesystem)

        # Create EmulatorManager
        self.ui.actionEditor.toggled.connect(self.editorWindowClicked)
        self._emulatorManager = TrickplayEmulatorManager(self) 
        self._inspector.emulatorManager = self._emulatorManager

		#File Menu
        QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        QObject.connect(self.ui.actionLua_File_Engine_UI_Elements, SIGNAL("triggered()"),  self.openLua)
        QObject.connect(self.ui.actionJSON_New_UI_Elements, SIGNAL("triggered()"),  self.open)
        QObject.connect(self.ui.actionNew_Layer, SIGNAL("triggered()"),  self.newLayer)
        QObject.connect(self.ui.actionNew_Project, SIGNAL("triggered()"),  self.newProject)
        QObject.connect(self.ui.actionOpen_Project, SIGNAL("triggered()"),  self.openProject)
        QObject.connect(self.ui.actionSave_Project, SIGNAL("triggered()"),  self.saveProject)
        QObject.connect(self.ui.actionImport_Assets, SIGNAL("triggered()"),  self.importAssets)
        QObject.connect(self.ui.actionImport_Skins, SIGNAL("triggered()"),  self.importSkins)
        
		#Edit Menu
        QObject.connect(self.ui.action_Button, SIGNAL("triggered()"),  self.button)
        QObject.connect(self.ui.actionDialog_Box, SIGNAL("triggered()"),  self.dialogbox)
        QObject.connect(self.ui.actionToastAlert, SIGNAL("triggered()"),  self.toastalert)
        #QObject.connect(self.ui.actionToggleButton, SIGNAL("triggered()"),  self.togglebutton)
        QObject.connect(self.ui.actionCheckBox, SIGNAL("triggered()"),  self.checkbox)
        QObject.connect(self.ui.actionRadioButton, SIGNAL("triggered()"),  self.radiobutton)
        QObject.connect(self.ui.actionProgressSpinner, SIGNAL("triggered()"),  self.progressspinner)
        QObject.connect(self.ui.actionProgressBar, SIGNAL("triggered()"),  self.progressbar)
        QObject.connect(self.ui.actionOrbitting_Dots, SIGNAL("triggered()"),  self.orbittingdots)
        QObject.connect(self.ui.actionTextInput, SIGNAL("triggered()"),  self.textinput)

        QObject.connect(self.ui.actionSlider, SIGNAL("triggered()"),  self.slider)
        QObject.connect(self.ui.actionLayoutManager, SIGNAL("triggered()"),  self.layoutmanager)
        QObject.connect(self.ui.actionScrollPane, SIGNAL("triggered()"),  self.scrollpane)
        QObject.connect(self.ui.actionTabBar, SIGNAL("triggered()"),  self.tabbar)
        QObject.connect(self.ui.actionArrowPane, SIGNAL("triggered()"),  self.arrowpane)
        QObject.connect(self.ui.actionButtonPicker, SIGNAL("triggered()"),  self.buttonpicker)
        QObject.connect(self.ui.actionMenuButton, SIGNAL("triggered()"),  self.menubutton)

        QObject.connect(self.ui.actionWidgetText, SIGNAL("triggered()"),  self.text)
        #QObject.connect(self.ui.actionWidgetImage, SIGNAL("triggered()"),  self.image)
        QObject.connect(self.ui.actionWidgetRectangle, SIGNAL("triggered()"),  self.rectangle)

        QObject.connect(self.ui.actionGroup, SIGNAL("triggered()"),  self.group)
        QObject.connect(self.ui.actionUngroup, SIGNAL("triggered()"),  self.ungroup)
        QObject.connect(self.ui.actionClone, SIGNAL("triggered()"),  self.clone)
        QObject.connect(self.ui.actionDuplicate, SIGNAL("triggered()"),  self.duplicate)
        QObject.connect(self.ui.actionDelete, SIGNAL("triggered()"),  self.delete)

		#Arrange Menu
        QObject.connect(self.ui.action_left, SIGNAL("triggered()"),  self.left)
        QObject.connect(self.ui.action_right, SIGNAL("triggered()"),  self.right)
        QObject.connect(self.ui.action_top, SIGNAL("triggered()"),  self.top)
        QObject.connect(self.ui.action_bottom, SIGNAL("triggered()"),  self.bottom)
        QObject.connect(self.ui.action_horizontalCenter, SIGNAL("triggered()"),  self.horizontalCenter)
        QObject.connect(self.ui.action_verticalCenter, SIGNAL("triggered()"),  self.verticalCenter)

        QObject.connect(self.ui.action_distributeHorizontally, SIGNAL("triggered()"),  self.distributeHorizontal)
        QObject.connect(self.ui.action_distributeVertically, SIGNAL("triggered()"),  self.distributeVertical)

        QObject.connect(self.ui.action_bring_to_front, SIGNAL("triggered()"),  self.bringToFront)
        QObject.connect(self.ui.action_bring_to_forward, SIGNAL("triggered()"),  self.bringForward)
        QObject.connect(self.ui.action_send_to_back, SIGNAL("triggered()"),  self.sendToBack)
        QObject.connect(self.ui.action_send_backward, SIGNAL("triggered()"),  self.sendBackward)

		#View Menu
        QObject.connect(self.ui.actionImage, SIGNAL("triggered()"),  self.backgroundImage)
        QObject.connect(self.ui.actionSmall_Grid, SIGNAL("triggered()"),  self.smallGrid)
        QObject.connect(self.ui.actionMedium_Grid, SIGNAL("triggered()"),  self.mediumGrid)
        QObject.connect(self.ui.actionLarge_Grid, SIGNAL("triggered()"),  self.largeGrid)
        QObject.connect(self.ui.actionWhite, SIGNAL("triggered()"),  self.white)
        QObject.connect(self.ui.actionBlack, SIGNAL("triggered()"),  self.black)

        QObject.connect(self.ui.actionAdd_Horizontal_Guide, SIGNAL("triggered()"),  self.addHorizonGuide)
        QObject.connect(self.ui.actionAdd_Vertical_Guide, SIGNAL("triggered()"),  self.addVerticalGuide)

        QObject.connect(self.ui.actionShow_Guides, SIGNAL("triggered()"),  self.showGuides)
        QObject.connect(self.ui.actionSnap_to_Guides, SIGNAL("triggered()"),  self.snapToGuides)

		#Run Menu
        QObject.connect(self.ui.action_Run, SIGNAL("triggered()"),  self.run)
        QObject.connect(self.ui.action_CodeEditor, SIGNAL("triggered()"),  self.debug)
        QObject.connect(self.ui.action_Stop, SIGNAL("triggered()"),  self.stop)
		
        # Restore sizes/positions of docks
        #self.restoreState(settings.value("mainWindowState").toByteArray());

        self.path =  None 
        self.app = app
        self.command = None
        self.currentProject = None

        QObject.connect(app, SIGNAL('aboutToQuit()'), self.exit)

    @property
    def emulatorManager(self):
        return self._emulatorManager
    
    @property
    def inspector(self):
        return self._inspector

    def sendLuaCommand(self, selfCmd, inputCmd):
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = selfCmd
        print "[VE] "+inputCmd

    def openLua(self):
        self.sendLuaCommand("openLuaFile", "_VE_.openLuaFile()")
        return True

    def open(self):
        self.sendLuaCommand("openFile", '_VE_.openFile("'+str(self.path)+'")')
        self.imageJsonFile = str(os.path.join(self.path, "assets/images/images.json"))
        return True
    
    def setAppPath(self):
        self.sendLuaCommand("setAppPath", '_VE_.setAppPath("'+str(self.path)+'")')
        return True

    def newLayer(self):
        self.sendLuaCommand("newLayer", "_VE_.newLayer()")
        return True

    def errorMsg(self, eMsg):
        msg = QMessageBox()
        msg.setText(eMsg)
        msg.setStandardButtons(QMessageBox.Ok)
        msg.setDefaultButton(QMessageBox.Ok)
        msg.setWindowTitle("Error")
        ret = msg.exec_()
        if ret == QMessageBox.Ok:
            return

    def warningMsg(self):
        msg = QMessageBox()
        msg.setText('The Project "'+ self.currentProject +'" is changed.')
        msg.setInformativeText('If you don\'t save it, the changes will be permanently lost.')
        msg.setStandardButtons(QMessageBox.Save | QMessageBox.Cancel)
        msg.addButton("Close without Saving" , QMessageBox.NoRole )
        msg.setDefaultButton(QMessageBox.Cancel)
        msg.setWindowTitle("Warning")
        ret = msg.exec_()
        if ret == QMessageBox.Save:
            self.saveProject()
        elif ret == QMessageBox.Cancel:
            return 
        
    def import_started(self):
        """
        self.bar = QProgressBar()
        self.bar.setRange(0, 100)
        self.bar.setValue(0)
        self.bar.setWindowTitle("Import Assets...")
        self.bar.setGeometry(600, 400, 300, 20)
        """
        self.bar.show()
        return 

    def import_readyRead(self):
        while True:
            if not self.stitcher.canReadLine():
                break
            s = self.stitcher.readLine()
            if s.isNull():
                break
            s = str( s ).rstrip()
            print s
        return

    def import_stdError(self):
        s = self.stitcher.readAllStandardError()
        if s.contains('\r') or s.contains('\n') :
            l = s.split('\n') 
            newVal = 0
            try : 
                if s[len(s)-1:] in ['\r', '\n'] : 
                    newVal = int(l[len(l) - 2])
                    self.lastNumber = None
                else :
                    if len(l) > 2 :
                        newVal = int(l[len(l) - 2])
                    elif self.lastNum is not None:
                        newVal = int(self.lastNum+l[0])
                    else : 
                        newVal = int(l[0])
                    self.lastNumber = l[len(l) - 1]
                        
                self.bar.setValue(newVal)
                print "[VE] progressBar.setValue : %s  "%str(newVal)
            except : 
                pass

        else:
            print str(s.data())

    def import_finished(self, errorCode):
        if errorCode == 0 : 
            print "[VE] progressBar.setValue : %s  "%'100'
            self.bar.setValue(100)
            self.bar.hide()
            self.sendLuaCommand("buildVF", '_VE_.buildVF()')
            self.sendLuaCommand("openFile", '_VE_.openFile("'+str(self.path)+'")')
        else : 
            self.bar.hide()
            errorMsg = str(self.stitcher.readAllStandardError().data())
            print errorMsg
            self.errorMsg("Import Failed.")
        return 


    def importAssets(self):
        path = -1 
        self.bar = QProgressBar()
        self.bar.setRange(0, 100)
        self.bar.setValue(0)
        self.bar.setWindowTitle("Import Assets...")
        self.bar.setGeometry(self.ui.fileSystemDock.geometry().x() + 200, self.ui.fileSystemDock.geometry().y() + 100, 300, 20)

        while path == -1 :
            if self.path is None:
		        self.path = self.apath
            path = QFileDialog.getExistingDirectory(None, 'Import Asset Images', self.path, QFileDialog.ShowDirsOnly)

        if path:
            print ("[VE] Import Asset Images ...[%s]"%path)

            if os.path.exists(os.path.join(self.path, "assets/images/images.json")) == True:
                print("[VE] stitcher -rp -m '"+str(os.path.join(self.path, "assets/images/images.json"))+"' -o '"+str(os.path.join(self.path, "assets/images"))+"/images' "+path)
                self.stitcher.start("stitcher -rp -m \""+str(os.path.join(self.path, "assets/images/images.json"))+"\" -o \""+str(os.path.join(self.path, "assets/images"))+"/images\" "+path)
            else:
                print("[VE] stitcher -rp -o \""+str(os.path.join(self.path, "assets/images"))+"/images\" "+path)
                self.stitcher.start("stitcher -rp -o \""+str(os.path.join(self.path, "assets/images"))+"/images\" "+path)

    def importSkins(self):
        path = -1 
        self.bar = QProgressBar()
        self.bar.setRange(0, 100)
        self.bar.setValue(0)
        self.bar.setWindowTitle("Import Skin...")
        self.bar.setGeometry(self.ui.fileSystemDock.geometry().x() + 200, self.ui.fileSystemDock.geometry().y() + 100, 300, 20)
        #self.bar.setGeometry(600, 400, 300, 20)
        while path == -1 :
            if self.path is None:
		        self.path = self.apath
            path = QFileDialog.getExistingDirectory(None, 'Import Asset Images', self.path, QFileDialog.ShowDirsOnly)

        if path:
            print ("[VE] Import Skin Images ...[%s]"%path)

            if os.path.exists(os.path.join(self.path, "assets/skins/skins.json")) == True:
                print("[VE] stitcher -r -m '"+str(os.path.join(self.path, "assets/skins/skins.json"))+"' -o '"+str(os.path.join(self.path, "assets/skins"))+"/skins' "+path)
                self.stitcher.start("stitcher -m \""+str(os.path.join(self.path, "assets/skins/skins.json"))+"\" -o \""+str(os.path.join(self.path, "assets/skins"))+"/skins\" "+path)
            else:
                print("[VE] stitcher -r -o '"+str(os.path.join(self.path, "assets/skins"))+"/skins' "+path)
                self.stitcher.start("stitcher -r -o \""+str(os.path.join(self.path, "assets/skins"))+"/skins\" "+path)

    def newProject(self):
        orgPath = self.path
        wizard = Wizard(self)
        path = None 

        if self._emulatorManager.unsavedChanges == True :
            self.warningMsg()

        while path == None :
            path = wizard.start("", False, True)

        if path is not None and path != -1 :
            settings = QSettings()
            if settings.value('path') is not None:
                settings.setValue('path', path)

            self.setCurrentProject(path)
            self.setAppPath()
            self.run()
            self.command = "newProject"
            self._ifilesystem.ui.fileSystemTree.clear()

            while self.inspector.ui.screenCombo.count() > 0 :
                curIdx = self.inspector.ui.screenCombo.currentIndex()
                self.inspector.ui.screenCombo.removeItem(curIdx)

            self.inspector.ui.screenCombo.addItem("Default")
            self.inspector.screens = {"_AllScreens":[],"Default":[]}

            return True

    def openProject(self):
        if self._emulatorManager.unsavedChanges == True :
            self.warningMsg()

        wizard = Wizard(self)
        path = -1
        while path == -1 :
            if self.path is None:
		        self.path = self.apath
            path = QFileDialog.getExistingDirectory(None, 'Open Project', self.path, QFileDialog.ShowDirsOnly)
            path = wizard.start(path, True)
        print ("[VE] Open Project [%s]"%path)
        if path:
            settings = QSettings()
            if settings.value('path') is not None:
                self.stop()
            while self.inspector.ui.screenCombo.count() > 0 :
                curIdx = self.inspector.ui.screenCombo.currentIndex()
                self.inspector.ui.screenCombo.removeItem(curIdx)
            self.inspector.ui.screenCombo.addItem("Default")
            settings.setValue('path', path)
            self.setCurrentProject(str(path))
            self.setAppPath()
            self.run()
            self.command = "openProject"
            self.inspector.screens = {"_AllScreens":[],"Default":[]}
        return True

    def saveProject(self):
        self.setAppPath()
        self.sendLuaCommand("save", "_VE_.saveFile(\'"+self.inspector.screen_json()+"\')")
        self._emulatorManager.unsavedChanges = False
        return True

    def save(self):
        self.setAppPath()
        self.sendLuaCommand("save", "_VE_.saveFile(\'"+self.inspector.screen_json()+"\')")
        self._emulatorManager.unsavedChanges = False
        return True

    def slider(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Slider')")
        return True

    def layoutmanager(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'LayoutManager')")
        return True

    def scrollpane(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'ScrollPane')")
        return True

    def tabbar(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'TabBar')")
        return True

    def arrowpane(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'ArrowPane')")
        return True

    def buttonpicker(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'ButtonPicker')")
        return True

    def menubutton(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'MenuButton')")
        return True

    def textinput(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'TextInput')")
        return True

    def orbittingdots(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'OrbittingDots')")
        return True

    def progressbar(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'ProgressBar')")
        return True

    def progressspinner(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'ProgressSpinner')")
        return True

    def toastalert(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'ToastAlert')")
        return True

    """
    def togglebutton(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'ToggleButton')")
        return True
    """

    def checkbox(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'CheckBox')")
        return True

    def radiobutton(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'RadioButton')")
        return True

    def dialogbox(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'DialogBox')")
        return True

    def button(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Button')")
        return True

    def text(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Text')")
        return True

    def image(self):
        path = QFileDialog.getOpenFileName(None, 'Set Image Source', str(os.path.join(self.path, 'assets/images')), "*.jpg *.gif *.png")
        path = os.path.basename(str(path))
        self.sendLuaCommand("setAppPath", '_VE_.setAppPath("'+str(os.path.join(self.path, 'assets/images'))+'")')
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Image', "+"'"+str(path)+"')")
        return True

    def clone(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Clone')")
        return True

    def group(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Group')")
        return True

    def ungroup(self):
        self.sendLuaCommand("ungroup", "_VE_.ungroup('"+str(self._inspector.curLayerGid)+"')")
        return True

    def delete(self):
        self.sendLuaCommand("delete", "_VE_.delete('"+str(self._inspector.curLayerGid)+"')")
        return True

    def duplicate(self):
        self.sendLuaCommand("duplicate", "_VE_.duplicate('"+str(self._inspector.curLayerGid)+"')")
        return True

    def rectangle(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Rectangle')")
        return True

    def left(self):
        self.sendLuaCommand("alignLeft", "_VE_.alignLeft('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def right(self):
        self.sendLuaCommand("alignRight", "_VE_.alignRight('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def top(self):
        self.sendLuaCommand("alignTop", "_VE_.alignTop('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def bottom(self):
        self.sendLuaCommand("alignButtom", "_VE_.alignButtom('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def horizontalCenter(self):
        self.sendLuaCommand("horizontalCenter", "_VE_.alignHorizontalCenter('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def verticalCenter(self):
        self.sendLuaCommand("verticalCenter", "_VE_.alignVerticalCenter('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def distributeHorizontal(self):
        self.sendLuaCommand("distributeHorizontal", "_VE_.distributeHorizontal('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def distributeVertical(self):
        self.sendLuaCommand("distributeVertical", "_VE_.distributeVertical('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def bringToFront(self):
        self.sendLuaCommand("bringToFront", "_VE_.bringToFront('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def bringForward(self):
        self.sendLuaCommand("bringForward", "_VE_.bringForward('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def sendToBack(self):
        self.sendLuaCommand("sendToBack", "_VE_.sendToBack('"+str(self._inspector.curLayerGid)+"')")
        return True
        
    def sendBackward(self):
        self.sendLuaCommand("sendBackward", "_VE_.sendBackward('"+str(self._inspector.curLayerGid)+"')")
        return True

    def stop(self, serverStoped=False, exit=False):
        # send 'q' command and close trickplay process
        self.onExit = exit

        if self._emulatorManager.trickplay.state() == QProcess.Running:
            # Local Debugging / Run 
            self._emulatorManager.trickplay.close()

    
    def debug_started(self):
        print "[VE] Code Editor Started"
        self.ui.fileSystemDock.hide()
        self.windows['images'] = False
        self.ui.InspectorDock.hide()
        self.windows['inspector'] = False
        self.ui.mainMenuDock.hide()
        
    def debug_finished(self, errorCode):
        print "[VE] Code Editor Finished"
        if self.debugger.state() == QProcess.NotRunning :
            self.ui.fileSystemDock.show()
            self.windows['images'] = True
            self.ui.InspectorDock.show()
            self.windows['inspector'] = True
            self.ui.mainMenuDock.show()
            self.run()

    def debug(self):
        if self._emulatorManager.trickplay.state() == QProcess.Running:
            self._emulatorManager.trickplay.close()
        self.debugger.start("python /usr/share/trickplay/debug/start.py \""+str(self.path)+"\"")

    def run(self):
        self.inspector.clearTree()
        self._emulatorManager.run()

    def exit(self):
        self.stop(False, True)
        #self._emulatorManager.stop()
        self.close()

    def editorWindowClicked(self) :
        if self.ui.actionEditor.isChecked() == True :
            self.sendLuaCommand("screenShow", "_VE_.screenShow()")
        else :
            self.sendLuaCommand("screenHide", "_VE_.screenHide()")

    def imagesWindowClicked(self) :
    	if self.windows['images'] == True:
    		self.ui.fileSystemDock.hide()
    		self.windows['images'] = False
    	else :
    		self.ui.fileSystemDock.show()
    		self.windows['images'] = True

    def inspectorWindowClicked(self) :
    	if self.windows['inspector'] == True:
    		self.ui.InspectorDock.hide()
    		self.windows['inspector'] = False
    	else :
    		self.ui.InspectorDock.show()
    		self.windows['inspector'] = True

    def setCurrentProject(self, path, openList = None):
        """
        Initialize widgets on the main window with a given app path
        """
        self.path = path
        if path is not -1:
            self.ui.mainMenuDock.setWindowTitle(QApplication.translate("MainWindow", "TrickPlay VE2 [ "+str(os.path.basename(str(path))+" ]"), None, QApplication.UnicodeUTF8))
            self.currentProject = str(os.path.basename(str(path)))
            #self.sendLuaCommand("setCurrentProject", "_VE_.setCurrentProject("+"'"+os.path.basename(str(path)) +"')")


    def backgroundImage(self):
        path = QFileDialog.getOpenFileName(None, 'Set Background Image Source', str(os.path.join(self.path, 'assets/images')), "*.jpg *.gif *.png")
        if len(path) > 0 :
            path = os.path.basename(str(path))
            self.sendLuaCommand("setAppPath", '_VE_.setAppPath("'+str(os.path.join(self.path, 'assets/images'))+'")')
            self.sendLuaCommand("backgroundImage", "_VE_.backgroundImage("+"'"+str(path)+"')")
        return True

    def smallGrid(self):
        self.sendLuaCommand("smallGrid", "_VE_.smallGrid()")
        return True

    def mediumGrid(self):
        self.sendLuaCommand("mediumGrid", "_VE_.mediumGrid()")
        return True

    def largeGrid(self):
        self.sendLuaCommand("largeGrid", "_VE_.largeGrid()")
        return True

    def white(self):
        self.sendLuaCommand("white", "_VE_.white()")
        return True

    def black(self):
        self.sendLuaCommand("black", "_VE_.black()")
        return True

    def addHorizonGuide(self):
        self.sendLuaCommand("addHorizonGuide", "_VE_.addHorizonGuide()")
        return True

    def addVerticalGuide(self):
        self.sendLuaCommand("addVerticalGuide", "_VE_.addVerticalGuide()")
        return True

    def showGuides(self):
        if self.ui.actionShow_Guides.isChecked() == True :
            self.sendLuaCommand("showGuides", "_VE_.showGuides(false)")
        else :
            self.sendLuaCommand("showGuides", "_VE_.showGuides(true)")
        return True

    def snapToGuides(self):
        if self.ui.actionSnap_to_Guides.isChecked() == True :
            self.sendLuaCommand("snapToGuides", "_VE_.snapToGuides(false)")
        else:
            self.sendLuaCommand("snapToGuides", "_VE_.snapToGuides(true)")
        return True

