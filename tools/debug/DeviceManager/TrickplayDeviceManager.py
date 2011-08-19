from PyQt4.QtGui import *
from PyQt4.QtCore import *

from TrickplayDiscovery import TrickplayDiscovery
from TrickplayPushApp import TrickplayPushApp
from UI.DeviceManager import Ui_DeviceManager

from connection import CON

NAME = Qt.UserRole + 1
ADDRESS = Qt.UserRole + 2
PORT = Qt.UserRole + 3



class TrickplayDeviceManager(QWidget):
    
    def __init__(self, inspector, parent = None):
        
        QWidget.__init__(self, parent)
                
        self.ui = Ui_DeviceManager()
        self.ui.setupUi(self)
        
        self.addLocalComboItem()
        
        self.discovery = TrickplayDiscovery(self.ui.comboBox, inspector)

        QObject.connect(self.ui.run,
                        SIGNAL("clicked()"),
                        self.run)
        
        self._path = ''
        self.trickplay = QProcess()
        
    def addLocalComboItem(self):
        """
        Add combo box from running app locally. This always exists.
        """
        name = 'Local device'
        port = '8888'
        address = 'localhost'
        
        self.ui.comboBox.addItem(name)
        index = self.ui.comboBox.findText(name)
        self.ui.comboBox.setItemData(index, address, ADDRESS)
        self.ui.comboBox.setItemData(index, port, PORT)
        self.ui.comboBox.setItemData(index, address, NAME)
        
        CON.port = port
        CON.address = address
    
    def push(self):    
        print('Pushing app to', CON.get())
        tp = TrickplayPushApp(str(self.path()))
        tp.push(address = CON.get())
        
    def setPath(self, p):
        self._path = p
        
    def path(self):
        return self._path
    
    def run(self):
        
        # Run on local trickplay
        if 0 == self.ui.comboBox.currentIndex():
            print("Starting trickplay locally")
            if self.trickplay.state() == QProcess.Running:
                self.trickplay.close()
                #print('exit status', self.trickplay.exitStatus())
            self.trickplay.start('trickplay', [self.path()])
        
        # Push to foreign device
        else:
            self.push()