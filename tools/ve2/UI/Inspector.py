# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Inspector.ui'
#
# Created: Fri Jun 28 15:16:04 2013
#      by: PyQt4 UI code generator 4.10.1
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

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
        self.tabWidget.setTabPosition(QtGui.QTabWidget.North)
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
        self.inspector.setDragEnabled(False)
        self.inspector.setDragDropMode(QtGui.QAbstractItemView.NoDragDrop)
        self.inspector.setDefaultDropAction(QtCore.Qt.MoveAction)
        self.inspector.setSelectionMode(QtGui.QAbstractItemView.ExtendedSelection)
        self.inspector.setObjectName(_fromUtf8("inspector"))
        self.gridLayout_3.addWidget(self.inspector, 2, 0, 1, 1)
        self.gridLayout_4 = QtGui.QGridLayout()
        self.gridLayout_4.setObjectName(_fromUtf8("gridLayout_4"))
        self.screenCombo = QtGui.QComboBox(self.ObjectInspector)
        self.screenCombo.setObjectName(_fromUtf8("screenCombo"))
        self.gridLayout_4.addWidget(self.screenCombo, 0, 1, 1, 1)
        self.deleteScreen = QtGui.QToolButton(self.ObjectInspector)
        self.deleteScreen.setObjectName(_fromUtf8("deleteScreen"))
        self.gridLayout_4.addWidget(self.deleteScreen, 0, 3, 1, 1)
        self.label = QtGui.QLabel(self.ObjectInspector)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Fixed, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label.sizePolicy().hasHeightForWidth())
        self.label.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.label.setFont(font)
        self.label.setLineWidth(1)
        self.label.setIndent(7)
        self.label.setObjectName(_fromUtf8("label"))
        self.gridLayout_4.addWidget(self.label, 0, 0, 1, 1)
        self.createScreen = QtGui.QToolButton(self.ObjectInspector)
        self.createScreen.setObjectName(_fromUtf8("createScreen"))
        self.gridLayout_4.addWidget(self.createScreen, 0, 2, 1, 1)
        self.gridLayout_3.addLayout(self.gridLayout_4, 1, 0, 1, 1)
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
        self.property.setSelectionMode(QtGui.QAbstractItemView.SingleSelection)
        self.property.setObjectName(_fromUtf8("property"))
        self.property.headerItem().setText(0, _fromUtf8("1"))
        self.property.header().setDefaultSectionSize(100)
        self.gridLayout_2.addWidget(self.property, 2, 0, 1, 1)
        self.inspectorTitleLayout = QtGui.QGridLayout()
        self.inspectorTitleLayout.setSpacing(0)
        self.inspectorTitleLayout.setContentsMargins(-1, 3, -1, 3)
        self.inspectorTitleLayout.setObjectName(_fromUtf8("inspectorTitleLayout"))
        self.inspectorTitle = QtGui.QLabel(self.PropertyEditor)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.inspectorTitle.setFont(font)
        self.inspectorTitle.setObjectName(_fromUtf8("inspectorTitle"))
        self.inspectorTitleLayout.addWidget(self.inspectorTitle, 0, 0, 1, 1)
        self.gridLayout_2.addLayout(self.inspectorTitleLayout, 0, 0, 1, 1)
        self.tabWidget.addTab(self.PropertyEditor, _fromUtf8(""))
        self.gridLayout.addWidget(self.tabWidget, 0, 0, 1, 1)

        self.retranslateUi(TrickplayInspector)
        self.tabWidget.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(TrickplayInspector)

    def retranslateUi(self, TrickplayInspector):
        TrickplayInspector.setWindowTitle(_translate("TrickplayInspector", "Form", None))
        self.deleteScreen.setText(_translate("TrickplayInspector", "-", None))
        self.label.setText(_translate("TrickplayInspector", "Scene:   ", None))
        self.createScreen.setText(_translate("TrickplayInspector", "+", None))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.ObjectInspector), _translate("TrickplayInspector", "Object Inspector", None))
        self.inspectorTitle.setText(_translate("TrickplayInspector", "  Inspector:", None))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.PropertyEditor), _translate("TrickplayInspector", "Property Editor", None))

