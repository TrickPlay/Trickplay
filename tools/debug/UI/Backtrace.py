# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Backtrace2.ui'
#
# Created: Thu Feb  2 13:57:55 2012
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
        TrickplayBacktrace.resize(230, 183)
        self.gridLayout = QtGui.QGridLayout(TrickplayBacktrace)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.traceTable = QtGui.QTableWidget(TrickplayBacktrace)
        font = QtGui.QFont()
        font.setStyleHint(font.Monospace)
        font.setFamily('Inconsolata')
        font.setPointSize(12)
        self.traceTable.setFont(font)
        self.traceTable.setShowGrid(False)
        self.traceTable.setObjectName(_fromUtf8("traceTable"))
        self.traceTable.setColumnCount(0)
        self.traceTable.setRowCount(0)
        self.traceTable.horizontalHeader().setVisible(False)
        self.traceTable.horizontalHeader().setStretchLastSection(True)
        self.traceTable.verticalHeader().setVisible(False)
        self.gridLayout.addWidget(self.traceTable, 0, 0, 1, 1)

        self.retranslateUi(TrickplayBacktrace)
        QtCore.QMetaObject.connectSlotsByName(TrickplayBacktrace)

    def retranslateUi(self, TrickplayBacktrace):
        TrickplayBacktrace.setWindowTitle(QtGui.QApplication.translate("TrickplayBacktrace", "Form", None, QtGui.QApplication.UnicodeUTF8))

