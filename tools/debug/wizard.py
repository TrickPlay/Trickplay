import sys
import os
import re

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from UI.NewApplicationDialog import Ui_newApplicationDialog

APP = """
    id          = "{0}",
    release     = "1",
    version     = "0.1",
    name        = "{1}",
    copyright   = "",
"""

# Could use QWizard, but this is simpler
class Wizard():
    
    # font 
    font = QFont()
    font.setPointSize(10)


    def __init(self, mainWindow = None):
        self.mainWindow = mainWindow
        self.id = None
        self.name = None
        self.new = None
        
    def filesToOpen(self):
        return self.openList
    
    def start(self, path, openApp=False, newApp=False):
        self.openList = None
        
        # Check settings for the last path used
        settings = QSettings()
        dir = str(settings.value('path', '').toString())

        # If no app path was passed in
        if not path and newApp == False:
            if os.path.exists(dir) and os.path.isdir(dir):
                files = os.listdir(dir)
                if len(files) <= 0:
                    #return self.createAppDialog(dir)
                    msg = QMessageBox()
                    msg.setText('Directory "' + os.path.basename(str(path)) +
                    '" does not contain an "app" file and a "main.lua" file.')
                    #msg.setInformativeText('If you pick an empty directory, you will be '
                    #                       'prompted to create a new app there.');
                    msg.setWindowTitle("Error")
                    msg.exec_()
                    return -1

                else:
                    if 'app' in files and 'main.lua' in files:
                        return dir
                    else:
                        sys.exit('Error >> ' + dir +
                                 ' does not contain an app file and a main.lua file.')
            else:
                #TODO: add dialog box for openApp or newApp 
                print("[VDBG] YUGI 2")
                return

	    # Get a path from the user
        if openApp == False and newApp == True:
            
            userPath = self.createAppDialog()
            if userPath:
                print('Path chosen: ' + str(userPath))
            else:    
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
                        msg = QMessageBox()
                        msg.setText('Directory "' + os.path.basename(str(userPath)) +
                                    '" does not contain an "app" file and a "main.lua" file.')
                        msg.setInformativeTet('If you pick an empty directory, you will be '
                                               'prompted to create a new app there.');
                        msg.setWindowTitle("Error")
                        msg.exec_()
                        return self.start(None)
        
        # Path was given on command line
        else:
            if os.path.exists(path) and os.path.isdir(path):
                #files = os.listdir(path)
                msg = QMessageBox()
                msg.setText('Directory "' + os.path.basename(str(path)) +
                '" does not contain an "app" file and a "main.lua" file.')
                #msg.setInformativeText('If you pick an empty directory, you will be '
                #                       'prompted to create a new app there.');
                msg.setWindowTitle("Error")
                msg.exec_()
                return -1

                """
                if len(files) <= 0:
                    return self.createAppDialog(path)
                else:
                    msg = QMessageBox()
                    msg.setText('Directory "' + os.path.basename(str(path)) +
                    '" does not contain an "app" file and a "main.lua" file.')
                    #msg.setInformativeText('If you pick an empty directory, you will be '
                    #                       'prompted to create a new app there.');
                    msg.setWindowTitle("Error")
                    msg.exec_()
                    return -1
                    if 'app' in files and 'main.lua' in files:
                        return path
                    else:
                        #print('[VDBG] Error - ' + path + ' does not contain an app file and a main.lua file.')
                        msg = QMessageBox()
                        msg.setText('Directory "' + os.path.basename(str(path)) +
                                    '" does not contain an "app" file and a "main.lua" file.')
                        #msg.setInformativeText('If you pick an empty directory, you will be '
                        #                       'prompted to create a new app there.');
                        msg.setWindowTitle("Error")
                        msg.exec_()
                        return -1
                """

            else:
                print('[VDBG] Error - ' + path + ' is not existing directory.')
            
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
        	    msg = QMessageBox()
        	    msg.setText('Directory "' + os.path.basename(str(path)) + '" does not contain an "app" file and a "main.lua" file.')
        	    msg.setInformativeText('If you pick an empty directory, you will be ' 'prompted to create a new app there.');
        	    msg.setWindowTitle("Error")
        	    msg.exec_()
        
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
        
        path = QFileDialog.getExistingDirectory(None, 'Create an app directory', directory, QFileDialog.ShowDirsOnly)
        apath = os.path.dirname(str(path))
        
        result = self.adjustDialog(path, directory)
        if result == 0:
            self.ui.directory.setText(path)
            self.ui.id.setReadOnly(False)
            self.ui.name.setReadOnly(False)
            self.new = True
        elif result == -4:
            msg = QMessageBox()
            msg.setText('\'' + os.path.basename(str(path)) + '\' is not a valid directory. Please select another empty directory to create a new app.')
            msg.setWindowTitle("Warning")
            msg.exec_()
        else:
            msg = QMessageBox()
            msg.setText('\'' + os.path.basename(str(path)) + '\' is not an empty directory. Please select an empty directory to create a new app.')
            msg.setWindowTitle("Warning")
            msg.exec_()
        return path
        
    def createAppDialog(self, path=None):
        """
        New app dialog
        """
        self.dialog = QDialog()
        self.ui = Ui_newApplicationDialog()
        self.ui.setupUi(self.dialog)
        if path is not None :
            self.ui.directory.setText(path)
        
        #self.adjustDialog(path)
        cancelButton = self.ui.buttonBox.button(QDialogButtonBox.Cancel)
        okButton = self.ui.buttonBox.button(QDialogButtonBox.Ok)

        QObject.connect(self.ui.browse, SIGNAL('clicked()'), self.chooseDirectoryDialog)
        QObject.connect(cancelButton, SIGNAL('clicked()'), self.exit_ii)
        QObject.connect(okButton, SIGNAL('clicked()'), self.exit_ii)

        
        if self.dialog.exec_():            
            id = str(self.ui.id.text())
            name = str(self.ui.name.text())
            path = str(self.ui.directory.text())
            
            if '' == id or '' == name or '' == path:
                return self.createAppDialog(path)
            
            if self.new:
                print('now creating', path, id, name)
                appPath = os.path.join(path, 'app')
                appFile = open(appPath, 'w')
                appFile.write('app = {' + APP.format(id, name) + '}')
                appFile.close()
                mainPath = os.path.join(path, 'main.lua')
                mainFile = open(mainPath, 'w')
                mainFile.close()
                self.openList = [appPath, mainPath]
                return path
            else:
                return path
        else:
            return 


        # If the path is a directory...
        #if os.path.isdir(path):
        #    
        #    files = os.listdir(path)
        #    
        #     If the directory is empty, allow the user to change id and name
        #    if len(files) <= 0:
        #        self.ui.id.setReadOnly(False)
        #        self.ui.name.setReadOnly(False)
        #        
        #    if 'app' in files and 'main.lua' in files:
        #        self.ui.id.setReadOnly(True)
        #        self.ui.name.setReadOnly(True)
        #        
        #    else:
        #        msg = QMessageBox()
        #        msg.setText('Directory "' + os.path.basename(str(path)) +
        #                    '" does not contain an "app" file and a "main.lua" file.')
        #        msg.setInformativeText('If you pick an empty directory, you will be '
        #                               'prompted to create a new app there.');
        #        msg.setWindowTitle("Error")
        #        msg.exec_()
        #        return
        #        
        # User shouldn't be able to get here...
        #else:
        #    sys.exit()



    def exit_ii(self):
		pass
