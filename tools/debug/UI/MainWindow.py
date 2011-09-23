# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'MainWindow.ui'
#
# Created: Fri Aug 19 14:32:17 2011
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName(_fromUtf8("MainWindow"))
        MainWindow.setEnabled(True)
        MainWindow.resize(1121, 811)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Ignored, QtGui.QSizePolicy.Ignored)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setCursor(QtCore.Qt.ArrowCursor)
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1121, 25))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        self.menuFile = QtGui.QMenu(self.menubar)
        self.menuFile.setObjectName(_fromUtf8("menuFile"))
        MainWindow.setMenuBar(self.menubar)
        self.InspectorDock = QtGui.QDockWidget(MainWindow)
        self.InspectorDock.setEnabled(True)
        self.InspectorDock.setMinimumSize(QtCore.QSize(300, 45))
        self.InspectorDock.setContextMenuPolicy(QtCore.Qt.NoContextMenu)
        self.InspectorDock.setFeatures(QtGui.QDockWidget.AllDockWidgetFeatures)
        self.InspectorDock.setObjectName(_fromUtf8("InspectorDock"))
        self.InspectorContainer = QtGui.QWidget()
        self.InspectorContainer.setObjectName(_fromUtf8("InspectorContainer"))
        self.gridLayout_2 = QtGui.QGridLayout(self.InspectorContainer)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.InspectorLayout = QtGui.QGridLayout()
        self.InspectorLayout.setObjectName(_fromUtf8("InspectorLayout"))
        self.gridLayout_2.addLayout(self.InspectorLayout, 0, 0, 1, 1)
        self.InspectorDock.setWidget(self.InspectorContainer)
        MainWindow.addDockWidget(QtCore.Qt.DockWidgetArea(2), self.InspectorDock)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)
        self.DeviceManagerDock = QtGui.QDockWidget(MainWindow)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.DeviceManagerDock.sizePolicy().hasHeightForWidth())
        self.DeviceManagerDock.setSizePolicy(sizePolicy)
        self.DeviceManagerDock.setMinimumSize(QtCore.QSize(100, 163))
        self.DeviceManagerDock.setObjectName(_fromUtf8("DeviceManagerDock"))
        self.DeviceManagerContainer = QtGui.QWidget()
        self.DeviceManagerContainer.setObjectName(_fromUtf8("DeviceManagerContainer"))
        self.verticalLayout = QtGui.QVBoxLayout(self.DeviceManagerContainer)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.DeviceManagerLayout = QtGui.QGridLayout()
        self.DeviceManagerLayout.setObjectName(_fromUtf8("DeviceManagerLayout"))
        self.verticalLayout.addLayout(self.DeviceManagerLayout)
        self.DeviceManagerDock.setWidget(self.DeviceManagerContainer)
        MainWindow.addDockWidget(QtCore.Qt.DockWidgetArea(1), self.DeviceManagerDock)
        self.FileSystemDock = QtGui.QDockWidget(MainWindow)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Maximum, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.FileSystemDock.sizePolicy().hasHeightForWidth())
        self.FileSystemDock.setSizePolicy(sizePolicy)
        self.FileSystemDock.setFloating(False)
        self.FileSystemDock.setFeatures(QtGui.QDockWidget.AllDockWidgetFeatures)
        self.FileSystemDock.setObjectName(_fromUtf8("FileSystemDock"))
        self.FileSystemContainer = QtGui.QWidget()
        self.FileSystemContainer.setObjectName(_fromUtf8("FileSystemContainer"))
        self.gridLayout_3 = QtGui.QGridLayout(self.FileSystemContainer)
        self.gridLayout_3.setObjectName(_fromUtf8("gridLayout_3"))
        self.FileSystemLayout = QtGui.QGridLayout()
        self.FileSystemLayout.setObjectName(_fromUtf8("FileSystemLayout"))
        self.gridLayout_3.addLayout(self.FileSystemLayout, 0, 0, 1, 1)
        self.FileSystemDock.setWidget(self.FileSystemContainer)
        MainWindow.addDockWidget(QtCore.Qt.DockWidgetArea(1), self.FileSystemDock)
        self.actionExit = QtGui.QAction(MainWindow)
        self.actionExit.setObjectName(_fromUtf8("actionExit"))
        self.action_Exit = QtGui.QAction(MainWindow)
        self.action_Exit.setMenuRole(QtGui.QAction.QuitRole)
        self.action_Exit.setObjectName(_fromUtf8("action_Exit"))
        self.action_Save = QtGui.QAction(MainWindow)
        self.action_Save.setObjectName(_fromUtf8("action_Save"))
        self.menuFile.addAction(self.action_Save)
        self.menuFile.addAction(self.action_Exit)
        self.menubar.addAction(self.menuFile.menuAction())

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Trickplay Editor", None, QtGui.QApplication.UnicodeUTF8))
        self.menuFile.setTitle(QtGui.QApplication.translate("MainWindow", "File", None, QtGui.QApplication.UnicodeUTF8))
        self.InspectorDock.setWindowTitle(QtGui.QApplication.translate("MainWindow", "  Inspector", None, QtGui.QApplication.UnicodeUTF8))
        self.DeviceManagerDock.setWindowTitle(QtGui.QApplication.translate("MainWindow", "  Device Manager", None, QtGui.QApplication.UnicodeUTF8))
        self.FileSystemDock.setWindowTitle(QtGui.QApplication.translate("MainWindow", "  File System", "texty7", QtGui.QApplication.UnicodeUTF8))
        self.actionExit.setText(QtGui.QApplication.translate("MainWindow", "Exit", None, QtGui.QApplication.UnicodeUTF8))
        self.action_Exit.setText(QtGui.QApplication.translate("MainWindow", "&Exit", None, QtGui.QApplication.UnicodeUTF8))
        self.action_Exit.setShortcut(QtGui.QApplication.translate("MainWindow", "Ctrl+Q", None, QtGui.QApplication.UnicodeUTF8))
        self.action_Save.setText(QtGui.QApplication.translate("MainWindow", "&Save", None, QtGui.QApplication.UnicodeUTF8))
        self.action_Save.setShortcut(QtGui.QApplication.translate("MainWindow", "Ctrl+S", None, QtGui.QApplication.UnicodeUTF8))
