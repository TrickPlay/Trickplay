import sys
import os

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from NewApplicationDialog import Ui_newApplicationDialog

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
        
    def filesToOpen(self):
        return self.openList
    
    
    def start(self, path):
    
        self.openList = None
        
        # First get an app path if one wasn't passed in
        if not path:
            userPath = self.chooseDirectoryDialog()
            
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
     
                # Can't currently get here...
                #else:
                #    msg = QMessageBox()
                #    msg.setText(
                #        os.path.basename(str(userPath)) + ' is not a directory.')
                #    msg.setWindowTitle("Error")
                #    msg.exec_()
                #    self.start(None)
        
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
            
    
    """
    User chooses a directory if one wasn't passed as an argument
    
    TODO, let user type in a blank directory. Right now they have to hit the
    new directory button.
    """
    def chooseDirectoryDialog(self):
        
        path = None
        
        settings = QSettings()
        dir = settings.value('path', QDir.homePath()).toPyObject()
        
        #dialog = QFileDialog(None, 'Select app directory', dir)
        #
        #dialog.setFileMode(QFileDialog.Directory)
        #
        #if dialog.exec_():
        #    selected = dialog.selectedFiles()
        #    path = selected[0]
        
        path = QFileDialog.getExistingDirectory(None, 'Select app directory', dir)
        
        return path
        
    def createAppDialog(self, path):
        print('started app creator!')
        
        dialog = QDialog()
        ui = Ui_newApplicationDialog()
        ui.setupUi(dialog)
        ui.directory.setText(path)
        if dialog.exec_():
            id = str(ui.id.text())
            name = str(ui.name.text())
            path = str(path)
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
            sys.exit()

        
#def openDir(d):
#    path = str(d)
#    print('opened', d)
#    dialog.close()
#    
#QObject.connect(dialog, SIGNAL('directoryEntered(const QString)'), openDir)
#