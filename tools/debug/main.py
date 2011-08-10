#!/usr/bin/env python

import sys
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from TreeView import Ui_MainWindow

import connection
from devices import TrickplayDiscovery
from editor import LuaEditor
from element import Element, ROW
from model import ElementModel, pyData, modelToData, dataToModel, summarize
from data import modelToData, dataToModel, BadDataException
from push import TrickplayPushApp
from connection import CON
from wizard import Wizard



class MainWindow(QMainWindow):
    
    def __init__(self):
        
        # Main window setup
        QWidget.__init__(self, parent)
        
        # Restore size/position of window
        settings = QSettings()
        self.restoreGeometry(settings.value("mainWindowGeometry").toByteArray());
        
        # Run UI file
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        
        # Restore sizes/positions of docks
        self.restoreState(settings.value("mainWindowState").toByteArray());
        
        
    """
    Save window and dock geometry on close
    """
    def closeEvent(self, event):
        settings = QSettings()
        settings.setValue("mainWindowGeometry", self.saveGeometry());
        settings.setValue("mainWindowState", self.saveState());
    
    def pushApp(self):    
        print('Pushing app to', CON.get())
        tp = TrickplayPushApp(str(self.appPath))
        tp.push(address = CON.get())
        
        
        
        
        