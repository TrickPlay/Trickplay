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
    
    def __init(self, mainWindow):
        self.mainWindow = mainWindow
        self.id = None
        self.name = None
        self.new = None
        
    def filesToOpen(self):
        return self.openList
    
    
    def start(self, path):
    
        self.openList = None
        
        # If no app path was passed in
        if not path:
            
            # Check settings for the last path used
            settings = QSettings()
            dir = str(settings.value('path', '').toString())

            # Get a path from the user
            userPath = self.createAppDialog(dir)
            
            if userPath:
                print('Path chosen: ' + str(userPath))
            else:    
                sys.exit()
                
            if os.path.exists(userPath):
                if os.path.isdir(userPath):
                    
                    files = os.listdir(userPath)
                    
                    # If the directory is empty, start the app creator
                    if len(files) <= 0:
                        return self.createAppDialog(userPath)
                        
                    if 'app' in files and 'main.lua' in files:
                        return userPath
                    else:
                        msg = QMessageBox()
                        msg.setText('Directory "' + os.path.basename(str(userPath)) +
                                    '" does not contain an "app" file and a "main.lua" file.')
                        msg.setInformativeText('If you pick an empty directory, you will be '
                                               'prompted to create a new app there.');
                        msg.setWindowTitle("Error")
                        msg.exec_()
                        return self.start(None)
        
        # Path was given on command line
        else:
            if os.path.exists(path) and os.path.isdir(path):
                files = os.listdir(path)
                if len(files) <= 0:
                    return self.createAppDialog(path)
                else:
                    if 'app' in files and 'main.lua' in files:
                        return path
                    else:
                        sys.exit('Error >> ' + path +
                                 ' does not contain an app file and a main.lua file.')
            else:
                sys.exit('Error >> ' + path + ' is not existing directory.')
            
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
        If invalid app file, return -3
        If user cancels the dialog, return -2
        If non-empty with no app and main.lua, return -1
        If empty, return 0
        If app and main.lua exist, return 1
        """
        
        if os.path.isdir(path):
            
            files = os.listdir(path)
            
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
                return -1
            
        else:
            return -2
        
    def adjustDialog(self, path):
        
        result = self.scan(str(path))
        
        # If the path is a directory...
        if 0 == result:
            self.ui.id.setReadOnly(False)
            self.ui.name.setReadOnly(False)
            self.new = True
                
        elif 1 == result:
            self.ui.id.setReadOnly(True)
            self.ui.name.setReadOnly(True)
            self.ui.id.setText(self.id)
            self.ui.name.setText(self.name)
            self.new = False
                
        elif -1 == result:
            msg = QMessageBox()
            msg.setText('Directory "' + os.path.basename(str(path)) +
                        '" does not contain an "app" file and a "main.lua" file.')
            msg.setInformativeText('If you pick an empty directory, you will be '
                                   'prompted to create a new app there.');
            msg.setWindowTitle("Error")
            msg.exec_()
        
        return result
        

    def chooseDirectoryDialog(self):
        """
        User chooses a directory:
        If the directory is empty, then they must fill in Name and Id
        If the directory is not empty, it must have an 'app' and 'main.lua'
        """
        
        # Open the browser, wait for it to close
        dir = self.ui.directory.text()
        
        path = QFileDialog.getExistingDirectory(None, 'Select app directory', dir)
        
        result = self.adjustDialog(path)
        if result >= 0:
            self.ui.directory.setText(path)
        
    def createAppDialog(self, path):
        """
        New app dialog
        """
        
        print('started app creator!')
        
        self.dialog = QDialog()
        self.ui = Ui_newApplicationDialog()
        self.ui.setupUi(self.dialog)
        self.ui.directory.setText(path)
        
        self.adjustDialog(path)
        
        QObject.connect(self.ui.browse, SIGNAL('clicked()'), self.chooseDirectoryDialog)
        
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
            sys.exit()





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