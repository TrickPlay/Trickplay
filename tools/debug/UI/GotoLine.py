# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'GotoLine.ui'
#
# Created: Mon Feb 27 13:41:57 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_gotoLineDialog(object):
    def setupUi(self, gotoLineDialog):
        gotoLineDialog.setObjectName(_fromUtf8("gotoLineDialog"))
        gotoLineDialog.resize(418, 85)
        font = QtGui.QFont()
        font.setStyleHint(font.Monospace)
        font.setPointSize(10)
        gotoLineDialog.setFont(font)
        gotoLineDialog.setModal(True)
        self.buttonBox = QtGui.QDialogButtonBox(gotoLineDialog)
        self.buttonBox.setGeometry(QtCore.QRect(240, 50, 176, 27))
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.notification = QtGui.QLabel(gotoLineDialog)
        self.notification.setGeometry(QtCore.QRect(10, 50, 201, 26))
        self.notification.setFont(font)
        self.notification.setText(_fromUtf8(""))
        self.notification.setObjectName(_fromUtf8("notification"))
        self.layoutWidget = QtGui.QWidget(gotoLineDialog)
        self.layoutWidget.setGeometry(QtCore.QRect(9, 9, 401, 28))
        self.layoutWidget.setObjectName(_fromUtf8("layoutWidget"))
        self.gridLayout = QtGui.QGridLayout(self.layoutWidget)
        self.gridLayout.setMargin(0)
        self.gridLayout.setHorizontalSpacing(10)
        self.gridLayout.setVerticalSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.line_txt = QtGui.QLineEdit(self.layoutWidget)
        self.line_txt.setPlaceholderText(_fromUtf8(""))
        self.line_txt.setObjectName(_fromUtf8("line_txt"))
        self.gridLayout.addWidget(self.line_txt, 0, 1, 1, 1)
        self.labelName = QtGui.QLabel(self.layoutWidget)
        self.labelName.setFont(font)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 0, 0, 1, 1)

        self.retranslateUi(gotoLineDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), gotoLineDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), gotoLineDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(gotoLineDialog)
        gotoLineDialog.setTabOrder(self.line_txt, self.buttonBox)

    def retranslateUi(self, gotoLineDialog):
        gotoLineDialog.setWindowTitle(QtGui.QApplication.translate("gotoLineDialog", "Go to Line", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("gotoLineDialog", "Enter line number:   ", None, QtGui.QApplication.UnicodeUTF8))

