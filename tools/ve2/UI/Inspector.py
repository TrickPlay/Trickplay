# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Inspector2.ui'
#
# Created: Fri Apr  6 16:34:38 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_TrickplayInspector(object):
    def setupUi(self, TrickplayInspector):
        TrickplayInspector.setObjectName(_fromUtf8("TrickplayInspector"))
        TrickplayInspector.resize(331, 819)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(TrickplayInspector.sizePolicy().hasHeightForWidth())
        TrickplayInspector.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(9)
        TrickplayInspector.setFont(font)
        self.gridLayout = QtGui.QGridLayout(TrickplayInspector)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.tabWidget = QtGui.QTabWidget(TrickplayInspector)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.tabWidget.sizePolicy().hasHeightForWidth())
        self.tabWidget.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(9)
        self.tabWidget.setFont(font)
        self.tabWidget.setMouseTracking(True)
        self.tabWidget.setTabPosition(QtGui.QTabWidget.South)
        self.tabWidget.setTabShape(QtGui.QTabWidget.Rounded)
        self.tabWidget.setObjectName(_fromUtf8("tabWidget"))
        self.ObjectInspector = QtGui.QWidget()
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.ObjectInspector.sizePolicy().hasHeightForWidth())
        self.ObjectInspector.setSizePolicy(sizePolicy)
        self.ObjectInspector.setObjectName(_fromUtf8("ObjectInspector"))
        self.gridLayout_3 = QtGui.QGridLayout(self.ObjectInspector)
        self.gridLayout_3.setMargin(0)
        self.gridLayout_3.setSpacing(0)
        self.gridLayout_3.setObjectName(_fromUtf8("gridLayout_3"))
        self.inspector = QtGui.QTreeView(self.ObjectInspector)
        self.inspector.setObjectName(_fromUtf8("inspector"))
        self.gridLayout_3.addWidget(self.inspector, 0, 0, 1, 1)
        self.tabWidget.addTab(self.ObjectInspector, _fromUtf8(""))
        self.PropertyEditor = QtGui.QWidget()
        self.PropertyEditor.setEnabled(True)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.PropertyEditor.sizePolicy().hasHeightForWidth())
        self.PropertyEditor.setSizePolicy(sizePolicy)
        self.PropertyEditor.setObjectName(_fromUtf8("PropertyEditor"))
        self.gridLayout_2 = QtGui.QGridLayout(self.PropertyEditor)
        self.gridLayout_2.setMargin(0)
        self.gridLayout_2.setSpacing(0)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.property = QtGui.QTreeWidget(self.PropertyEditor)
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Ubuntu"))
        font.setPointSize(9)
        self.property.setFont(font)
        self.property.setObjectName(_fromUtf8("property"))
        #self.property.headerItem().setText(0, _fromUtf8("1"))
        self.property.header().setVisible(True)
        self.gridLayout_2.addWidget(self.property, 0, 1, 1, 1)
        self.tabWidget.addTab(self.PropertyEditor, _fromUtf8(""))
        self.gridLayout.addWidget(self.tabWidget, 0, 0, 1, 1)

        self.retranslateUi(TrickplayInspector)
        self.tabWidget.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(TrickplayInspector)

    def retranslateUi(self, TrickplayInspector):
        TrickplayInspector.setWindowTitle(QtGui.QApplication.translate("TrickplayInspector", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.ObjectInspector), QtGui.QApplication.translate("TrickplayInspector", "Object Inspector", None, QtGui.QApplication.UnicodeUTF8))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.PropertyEditor), QtGui.QApplication.translate("TrickplayInspector", "Property Editor", None, QtGui.QApplication.UnicodeUTF8))

