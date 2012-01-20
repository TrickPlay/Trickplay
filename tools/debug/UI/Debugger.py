# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Debugger.ui'
#
# Created: Thu Jan 19 16:15:13 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_TrickplayDebugger(object):
    def setupUi(self, TrickplayDebugger):
        TrickplayDebugger.setObjectName(_fromUtf8("TrickplayDebugger"))
        TrickplayDebugger.resize(272, 496)
        self.gridLayout = QtGui.QGridLayout(TrickplayDebugger)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.tabWidget = QtGui.QTabWidget(TrickplayDebugger)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.tabWidget.sizePolicy().hasHeightForWidth())
        self.tabWidget.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(9)
        self.tabWidget.setFont(font)
        self.tabWidget.setMouseTracking(True)
        self.tabWidget.setTabPosition(QtGui.QTabWidget.West)
        self.tabWidget.setTabShape(QtGui.QTabWidget.Rounded)
        self.tabWidget.setObjectName(_fromUtf8("tabWidget"))
        self.Breaks = QtGui.QWidget()
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.Breaks.sizePolicy().hasHeightForWidth())
        self.Breaks.setSizePolicy(sizePolicy)
        self.Breaks.setObjectName(_fromUtf8("Breaks"))
        self.gridLayout_3 = QtGui.QGridLayout(self.Breaks)
        self.gridLayout_3.setMargin(0)
        self.gridLayout_3.setSpacing(0)
        self.gridLayout_3.setObjectName(_fromUtf8("gridLayout_3"))
        self.breakTable = QtGui.QTableView(self.Breaks)
        self.breakTable.setObjectName(_fromUtf8("breakTable"))
        self.gridLayout_3.addWidget(self.breakTable, 0, 0, 1, 1)
        self.tabWidget.addTab(self.Breaks, _fromUtf8(""))
        self.Locals = QtGui.QWidget()
        self.Locals.setEnabled(True)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.Locals.sizePolicy().hasHeightForWidth())
        self.Locals.setSizePolicy(sizePolicy)
        self.Locals.setObjectName(_fromUtf8("Locals"))
        self.gridLayout_2 = QtGui.QGridLayout(self.Locals)
        self.gridLayout_2.setMargin(0)
        self.gridLayout_2.setSpacing(0)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.localTable = QtGui.QTableView(self.Locals)
        self.localTable.setObjectName(_fromUtf8("localTable"))
        self.gridLayout_2.addWidget(self.localTable, 0, 0, 1, 1)
        self.tabWidget.addTab(self.Locals, _fromUtf8(""))
        self.gridLayout.addWidget(self.tabWidget, 0, 0, 1, 1)

        self.retranslateUi(TrickplayDebugger)
        self.tabWidget.setCurrentIndex(1)
        QtCore.QMetaObject.connectSlotsByName(TrickplayDebugger)

    def retranslateUi(self, TrickplayDebugger):
        TrickplayDebugger.setWindowTitle(QtGui.QApplication.translate("TrickplayDebugger", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.Breaks), QtGui.QApplication.translate("TrickplayDebugger", "Breaks", None, QtGui.QApplication.UnicodeUTF8))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.Locals), QtGui.QApplication.translate("TrickplayDebugger", "Locals", None, QtGui.QApplication.UnicodeUTF8))

