# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Backtrace.ui'
#
# Created: Thu Jan 26 16:06:42 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_TrickplayBacktrace(object):
    def setupUi(self, TrickplayBacktrace):
        TrickplayBacktrace.setObjectName(_fromUtf8("TrickplayBacktrace"))
        TrickplayBacktrace.resize(200, 184)
        self.gridLayout = QtGui.QGridLayout(TrickplayBacktrace)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.listWidget = QtGui.QListWidget(TrickplayBacktrace)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.listWidget.setFont(font)
        self.listWidget.setObjectName(_fromUtf8("listWidget"))
        self.gridLayout.addWidget(self.listWidget, 0, 0, 1, 1)

        self.retranslateUi(TrickplayBacktrace)
        QtCore.QMetaObject.connectSlotsByName(TrickplayBacktrace)

    def retranslateUi(self, TrickplayBacktrace):
        TrickplayBacktrace.setWindowTitle(QtGui.QApplication.translate("TrickplayBacktrace", "Form", None, QtGui.QApplication.UnicodeUTF8))

