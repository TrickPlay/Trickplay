import os, time, sys

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from wizard import Wizard
from UI.MainWindow import Ui_MainWindow
from UI.ImportSkinDialog import Ui_importSkinImages
from Inspector.TrickplayInspector import TrickplayInspector
from ImageFileSystem.TrickplayImageFileSystem import TrickplayImageFileSystem
from EmulatorManager.TrickplayEmulatorManager import TrickplayEmulatorManager
from Inspector.TrickplayElement import TrickplayElement

try:
    _fromUtf8 = QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s


class MainWindow(QMainWindow):
    
    def __init__(self, app, apath=None, parent = None):
        
        self.stitcherErrorCode = {
            1 : 'Could not parse arguments',
            2 : 'No inputs given',
            3 : 'Ambiguous output path',
            4 : 'Segregation size (see --help) cannot be larger than 65,536 x 65,536',
            5 : 'Maximum texture size (see --help) cannot be larger than 65,536 x 65,536',
            201 : 'Could not load JSON file of spritesheet <path>',
            202 : 'Could not parse JSON file of spritesheet <path>',
            203 : 'Could not load spritesheet source image <path>',
            301 : 'Failed to fit all of the images'
        }
            
        self.containerUI = ['Widget_Group', 'ArrowPane', 'MenuButton', 'ScrollPane', 'DialogBox', 'TabBar', 'LayoutManager'] 
        self.skinUI = ["ArrowPane", "ButtonPicker", "Button", "DialogBox", "MenuButton", "RadioButton", "CheckBox", "TabBar", "ToastAlert", "TextInput", "ScrollPane", "Slider", "ProgressBar", "OrbitingDots", "ProgressSpinner", "ClippingRegion"]
        self.uiElements = ["ArrowPane", "ButtonPicker", "Button", "DialogBox", "MenuButton", "RadioButton", "CheckBox", "TabBar", "LayoutManager", "ToastAlert", "TextInput", "ScrollPane", "Slider", "ProgressBar", "OrbitingDots", "ProgressSpinner", "Sprite", "Text", "Rectangle"]

        self.skinPath = {"ArrowPane": ['arrow-up', 'arrow-down', 'arrow-right', 'arrow-left', 'default'],  
         "ButtonPicker": ['arrow-up', 'arrow-down', 'arrow-right', 'arrow-left', 'default'],  
         "Button": ['default', 'activation', 'focus'],  
         "DialogBox": ['default', 'seperator-h.png'],  
         "MenuButton": ['default', 'activation', 'focus'],  
         "RadioButton": ['default', 'activation', 'focus', 'selection', 'box-focus.png', 'box-default.png','box-selected.png', 'box-focus-selected.png'],  
         "CheckBox": ['default', 'activation', 'focus', 'selection', 'radio-focus.png', 'radio-default.png','radio-selected.png', 'radio-focus-selected.png'],  
         "TabBar": ['arrow-up', 'arrow-down', 'arrow-right', 'arrow-left', 'default', 'activation', 'focus', 'selection'],  
         "ToastAlert": ['default', 'seperator-h.png', 'error.png'],  
         "TextInput": ['default', 'focus'],  
         "ScrollPane": ['default', 'track', 'grip/default', 'grip/focus'],  
         "Slider": ['track', 'grip/default', 'grip/focus'],  
         "ProgressBar": ['empty', 'filled'], 
         "OrbitingDots": ['icon.png'], 
         "ProgressSpinner": ['icon.png'], 
         "ClippingRegion": ['default'],  
        }
        self.skinPathList = self.skinPath.items()

        self.skinSubPath = {'arrow-up':['default.png', 'focus.png', 'activation.png'],
            'arrow-down':['default.png', 'focus.png', 'activation.png'],
            'arrow-right':['default.png', 'focus.png', 'activation.png'],
            'arrow-left':['default.png', 'focus.png', 'activation.png'],
            'default':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'grip/default':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'activation':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png'], 
            'focus':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'grip/focus':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'selection':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'empty':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'filled':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'], 
            'track':['se.png','sw.png','ne.png','nw.png','n.png','e.png','w.png','s.png','c.png'] 
        }

        #Progress Bar for image/skin importing
        self.bar = None

        #Trickplay Lua Emulator, default position
        self.luaEy = 300
        self.luaEx = 500

        QWidget.__init__(self, parent)
        
        #VE path 
        self.apath = apath 

        #Visual Debugger 
        self.debugger = QProcess()
        QObject.connect(self.debugger, SIGNAL('started()'), self.debug_started)
        QObject.connect(self.debugger, SIGNAL('finished(int)'), self.debug_finished)

        #Stitcher 
        self.stitcher = QProcess()
        QObject.connect(self.stitcher, SIGNAL('started()'), self.stitcher_started)
        QObject.connect(self.stitcher, SIGNAL('finished(int)'), self.stitcher_finished)
        QObject.connect(self.stitcher, SIGNAL('readyReadStandardError()'), self.stitcher_stdError)
        QObject.connect(self.stitcher, SIGNAL('readyRead()'), self.import_readyRead)

        #MainWindow UI
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.resize(0,0)

        self.windows = {"inspector":False, "images":False}

        # Create Inspector
        self._inspector = TrickplayInspector(self)
        self._inspector.setWindowTitle('Inspector')
        self.ui.actionInspector.toggled.connect(self.inspectorWindowClicked)

        self.inspectorWindowClicked()

        # Create Image File System
        self._ifilesystem = TrickplayImageFileSystem(self)
        self._ifilesystem.setWindowTitle('Images')
        self.ui.actionImages.toggled.connect(self.imagesWindowClicked)

        self.imagesWindowClicked()

        #Create main menu 
        class menubarWidget(QWidget):
            def __init__(self):
                flags = Qt.Tool | Qt.WindowStaysOnTopHint #| Qt.FramelessWindowHint
                if sys.platform == "darwin":
                    flags |= Qt.WA_MacAlwaysShowToolWindow
                else:
                    flags |= Qt.X11BypassWindowManagerHint

                QWidget.__init__(self, None, flags )

        self._menubar = menubarWidget()

        self.mainMenuLayout = QGridLayout()
        self.mainMenuLayout.setSpacing(0)
        self.mainMenuLayout.setMargin(0)
        self.mainMenuLayout.setObjectName(_fromUtf8("mainMenuLayout"))
        self.mainMenuLayout.addWidget(self.ui.menubar)
        self.ui.menubar.setNativeMenuBar(False)
        self._menubar.setLayout(self.mainMenuLayout)

        self._menubar.show()
        self.menuDisable()

        # Create EmulatorManager
        self.ui.actionEditor.toggled.connect(self.editorWindowClicked)
        self._emulatorManager = TrickplayEmulatorManager(self) 
        self._inspector.emulatorManager = self._emulatorManager

		#File Menu
        #QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        self.ui.action_Exit.triggered.connect(self.exit)
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
        QObject.connect(self.ui.actionWidgetRectangle, SIGNAL("triggered()"),  self.rectangle)

        QObject.connect(self.ui.actionGroup, SIGNAL("triggered()"),  self.group)
        QObject.connect(self.ui.actionUngroup, SIGNAL("triggered()"),  self.ungroup)
        QObject.connect(self.ui.actionClone, SIGNAL("triggered()"),  self.clone)
        QObject.connect(self.ui.actionDuplicate, SIGNAL("triggered()"),  self.duplicate)
        QObject.connect(self.ui.actionDelete, SIGNAL("triggered()"),  self.delete)

		#Arrange Menu
        QObject.connect(self.ui.action_left, SIGNAL("triggered()"),  self.left)
        self.ui.action_left.setIconVisibleInMenu(True)
        left_icon = QIcon()
        left_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-left.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_left.setIcon(left_icon)

        QObject.connect(self.ui.action_right, SIGNAL("triggered()"),  self.right)
        self.ui.action_right.setIconVisibleInMenu(True)
        right_icon = QIcon()
        right_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-right.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_right.setIcon(right_icon)

        QObject.connect(self.ui.action_top, SIGNAL("triggered()"),  self.top)
        self.ui.action_top.setIconVisibleInMenu(True)
        top_icon = QIcon()
        top_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-top.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_top.setIcon(top_icon)

        QObject.connect(self.ui.action_bottom, SIGNAL("triggered()"),  self.bottom)
        self.ui.action_bottom.setIconVisibleInMenu(True)
        bottom_icon = QIcon()
        bottom_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-bottom.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_bottom.setIcon(bottom_icon)

        QObject.connect(self.ui.action_horizontalCenter, SIGNAL("triggered()"),  self.horizontalCenter)
        self.ui.action_horizontalCenter.setIconVisibleInMenu(True)
        hCenter_icon = QIcon()
        hCenter_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-hcenter.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_horizontalCenter.setIcon(hCenter_icon)

        QObject.connect(self.ui.action_verticalCenter, SIGNAL("triggered()"),  self.verticalCenter)
        self.ui.action_verticalCenter.setIconVisibleInMenu(True)
        vCenter_icon = QIcon()
        vCenter_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-vcenter.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_verticalCenter.setIcon(vCenter_icon)

        QObject.connect(self.ui.action_distributeHorizontally, SIGNAL("triggered()"),  self.distributeHorizontal)
        self.ui.action_distributeHorizontally.setIconVisibleInMenu(True)
        distH_icon = QIcon()
        distH_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-distributeh.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_distributeHorizontally.setIcon(distH_icon)

        QObject.connect(self.ui.action_distributeVertically, SIGNAL("triggered()"),  self.distributeVertical)
        self.ui.action_distributeVertically.setIconVisibleInMenu(True)
        distV_icon = QIcon()
        distV_icon.addPixmap(QPixmap(self.apath+"/Assets/icons/icon-align-distributev.png"), QIcon.Disabled, QIcon.Off)
        self.ui.action_distributeVertically.setIcon(distV_icon)

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
        settings = QSettings()
        if settings.value('mainMenuDock') and settings.value('inspectorDock') and settings.value('fileSystemDock') :
            self._menubar.setGeometry((settings.value('mainMenuDock').toRect()))
            self._inspector.setGeometry((settings.value('inspectorDock').toRect()))
            self._ifilesystem.setGeometry((settings.value('fileSystemDock').toRect()))
        else :
            self._menubar.setGeometry(self.luaEx,self.luaEy-85,670,100)
            self._inspector.setGeometry(self.luaEx+965,self.luaEy-25,330,570)
            self._ifilesystem.setGeometry(self.luaEx-335,self.luaEy-25,330,570)

        self.path =  None 
        self.app = app
        self.command = None
        self.currentProject = None

        app.aboutToQuit.connect(self.exit)

    @property
    def emulatorManager(self):
        return self._emulatorManager
    
    @property
    def inspector(self):
        return self._inspector

    @property
    def menubar(self):
        return self._menubar

    @property
    def ifilesystem(self):
        return self._ifilesystem

    def menuEnable (self):
        self.ui.action_left.setEnabled(True)
        self.ui.action_right.setEnabled(True)
        self.ui.action_top.setEnabled(True)
        self.ui.action_bottom.setEnabled(True)
        self.ui.action_horizontalCenter.setEnabled(True)
        self.ui.action_verticalCenter.setEnabled(True)
        self.ui.action_distributeHorizontally.setEnabled(True)
        self.ui.action_distributeVertically.setEnabled(True)
        self.ui.action_bring_to_front.setEnabled(True)
        self.ui.action_bring_to_forward.setEnabled(True)
        self.ui.action_send_to_back.setEnabled(True)
        self.ui.action_send_backward.setEnabled(True)
        self.ui.actionGroup.setEnabled(True)
        self.ui.actionUngroup.setEnabled(True)
        self.ui.actionClone.setEnabled(True)
        self.ui.actionDuplicate.setEnabled(True)
        self.ui.actionDelete.setEnabled(True)

    def menuDisableContents (self):
        self.ui.action_left.setDisabled(True)
        self.ui.action_right.setDisabled(True)
        self.ui.action_top.setDisabled(True)
        self.ui.action_bottom.setDisabled(True)
        self.ui.action_horizontalCenter.setDisabled(True)
        self.ui.action_verticalCenter.setDisabled(True)
        self.ui.action_distributeHorizontally.setDisabled(True)
        self.ui.action_distributeVertically.setDisabled(True)
        self.ui.action_bring_to_front.setDisabled(True)
        self.ui.action_bring_to_forward.setDisabled(True)
        self.ui.action_send_to_back.setDisabled(True)
        self.ui.action_send_backward.setDisabled(True)
        self.ui.actionGroup.setDisabled(True)
        self.ui.actionUngroup.setDisabled(True)
        self.ui.actionClone.setDisabled(True)
        self.ui.actionDuplicate.setDisabled(True)
        self.ui.actionDelete.setEnabled(True)

    def menuDisable (self):
        self.ui.action_left.setDisabled(True)
        self.ui.action_right.setDisabled(True)
        self.ui.action_top.setDisabled(True)
        self.ui.action_bottom.setDisabled(True)
        self.ui.action_horizontalCenter.setDisabled(True)
        self.ui.action_verticalCenter.setDisabled(True)
        self.ui.action_distributeHorizontally.setDisabled(True)
        self.ui.action_distributeVertically.setDisabled(True)
        self.ui.action_bring_to_front.setDisabled(True)
        self.ui.action_bring_to_forward.setDisabled(True)
        self.ui.action_send_to_back.setDisabled(True)
        self.ui.action_send_backward.setDisabled(True)
        self.ui.actionGroup.setDisabled(True)
        self.ui.actionUngroup.setDisabled(True)
        self.ui.actionClone.setDisabled(True)
        self.ui.actionDuplicate.setDisabled(True)
        self.ui.actionDelete.setDisabled(True)

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
        self._emulatorManager.unsavedChanges = True
        return True

    def errorMsg(self, eMsg):
        msg = QMessageBox()
        msg.setText(eMsg)
        msg.setStandardButtons(QMessageBox.Ok)
        msg.setDefaultButton(QMessageBox.Ok)
        msg.setWindowTitle("Error")
        msg.setGeometry(self._menubar.geometry().x() + 100, self._menubar.geometry().y() + 200, msg.geometry().width(), msg.geometry().height())
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
        msg.setGeometry(self._menubar.geometry().x() + 100, self._menubar.geometry().y() + 200, msg.geometry().width(), msg.geometry().height())
        ret = msg.exec_()
        if ret == QMessageBox.Save:
            self.saveProject()
            time.sleep(0.1)
        elif ret == QMessageBox.Cancel:
            return False
        return True
        
    def stitcher_started(self):
        if self.bar is not None :
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

    def stitcher_stdError(self):
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
                        
                if self.bar is not None:
                    self.bar.setValue(newVal)
                print "[VE] progressBar.setValue : %s  "%str(newVal)
            except : 
                pass

        else:
            print str(s.data())

    def stitcher_finished(self, errorCode):
        if errorCode == 0 : 
            if self.bar is not None and self.importCmd is not "remove":
                print "[VE] progressBar.setValue : %s  "%'100'
                self.bar.setValue(100)
                self.bar.hide()
            if self.importCmd is "assets" :
                self.sendLuaCommand("buildVF", '_VE_.buildVF()')

        else : 
            if self.bar is not None:
                self.bar.hide()
            errorMsg = str(self.stitcher.readAllStandardError().data())
            if self.stitcherErrorCode[int(errorCode)]:
                self.errorMsg(self.stitcherErrorCode[int(errorCode)])
            else :
                self.errorMsg("Import Failed.")
        return 

    def processErrorHandler(self, process_name):
        if process_name == "stitcher" :
            if self.stitcher.error() == QProcess.FailedToStart :
                self.errorMsg("Import helper failed to launch: check TrickPlay SDK installation") 
            elif self.stitcher.error() == QProcess.Timedout :
                self.errorMsg("Import helper launch timed out: check TrickPlay SDK installation") 
        elif process_name == "trickplay" :
            if self._emulatorManager.trickplay.error() == QProcess.FailedToStart :
                self.errorMsg("TrickPlay engine failed to launch: check TrickPlay SDK installation") 
            elif self._emulatorManager.trickplay.error() == QProcess.Timedout :
                self.errorMsg("TrickPlay engine launch timed out: check TrickPlay SDK installation") 
        elif process_name == "debugger" :
            if self.debugger.error() == QProcess.FailedToStart :
                self.errorMsg("Visual Debugger helper failed to launch: check TrickPlay SDK installation") 
            elif self.debugger.error() == QProcess.Timedout :
                self.errorMsg("Visual Debugger helper launch timed out: check TrickPlay SDK installation") 

    def importAssets(self):
        self.importCmd = "assets"
        self._ifilesystem.imageCommand = "assets"
        path = -1 

        self.bar = QProgressBar()
        self.bar.setRange(0, 100)
        self.bar.setValue(0)
        self.bar.setWindowTitle("Import Assets...")
        self.bar.setGeometry(self._ifilesystem.geometry().x() + 200, self._ifilesystem.geometry().y() + 100, 300, 20)

        while path == -1 :
            if self.path is None:
		        self.path = self.apath
            path = QFileDialog.getExistingDirectory(None, 'Import Asset Images', self.path, QFileDialog.ShowDirsOnly)

        if path:
            print ("[VE] Import Asset Images ...[%s]"%path)

            if os.path.exists(os.path.join(self.path, "assets/images/images.json")) == True:
                print("[VE] stitcher -rpd -m '"+str(os.path.join(self.path, "assets/images/images.json"))+"' -o '"+str(os.path.join(self.path, "assets/images"))+"/images' "+path)
                self.stitcher.start("stitcher -rpd -m \""+str(os.path.join(self.path, "assets/images/images.json"))+"\" -o \""+str(os.path.join(self.path, "assets/images"))+"/images\" \""+path+"\"")
                ret = self.stitcher.waitForStarted()
                if ret == False :
                    self.processErrorHandler("stitcher")
            else:
                print("[VE] stitcher -rpd -o \""+str(os.path.join(self.path, "assets/images"))+"/images\" "+path)
                self.stitcher.start("stitcher -rpd -o \""+str(os.path.join(self.path, "assets/images"))+"/images\" \""+path+"\"")
                ret = self.stitcher.waitForStarted()
                if ret == False :
                    self.processErrorHandler("stitcher")

    def chooseDirectoryDialog(self, dir=None):

        if self.path is None:
            self.path = self.apath
        path = QFileDialog.getExistingDirectory(None, 'Import Skin Images', self.path, QFileDialog.ShowDirsOnly)

        if path :
            self.uiD.directory.setText(path)
            self.uiD.id.setReadOnly(False)

        return path

    def idChanged(self, change):
        self.id = change

    def importSkinDialog(self, path=None, id=None, name=None):
        """
        New app dialog
        """
        self.dialog = QDialog() 
        self.id = ""
        self.name = ""
        self.uiD = Ui_importSkinImages()
        self.uiD.setupUi(self.dialog)

        if path is not None :
            self.uiD.directory.setText(path)
        

        cancelButton = self.uiD.buttonBox.button(QDialogButtonBox.Cancel)
        okButton = self.uiD.buttonBox.button(QDialogButtonBox.Ok)
        self.dialog.setGeometry(self._ifilesystem.geometry().x() + 200, self._ifilesystem.geometry().y() + 200, self.dialog.geometry().width(), self.dialog.geometry().height())

        QObject.connect(self.uiD.browse, SIGNAL('clicked()'), self.chooseDirectoryDialog)

        if id is not None:
            self.uiD.id.setText(id)

        if self.dialog.exec_():            
            id = str(self.uiD.id.text())
            path = str(self.uiD.directory.text())

            if '' == id or '' == name or path == "source image directory" :
                return self.importSkinDialog(path, id, name)
        return path, id 

    def importSkinErrorMsg(self, sUIs, fUIs):
        msg = QMessageBox()
        errorMsg = "" 

        if len (sUIs) is not 0:
            errorMsg = "Skin assets are available for the following UI Elements: \n\n"
            i = 1 
            for j in sUIs:
                if j == "TabBar" and errorMsg[-1:] != "\n": 
                    errorMsg = errorMsg[:len(errorMsg)-1]
                    errorMsg = errorMsg + j + "\t\t"
                elif len(j) > 10 :
                    errorMsg = errorMsg + j + "\t"
                else:
                    errorMsg = errorMsg + j + "\t\t"
                if i % 3 == 0 :
                    errorMsg = errorMsg + "\n"
                i = i + 1 

            errorMsg = errorMsg + "\n\n"

        errorMsg = errorMsg + "Could not find skin assets for the following UI Elements: \n\n"
        j = 1 
        for i in fUIs:
            if i == "TabBar" and errorMsg[-1:] != "\n": 
                errorMsg = errorMsg[:len(errorMsg)-1]
                errorMsg = errorMsg + i + "\t\t"
            elif len(i) > 10 :
                errorMsg = errorMsg + i + "\t"
            else:
                errorMsg = errorMsg + i + "\t\t"
            if j % 3 == 0 :
                errorMsg = errorMsg + "\n"
            j = j + 1 

        errorMsg = errorMsg + "\n\nDo you want to proceed ?\n"
        msg.setText(errorMsg)
        msg.setStandardButtons(QMessageBox.Yes|QMessageBox.No)
        msg.setDefaultButton(QMessageBox.Yes)
        msg.setWindowTitle("Import Skin Error")
        ret = msg.exec_()
        if ret == QMessageBox.Yes:
            return True 
        else:
            return False 
            

    def checkSkinAssetsExist(self, path):
        
        id1 = ""
        id2 = ""
        uiName = ""
        failedUI = []
        succeedUI = self.skinUI

        for i, v in self.skinPathList:
            uiName = i 
            for j in v:
                id1 = j
                if self.skinSubPath.has_key(j) == True :
                    for x in self.skinSubPath[j]:
                        id2 = x
                        if os.path.exists(os.path.join(path, uiName+"/"+id1+"/"+id2)) == False:
                            if not uiName in failedUI:
                                failedUI.insert(0, uiName)
                else:
                    if os.path.exists(os.path.join(path, uiName+"/"+id1)) == False:
                        if not uiName in failedUI:
                            failedUI.insert(0, uiName)

        if len(failedUI) == 0 :
            return True
        else :
            for l in failedUI:
                if l in succeedUI:
                    succeedUI.remove(l)

            return self.importSkinErrorMsg(succeedUI, failedUI)

    def importSkins(self):
        self.importCmd = "skins"
        self._ifilesystem.imageCommand = "skins"
        self.bar = QProgressBar()
        self.bar.setRange(0, 100)
        self.bar.setValue(0)
        self.bar.setWindowTitle("Import Skin...")
        self.bar.setGeometry(self._ifilesystem.geometry().x() + 200, self._ifilesystem.geometry().y() + 100, 300, 20)

        skinPath, id = self.importSkinDialog()
        if skinPath:
            print ("[VE] Import Skin Images ...[%s]"%skinPath)
            if self.checkSkinAssetsExist(skinPath) != True :
                return 

        if os.path.exists(os.path.join(self.path, "assets/skins/"+id+".json")) == True:
            print("[VE] stitcher -rpd -m '"+str(os.path.join(self.path, "assets/skins/"+id+".json"))+"' -o '"+str(os.path.join(self.path, "assets/skins"))+"/'"+id+" "+skinPath)
            self.stitcher.start("stitcher -rpd -m \""+str(os.path.join(self.path, "assets/skins/"+id+".json"))+"\" -o \""+str(os.path.join(self.path, "assets/skins"))+"/"+id+"\" \""+skinPath+"\"")
            ret = self.stitcher.waitForStarted()
            if ret == False :
                self.processErrorHandler("stitcher")
        else:
            print("[VE] stitcher -rpd -o \'"+str(os.path.join(self.path, "assets/skins"))+"/"+id+"\' "+skinPath)
            self.stitcher.start("stitcher -rpd -o \""+str(os.path.join(self.path, "assets/skins"))+"/"+id+"\" \""+skinPath+"\"")
            ret = self.stitcher.waitForStarted()
            if ret == False :
                self.processErrorHandler("stitcher")

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
            self.menuCommand = "newProject"

            self._ifilesystem.ui.fileSystemTree.clear()
            self._ifilesystem.orgCnt = 0
            self._ifilesystem.idCnt = 0

            while self.inspector.ui.screenCombo.count() > 0 :
                curIdx = self.inspector.ui.screenCombo.currentIndex()
                self.inspector.ui.screenCombo.removeItem(curIdx)

            self.inspector.ui.screenCombo.addItem("Default")
            self.inspector.screens = {"_AllScreens":[],"Default":[]}

            return True

    def openProject(self):
        if self._emulatorManager.unsavedChanges == True :
            if self.warningMsg() == False:
                return

        wizard = Wizard(self)
        path = -1
        while path == -1 :
            if self.path is None:
		        self.path = self.apath
            path = QFileDialog.getExistingDirectory(None, 'Open Project', self.path, QFileDialog.ShowDirsOnly)
            if path == None or path == "":
                return 
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
        index = self._inspector.selected (self.inspector.ui.inspector)
        while index is not None:
            item = self._inspector.inspectorModel.itemFromIndex(index)
            self.sendLuaCommand("clone", "_VE_.clone('"+str(item['gid'])+"')")
            self._inspector.deselectItem(item)
            self.command = "clone"
            index = self._inspector.selected (self.inspector.ui.inspector)
        return True

    def group(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement('"+str(self._inspector.curLayerGid)+"', 'Group')")
        return True

    def ungroup(self):
        self.sendLuaCommand("ungroup", "_VE_.ungroup('"+str(self._inspector.curLayerGid)+"')")
        curLayerItem = self._inspector.search(self._inspector.curLayerGid, 'gid')
        index = self._inspector.selected (self.inspector.ui.inspector)
        while index is not None:
            item = self._inspector.inspectorModel.itemFromIndex(index)
            try:
                if item['type'] == "Widget_Group" :
                    for c in item['children']:
                        self._inspector.inspectorModel.insertElement(curLayerItem, c, curLayerItem.TPJSON(), False)
                    item.parent().removeRow(item.row())
            except:
                pass
            index = self._inspector.selected (self.inspector.ui.inspector)
        return True

    def delete(self):
        index = self._inspector.selected (self.inspector.ui.inspector)
        while index is not None:
            item = self._inspector.inspectorModel.itemFromIndex(index)
            self.sendLuaCommand("delete", "_VE_.delete('"+str(item['gid'])+"')")
            if "Row" in item.parent().text() :
                emptynode = TrickplayElement("Empty")
                emptynode.setFlags(emptynode.flags() ^ Qt.ItemIsEditable)
                partner = emptynode.partner()
                partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
                partner.setData("", Qt.DisplayRole) 
                item.parent().appendRow([emptynode, partner])
                item.parent().removeRow(item.row())
                index = None
            else:
                item.parent().removeRow(item.row())
                index = self._inspector.selected (self.inspector.ui.inspector)
        return True

    def duplicate(self):
        index = self._inspector.selected (self.inspector.ui.inspector)
        while index is not None:
            item = self._inspector.inspectorModel.itemFromIndex(index)
            self.sendLuaCommand("duplicate", "_VE_.duplicate('"+str(item['gid'])+"')")
            self._inspector.deselectItem(item)
            self.command = "duplicate"
            index = self._inspector.selected (self.inspector.ui.inspector)
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
        self.sendLuaCommand("alignBottom", "_VE_.alignBottom('"+str(self._inspector.curLayerGid)+"')")
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
        self._ifilesystem.hide()
        self.windows['images'] = False
        self._inspector.hide()
        self.windows['inspector'] = False
        
    def debug_finished(self, errorCode):
        print "[VE] Code Editor Finished"
        if self.debugger.state() == QProcess.NotRunning :
            self._ifilesystem.show()
            self.windows['images'] = True
            self._inspector.show()
            self.windows['inspector'] = True
            self.run()
            if errorCode == 2 : 
                self.errorMsg("Visual Debugger launch failed : check TrickPlay SDK installation") 
            else :
                if self.debugger.exitStatus() is not QProcess.NormalExit and self.debugger.exitStatus() != 0:
                    self.errorMsg("Visual Debugger launch failed : check TrickPlay SDK installation") 

    def debug(self):
        if self._emulatorManager.trickplay.state() == QProcess.Running:
            if self._emulatorManager.unsavedChanges == True :
                self.warningMsg()
            self._emulatorManager.trickplay.close()
        self.debugger.start("python /usr/share/trickplay/debug/start.py \""+str(self.path)+"\"")
        ret = self.debugger.waitForStarted()
        if ret == False :
            self.processErrorHandler("debugger")

    def run(self):
        self.inspector.clearTree()
        self._emulatorManager.run()

    def exit(self):

        self.sendLuaCommand("getScreenLoc", "_VE_.getScreenLoc()")

        settings = QSettings()
        settings.setValue("mainMenuDock", self._menubar.geometry());
        settings.setValue("inspectorDock", self._inspector.geometry());
        settings.setValue("fileSystemDock", self._ifilesystem.geometry());
        time.sleep(0.1)

        settings.setValue("x", self.x)
        settings.setValue("y", self.y)

        if self._emulatorManager.trickplay.state() == QProcess.Running:
            if self._emulatorManager.unsavedChanges == True :
                if self.warningMsg() == False :
                    return True
            self.stop(False, True)
            self.close()
        sys.exit(0)

        return True

    def editorWindowClicked(self) :
        if self.ui.actionEditor.isChecked() == True :
            self.sendLuaCommand("screenShow", "_VE_.screenShow()")
        else :
            self.sendLuaCommand("screenHide", "_VE_.screenHide()")

    def imagesWindowClicked(self) :
    	if self.windows['images'] == True:
    		self._ifilesystem.hide()
    		self.windows['images'] = False
    	else :
    		self._ifilesystem.show()
    		self.windows['images'] = True

    def inspectorWindowClicked(self) :
    	if self.windows['inspector'] == True:
    		self._inspector.hide()
    		self.windows['inspector'] = False
    	else :
    		self._inspector.show()
    		self.windows['inspector'] = True

    def setCurrentProject(self, path, openList = None):
        """
        Initialize widgets on the main window with a given app path
        """
        self.path = path
        if path is not -1:
            self._menubar.setWindowTitle(QApplication.translate("MainWindow", "TrickPlay VE2 [ "+str(os.path.basename(str(path))+" ]"), None, QApplication.UnicodeUTF8))
            self.currentProject = str(os.path.basename(str(path)))
            self.sendLuaCommand("setCurrentProject", "_VE_.setCurrentProject("+"'"+os.path.basename(str(path)) +"')")


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

