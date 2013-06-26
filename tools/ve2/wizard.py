import sys
import os
import shutil
import re

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from UI.NewProjectDialog import Ui_newProjectDialog

APP = """
    id          = "{0}",
    release     = "1",
    version     = "0.1",
    name        = "{1}",
    copyright   = "",
"""

VE_NEW_PROJECT_ROLE = 0
VE_OPEN_PROJECT_ROLE = 1

# To add dialog background image later ?
class MyDialog(QDialog):
    def __init__(self):
        QDialog.__init__(self)

    def paintEvent(self, event):
        pass

# Could use QWizard, but this is simpler
class Wizard():

    # font
    font = QFont()
    font.setPointSize(10)

    def __init__(self, mainWindow = None):
        self.mainWindow = mainWindow
        self.id = None
        self.name = None
        self.new = None

    def filesToOpen(self):
        return self.openList

    def warningMsg(self, title = "Warning", message=None):
        if message is not None:
            msg = QMessageBox()
            msg.setWindowFlags(Qt.WindowStaysOnTopHint)
            msg.setText(message)
            msg.addButton("New Project" , VE_NEW_PROJECT_ROLE)
            msg.addButton("Open Project" , VE_OPEN_PROJECT_ROLE)
            msg.setWindowTitle(title)
            msg.setGeometry(self.mainWindow._menubar.geometry().x() + 100, self.mainWindow._menubar.geometry().y() + 200, msg.geometry().width(), msg.geometry().height())

            ret = msg.exec_()
            if ret == VE_NEW_PROJECT_ROLE:
                self.mainWindow.newProject()
            elif ret == VE_OPEN_PROJECT_ROLE:
                self.mainWindow.openProject()
            return

    def start(self, path, openApp=False, newApp=False):

        self.openList = None

        # Check settings for the last path used
        settings = QSettings()
        dir = str(settings.value('path', '').toString())

        # If path is None
        if not path and newApp == False:
            if os.path.exists(dir) and os.path.isdir(dir):
                files = os.listdir(dir)
                if len(files) <= 0:
                    self.warningMsg("Error", 'Directory "' + dir + '" is not valid. it does not contain an "app" file and a "main.lua" file.')
                    return
                else:
                    if 'app' in files and 'main.lua' in files:
                        return dir
                    else:
                        self.warningMsg("Error", 'Directory "' + dir + '" does not contain an "app" file or a "main.lua" file.')
                        return
            else:
                self.warningMsg("Error", 'Directory "' + dir + '" does not exist.')
                return

        # Get a path from the user
        if openApp == False and newApp == True:

            userPath = self.createAppDialog()

            if userPath and userPath is not -1:
                print('[VE] New App Path : ' + str(userPath))
            elif userPath == -1:
                return -1
            else:
                print('[VE] App Path Error')
                return

            if os.path.exists(userPath):

                if os.path.isdir(userPath):

                    files = os.listdir(userPath)

                    # If the directory is empty, start the app creator
                    if len(files) <= 0:
                        return self.createAppDialog()

                    if 'app' in files and 'main.lua' in files:
                        #return self.start(path, True, False)
                        return userPath
                    else:
                        self.warningMsg("Error", 'Directory "' + os.path.basename(str(userPath)) + '" does not contain an "app" file or a "main.lua" file.')
                        return self.start(None)

        # Path was given on command line
        else:

            if os.path.exists(path) and os.path.isdir(path):
                files = os.listdir(path)
                if len(files) <= 0:
                    self.warningMsg("Error", 'Directory "' + os.path.basename(str(path)) + '" does not contain an "app" file and a "main.lua" file.')
                    return
                    #return self.createAppDialog(path)
                else:
                    if 'app' in files and 'main.lua' in files:
                        return path
                    else:
                        self.warningMsg("Error", 'Directory "' + os.path.basename(str(path)) + '" does not contain an "app" file and a "main.lua" file.')
                        return

            else:
                print('[VE] Error - ' + path + ' is not existing directory.')

    def lineSplit(self, line):
        """
        TODO: Find the id/name in a better way...
        """
        s = line.split('"')
        if len(s) == 3:
            return s
        else:
            s = line.split("'")
            if len(s) == 3:
                return s

    def scan(self, path):
        """
        Scan the path given:
        If invalid app dir, return -4
        If invalid app file, return -3
        If user cancels the dialog, return -2
        If non-empty with no app and main.lua, return -1
        If empty, return 0
        If app and main.lua exist, return 1
        """

        if os.path.isdir(path):

            try:
                files = os.listdir(path)
            except:
                return -4


            # If the directory is empty, allow the user to change id and name
            if len(files) <= 0:
                return 0

            if 'app' in files and 'main.lua' in files:
                f = open(os.path.join(path, 'app'))

                id = None
                name = None
                try:
                    app = f.read()
                    idLine = re.search('''id\s*=\s*['"].*['"]\s*[,]''', app).group(0)[:-1]
                    nameLine = re.search('''name\s*=\s*['"].*['"]\s*[,]''', app).group(0)[:-1]
                    id = self.lineSplit(idLine)[1]
                    name = self.lineSplit(nameLine)[1]
                    self.id = id
                    self.name = name
                    return 1
                except:
                    print('invalid app')
                    return -3

            else:
                #print("U",path)
                return -1

        else:
            # not a valid directory
            return -2

    def adjustDialog(self, path, dir=None):

        result = self.scan(str(path))

        # If the path is a directory...
        if dir is None :
            if 0 == result:
                self.ui.id.setReadOnly(False)
                self.ui.name.setReadOnly(False)
                self.new = True
            elif 1 == result:
                self.ui.id.setReadOnly(True)
                self.ui.name.setReadOnly(True)
                #self.ui.id.setText(self.id)
                #self.ui.name.setText(self.name)
                self.new = False

            if -1 == result:
                self.warningMsg("Error", 'Directory "' + os.path.basename(str(path)) + '" does not contain an "app" file and a "main.lua" file.')
        return result


    def chooseDirectoryDialog(self, dir=None):
        """
        User chooses a directory:
        If the directory is empty, then they must fill in Name and Id
        If the directory is not empty, it must have an 'app' and 'main.lua'
        """

        # Open the browser, wait for it to close
        if dir is None:
            directory = self.ui.directory.text()
        else :
            directory = dir


        return self.mainWindow.openFileDialog('Choose a directory for your app', self.mainWindow.path)

    # whenever user edit id and name line editor, change the label-selfe.ui.projectDirName.
    def idChanged(self, change):
        self.id = change
        self.ui.projectDirName.setText(self.id+"."+self.name)


    def nameChanged(self, change):
        self.name = change
        self.ui.projectDirName.setText(self.id+"."+self.name)

    def copytree(self, src, dst, symlinks=False):
        names = os.listdir(src)
        os.makedirs(dst)
        errors = []
        for name in names:
            srcname = os.path.join(src, name)
            dstname = os.path.join(dst, name)
            try:
                if symlinks and os.path.islink(srcname):
                    linkto = os.readlink(srcname)
                    os.symlink(linkto, dstname)
                elif os.path.isdir(srcname):
                    copytree(srcname, dstname, symlinks)
                else:
                    copy2(srcname, dstname)
                # XXX What about devices, sockets etc.?
            except (IOError, os.error) as why:
                errors.append((srcname, dstname, str(why)))
            # catch the Error from the recursive copytree so that we can
            # continue with other files
            except Error as err:
                errors.extend(err.args[0])
        try:
            copystat(src, dst)
        except WindowsError:
            # can't copy file access times on Windows
            pass
        except OSError as why:
            errors.extend((src, dst, str(why)))
        if errors:
            raise Error(errors)

    def createAppDialog(self, path=None, id=None, name=None):
        """
        New app dialog
        """
        self.dialog = MyDialog() #QDialog
        self.dialog.setWindowFlags(Qt.WindowStaysOnTopHint)
        self.id = ""
        self.name = ""
        self.ui = Ui_newProjectDialog()
        self.ui.setupUi(self.dialog)
        if path is not None :
            self.ui.directory.setText(path)

        #self.adjustDialog(path)
        cancelButton = self.ui.buttonBox.button(QDialogButtonBox.Cancel)
        okButton = self.ui.buttonBox.button(QDialogButtonBox.Ok)

        QObject.connect(self.ui.browse, SIGNAL('clicked()'), self.chooseDirectoryDialog)
        QObject.connect(self.ui.id, SIGNAL("textChanged(QString)"), self.idChanged)
        QObject.connect(self.ui.name, SIGNAL("textChanged(QString)"), self.nameChanged)
        QObject.connect(cancelButton, SIGNAL('clicked()'), self.quiet_exit)
        QObject.connect(okButton, SIGNAL('clicked()'), self.quiet_exit)

        self.dialog.setGeometry(self.mainWindow._menubar.geometry().x() + 100, self.mainWindow._menubar.geometry().y() + 200, self.dialog.geometry().width(), self.dialog.geometry().height())

        if id is not None:
            self.ui.id.setText(id)
        if name is not None:
            self.ui.name.setText(name)

        if self.dialog.exec_():
            id = str(self.ui.id.text())
            name = str(self.ui.name.text())
            path = str(self.ui.directory.text())

            if '' == id or '' == name or path == "Project Directory" :
                return self.createAppDialog(path, id, name)

            # set the path to path+project dir name
            path = str(os.path.join(str(path), str(self.id+"."+self.name)))

            if self.new:
                # create project directory id.name and create app and main.lua there
                try :
                    if not os.path.exists(path):
                        os.mkdir(path)
                    else :
                        msg = QMessageBox()
                        msg.setWindowFlags(Qt.WindowStaysOnTopHint)
                        msg.setText('Path "' + path + '" is aleady exist. Please select other id or name for the project.')
                        msg.setWindowTitle("Error")
                        msg.setGeometry(self.mainWindow._menubar.geometry().x() + 100, self.mainWindow._menubar.geometry().y() + 200, msg.geometry().width(), msg.geometry().height())
                        msg.exec_()
                        return None
                except:
                    msg = QMessageBox()
                    msg.setWindowFlags(Qt.WindowStaysOnTopHint)
                    msg.setText('Path "' + path + '" is not valid. Please select other id or name for the project.')
                    msg.setWindowTitle("Error")
                    msg.setGeometry(self.mainWindow._menubar.geometry().x() + 100, self.mainWindow._menubar.geometry().y() + 200, msg.geometry().width(), msg.geometry().height())
                    msg.exec_()
                    return None

                appPath = os.path.join(path, 'app')
                appFile = open(appPath, 'w')
                appFile.write('app = {' + APP.format(id, name) + '}')
                appFile.close()

                eventPath = os.path.join(path, 'event.lua')
                eventFile = open(eventPath, 'w')
                eventContents = "--[ DO NOT CHANGE THIS SECTION ]\nlocal function event_handlers(VL)\n--[ DO NOT CHANGE THIS SECTION ]\n\n-- SCREEN ON_KEY_DOWN SECTION [DO NOT CHANGE THIS LINE]\n\tfunction screen:on_key_down(key)\n\n\tend\n-- END SCREEN ON_KEY_DOWN SECTION [DO NOT CHANGE THIS LINE]\n\n-- SCREEN ON_KEY_UP SECTION [DO NOT CHANGE THIS LINE]\n\tfunction screen:on_key_up(key)\n\n\tend\n-- END SCREEN ON_KEY_UP SECTION [DO NOT CHANGE THIS LINE]\n\n-- SCREEN ON_BUTTON_DOWN SECTION [DO NOT CHANGE THIS LINE]\n\tfunction screen:on_button_down(x , y , button, num_clicks, m)\n\n\tend\n-- END SCREEN ON_BUTTON_DOWN SECTION [DO NOT CHANGE THIS LINE]\n\n-- SCREEN ON_BUTTON_UP SECTION [DO NOT CHANGE THIS LINE]\n\tfunction screen:on_button_up(x , y , button, num_clicks, m)\n\n\tend\n-- END SCREEN ON_BUTTON_UP SECTION [DO NOT CHANGE THIS LINE]\n\n-- SCREEN ON_MOTION SECTION [DO NOT CHANGE THIS LINE]\n\tfunction screen:on_motion(x , y)\n\n\tend\n-- END SCREEN ON_MOTION SECTION [DO NOT CHANGE THIS LINE]\n\n--[ DO NOT CHANGE THIS SECTION ]\nend\nreturn event_handlers\n--[ DO NOT CHANGE THIS SECTION ]"

                eventFile.write(eventContents)
                eventFile.close()

                mainPath = os.path.join(path, 'main.lua')
                mainFile = open(mainPath, 'w')

                mainContents = """-- VE LIBRARY SECTION [DO NOT CHANGE THIS SECTION]\nlocal VL = {}\n-- END VE LIBRARY SECTION [DO NOT CHANGE THIS SECTION]\n\nlocal function user_main()\n\n\t-- transit to default screen\n\tVL.transit_to()\n\n\tcontrollers:start_pointer()\n\tscreen:show()\n\nend\n\n-- VE LIBRARY SECTION [DO NOT CHANGE THIS SECTION]\nVL = dofile('LIB/ve2/ve_runtime')(user_main)\n-- END VE LIBRARY SECTION [DO NOT CHANGE THIS SECTION]""" 
                mainFile.write(mainContents)
                mainFile.close()


                self.openList = [appPath, mainPath]
                # create subdirectories (lib, assets, screens ...) and copy lib files into it.
                assets_path = str(os.path.join(str(path), 'assets'))
                os.mkdir(assets_path)
                os.mkdir(str(os.path.join(assets_path, 'videos')))
                os.mkdir(str(os.path.join(assets_path, 'images')))
                os.mkdir(str(os.path.join(assets_path, 'skins')))
                os.mkdir(str(os.path.join(assets_path, 'sounds')))

                os.mkdir(str(os.path.join(str(path), 'screens')))

                lib_path = str(os.path.join(str(path), 'LIB'))
                os.mkdir(lib_path)
                shutil.copytree(str(os.path.join(self.mainWindow.apath, 'VE/LIB/Widget')) ,str(os.path.join(lib_path, 'Widget')))
                #shutil.copytree(str(os.path.join(self.mainWindow.apath, 'VE/LIB/assets')) ,str(os.path.join(lib_path, 'assets')))
                os.mkdir(str(os.path.join(lib_path, 've2')))
                shutil.copyfile(str(os.path.join(self.mainWindow.apath, 'VE/LIB/VE/ve_runtime.lua')) ,str(os.path.join(lib_path, 've2/ve_runtime.lua')))

                self.id = ""
                self.name = ""
                return path
            else:
                return -1
        else:
            return -1

    def quiet_exit(self):
        pass
