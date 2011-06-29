# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'TreeView.ui'
#
# Created: Wed Jun 29 12:13:16 2011
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
        MainWindow.resize(458, 605)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Ignored, QtGui.QSizePolicy.Ignored)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setCursor(QtCore.Qt.ArrowCursor)
        self.centralwidget = QtGui.QWidget(MainWindow)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.Inspector = QtGui.QTreeView(self.centralwidget)
        self.Inspector.setGeometry(QtCore.QRect(0, 40, 1920, 1080))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.MinimumExpanding, QtGui.QSizePolicy.MinimumExpanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.Inspector.sizePolicy().hasHeightForWidth())
        self.Inspector.setSizePolicy(sizePolicy)
        self.Inspector.setAutoFillBackground(False)
        self.Inspector.setDragDropMode(QtGui.QAbstractItemView.NoDragDrop)
        self.Inspector.setAlternatingRowColors(True)
        self.Inspector.setAllColumnsShowFocus(True)
        self.Inspector.setObjectName(_fromUtf8("Inspector"))
        self.Inspector.header().setCascadingSectionResizes(True)
        self.Inspector.header().setDefaultSectionSize(200)
        self.Inspector.header().setHighlightSections(True)
        self.Inspector.header().setMinimumSectionSize(100)
        self.Inspector.header().setStretchLastSection(True)
        self.button_Refresh = QtGui.QPushButton(self.centralwidget)
        self.button_Refresh.setGeometry(QtCore.QRect(10, 10, 85, 27))
        self.button_Refresh.setObjectName(_fromUtf8("button_Refresh"))
        self.button_ExpandAll = QtGui.QPushButton(self.centralwidget)
        self.button_ExpandAll.setGeometry(QtCore.QRect(100, 10, 97, 27))
        self.button_ExpandAll.setObjectName(_fromUtf8("button_ExpandAll"))
        self.button_CollapseAll = QtGui.QPushButton(self.centralwidget)
        self.button_CollapseAll.setGeometry(QtCore.QRect(200, 10, 97, 27))
        self.button_CollapseAll.setObjectName(_fromUtf8("button_CollapseAll"))
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 458, 25))
        self.menubar.setObjectName(_fromUtf8("menubar"))
        self.menuFile = QtGui.QMenu(self.menubar)
        self.menuFile.setObjectName(_fromUtf8("menuFile"))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtGui.QStatusBar(MainWindow)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        MainWindow.setStatusBar(self.statusbar)
        self.actionExit = QtGui.QAction(MainWindow)
        self.actionExit.setObjectName(_fromUtf8("actionExit"))
        self.action_Exit = QtGui.QAction(MainWindow)
        self.action_Exit.setMenuRole(QtGui.QAction.QuitRole)
        self.action_Exit.setObjectName(_fromUtf8("action_Exit"))
        self.menuFile.addAction(self.action_Exit)
        self.menubar.addAction(self.menuFile.menuAction())

        self.retranslateUi(MainWindow)
        QtCore.QObject.connect(self.button_ExpandAll, QtCore.SIGNAL(_fromUtf8("released()")), self.Inspector.expandAll)
        QtCore.QObject.connect(self.button_CollapseAll, QtCore.SIGNAL(_fromUtf8("released()")), self.Inspector.collapseAll)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)
        MainWindow.setTabOrder(self.button_Refresh, self.Inspector)

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QtGui.QApplication.translate("MainWindow", "Trickplay UI Tree Viewer", None, QtGui.QApplication.UnicodeUTF8))
        self.button_Refresh.setText(QtGui.QApplication.translate("MainWindow", "Refresh", None, QtGui.QApplication.UnicodeUTF8))
        self.button_ExpandAll.setText(QtGui.QApplication.translate("MainWindow", "Expand All", None, QtGui.QApplication.UnicodeUTF8))
        self.button_CollapseAll.setText(QtGui.QApplication.translate("MainWindow", "Collapse All", None, QtGui.QApplication.UnicodeUTF8))
        self.menuFile.setTitle(QtGui.QApplication.translate("MainWindow", "File", None, QtGui.QApplication.UnicodeUTF8))
        self.actionExit.setText(QtGui.QApplication.translate("MainWindow", "Exit", None, QtGui.QApplication.UnicodeUTF8))
        self.action_Exit.setText(QtGui.QApplication.translate("MainWindow", "Exit", None, QtGui.QApplication.UnicodeUTF8))

