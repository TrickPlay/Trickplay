# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Console2.ui'
#
# Created: Wed Nov  2 16:01:23 2011
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_Console(object):
    def setupUi(self, Console):
        Console.setObjectName(_fromUtf8("Console"))
        Console.resize(1060, 178)
        self.gridLayout = QtGui.QGridLayout(Console)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.formLayout = QtGui.QFormLayout()
        self.formLayout.setFieldGrowthPolicy(QtGui.QFormLayout.AllNonFixedFieldsGrow)
        self.formLayout.setObjectName(_fromUtf8("formLayout"))
        self.textEdit = QtGui.QTextEdit(Console)
        self.textEdit.setObjectName(_fromUtf8("textEdit"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.SpanningRole, self.textEdit)
        self.gridLayout.addLayout(self.formLayout, 0, 0, 1, 1)

        self.retranslateUi(Console)
        QtCore.QMetaObject.connectSlotsByName(Console)

    def retranslateUi(self, Console):
        Console.setWindowTitle(QtGui.QApplication.translate("Console", "Console", None, QtGui.QApplication.UnicodeUTF8))

