# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Replace.ui'
#
# Created: Thu Feb  9 10:47:05 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_replaceDialog(object):
    def setupUi(self, replaceDialog):
        replaceDialog.setObjectName(_fromUtf8("replaceDialog"))
        replaceDialog.resize(415, 219)
        font = QtGui.QFont()
        font.setPointSize(10)
        replaceDialog.setFont(font)
        replaceDialog.setModal(True)
        self.layoutWidget = QtGui.QWidget(replaceDialog)
        self.layoutWidget.setGeometry(QtCore.QRect(10, 10, 391, 28))
        self.layoutWidget.setObjectName(_fromUtf8("layoutWidget"))
        self.formLayout = QtGui.QFormLayout(self.layoutWidget)
        self.formLayout.setMargin(0)
        self.formLayout.setHorizontalSpacing(10)
        self.formLayout.setVerticalSpacing(0)
        self.formLayout.setObjectName(_fromUtf8("formLayout"))
        self.labelName = QtGui.QLabel(self.layoutWidget)

        self.layoutWidget_2 = QtGui.QWidget(replaceDialog)
        self.layoutWidget_2.setGeometry(QtCore.QRect(10, 40, 391, 28))
        self.layoutWidget_2.setObjectName(_fromUtf8("layoutWidget_2"))
        self.formLayout_2 = QtGui.QFormLayout(self.layoutWidget_2)
        self.formLayout_2.setMargin(0)
        self.formLayout_2.setHorizontalSpacing(10)
        self.formLayout_2.setVerticalSpacing(0)
        self.formLayout_2.setObjectName(_fromUtf8("formLayout_2"))
        self.labelName_2 = QtGui.QLabel(self.layoutWidget_2)

        font = QtGui.QFont()
        font.setPointSize(10)
        self.labelName.setFont(font)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.LabelRole, self.labelName)
        self.search_txt = QtGui.QLineEdit(self.layoutWidget)
        self.search_txt.setPlaceholderText(_fromUtf8(""))
        self.search_txt.setObjectName(_fromUtf8("search_txt"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.FieldRole, self.search_txt)


        font = QtGui.QFont()
        font.setPointSize(10)
        self.labelName_2.setFont(font)
        self.labelName_2.setObjectName(_fromUtf8("labelName_2"))
        self.formLayout_2.setWidget(0, QtGui.QFormLayout.LabelRole, self.labelName_2)
        self.replace_txt = QtGui.QLineEdit(self.layoutWidget_2)
        self.replace_txt.setPlaceholderText(_fromUtf8(""))
        self.replace_txt.setObjectName(_fromUtf8("replace_txt"))
        self.formLayout_2.setWidget(0, QtGui.QFormLayout.FieldRole, self.replace_txt)

        self.verticalLayoutWidget_3 = QtGui.QWidget(replaceDialog)
        self.verticalLayoutWidget_3.setGeometry(QtCore.QRect(10, 80, 141, 50))
        self.verticalLayoutWidget_3.setObjectName(_fromUtf8("verticalLayoutWidget_3"))
        self.verticalLayout_3 = QtGui.QVBoxLayout(self.verticalLayoutWidget_3)
        self.verticalLayout_3.setMargin(0)
        self.verticalLayout_3.setObjectName(_fromUtf8("verticalLayout_3"))
        self.checkBox_case = QtGui.QCheckBox(self.verticalLayoutWidget_3)
        self.checkBox_case.setChecked(True)
        self.checkBox_case.setObjectName(_fromUtf8("checkBox_case"))
        self.verticalLayout_3.addWidget(self.checkBox_case)
        self.checkBox_forward = QtGui.QCheckBox(self.verticalLayoutWidget_3)
        self.checkBox_forward.setChecked(True)
        self.checkBox_forward.setObjectName(_fromUtf8("checkBox_forward"))
        self.verticalLayout_3.addWidget(self.checkBox_forward)

        self.verticalLayoutWidget_2 = QtGui.QWidget(replaceDialog)
        self.verticalLayoutWidget_2.setGeometry(QtCore.QRect(220, 80, 181, 50))
        self.verticalLayoutWidget_2.setObjectName(_fromUtf8("verticalLayoutWidget_2"))
        self.verticalLayout_2 = QtGui.QVBoxLayout(self.verticalLayoutWidget_2)
        self.verticalLayout_2.setMargin(0)
        self.verticalLayout_2.setObjectName(_fromUtf8("verticalLayout_2"))
        self.checkBox_word = QtGui.QCheckBox(self.verticalLayoutWidget_2)
        self.checkBox_word.setChecked(True)
        self.checkBox_word.setObjectName(_fromUtf8("checkBox_word"))
        self.verticalLayout_2.addWidget(self.checkBox_word)
        self.checkBox_wrap = QtGui.QCheckBox(self.verticalLayoutWidget_2)
        self.checkBox_wrap.setChecked(True)
        self.checkBox_wrap.setObjectName(_fromUtf8("checkBox_wrap"))
        self.verticalLayout_2.addWidget(self.checkBox_wrap)
                
        self.pushButton_replaceAll = QtGui.QPushButton(replaceDialog)
        self.pushButton_replaceAll.setGeometry(QtCore.QRect(300, 180, 99, 27))
        self.pushButton_replaceAll.setObjectName(_fromUtf8("pushButton_replaceAll"))

        self.pushButton_replace = QtGui.QPushButton(replaceDialog)
        self.pushButton_replace.setGeometry(QtCore.QRect(190, 180, 99, 27))
        self.pushButton_replace.setObjectName(_fromUtf8("pushButton_replace"))

        self.pushButton_replaceFind = QtGui.QPushButton(replaceDialog)
        self.pushButton_replaceFind.setGeometry(QtCore.QRect(300, 140, 99, 27))
        self.pushButton_replaceFind.setObjectName(_fromUtf8("pushButton_replaceFind"))

        self.pushButton_find = QtGui.QPushButton(replaceDialog)
        self.pushButton_find.setGeometry(QtCore.QRect(190, 140, 99, 27))
        self.pushButton_find.setObjectName(_fromUtf8("pushButton_find"))

        self.pushButton_close = QtGui.QPushButton(replaceDialog)
        self.pushButton_close.setGeometry(QtCore.QRect(80, 140, 99, 27))
        self.pushButton_close.setObjectName(_fromUtf8("pushButton_close"))

        self.notification = QtGui.QLabel(replaceDialog)
        self.notification.setGeometry(QtCore.QRect(10, 180, 161, 26))
        font = QtGui.QFont()
        font.setPointSize(10)
        self.notification.setFont(font)
        self.notification.setText(_fromUtf8(""))
        self.notification.setObjectName(_fromUtf8("notification"))

        self.retranslateUi(replaceDialog)
        QtCore.QMetaObject.connectSlotsByName(replaceDialog)

    def retranslateUi(self, replaceDialog):
        replaceDialog.setWindowTitle(QtGui.QApplication.translate("replaceDialog", "Search/Replace", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("replaceDialog", "Find:                     ", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_word.setText(QtGui.QApplication.translate("replaceDialog", "Match entire word only", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_wrap.setText(QtGui.QApplication.translate("replaceDialog", "Wrap around", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_case.setText(QtGui.QApplication.translate("replaceDialog", "Match case", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_forward.setText(QtGui.QApplication.translate("replaceDialog", "Search forward", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName_2.setText(QtGui.QApplication.translate("replaceDialog", "Replace with:   ", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_replaceAll.setText(QtGui.QApplication.translate("replaceDialog", "Replace All", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_replace.setText(QtGui.QApplication.translate("replaceDialog", "Replace", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_replaceFind.setText(QtGui.QApplication.translate("replaceDialog", "Replace/Find", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_find.setText(QtGui.QApplication.translate("replaceDialog", "Find", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_close.setText(QtGui.QApplication.translate("replaceDialog", "Close", None, QtGui.QApplication.UnicodeUTF8))

