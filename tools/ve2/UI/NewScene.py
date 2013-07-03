# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'newScene.ui'
#
# Created: Sat Jun 29 16:59:38 2013
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

class Ui_newScene(object):
    def setupUi(self, newScene):
        newScene.setObjectName(_fromUtf8("newScene"))
        newScene.resize(198, 41)
        self.lineEdit = QtGui.QLineEdit(newScene)
        self.lineEdit.setGeometry(QtCore.QRect(10, 10, 181, 22))
        self.lineEdit.setObjectName(_fromUtf8("lineEdit"))

        self.retranslateUi(newScene)
        QtCore.QMetaObject.connectSlotsByName(newScene)

    def retranslateUi(self, newScene):
        newScene.setWindowTitle(_translate("newScene", "Form", None))

