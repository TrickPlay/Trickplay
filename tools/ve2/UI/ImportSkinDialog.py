# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'ImportSkinDialog.ui'
#
# Created: Fri Feb  8 11:20:03 2013
#      by: PyQt4 UI code generator 4.9.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_importSkinImages(object):
    def setupUi(self, importSkinImages):
        importSkinImages.setObjectName(_fromUtf8("importSkinImages"))
        importSkinImages.resize(456, 124)
        font = QtGui.QFont()
        font.setPointSize(10)
        importSkinImages.setFont(font)
        importSkinImages.setModal(True)
        self.gridLayout_2 = QtGui.QGridLayout(importSkinImages)
        self.gridLayout_2.setVerticalSpacing(12)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setHorizontalSpacing(16)
        self.gridLayout.setVerticalSpacing(8)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.labelDirectory = QtGui.QLabel(importSkinImages)
        self.labelDirectory.setObjectName(_fromUtf8("labelDirectory"))
        self.gridLayout.addWidget(self.labelDirectory, 0, 0, 1, 1)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setSpacing(6)
        self.horizontalLayout.setSizeConstraint(QtGui.QLayout.SetMinimumSize)
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.directory = QtGui.QLineEdit(importSkinImages)
        self.directory.setText(_fromUtf8(""))
        self.directory.setReadOnly(True)
        self.directory.setObjectName(_fromUtf8("directory"))
        self.horizontalLayout.addWidget(self.directory)
        self.browse = QtGui.QPushButton(importSkinImages)
        self.browse.setObjectName(_fromUtf8("browse"))
        self.horizontalLayout.addWidget(self.browse)
        self.gridLayout.addLayout(self.horizontalLayout, 0, 1, 1, 1)
        self.labelId = QtGui.QLabel(importSkinImages)
        self.labelId.setObjectName(_fromUtf8("labelId"))
        self.gridLayout.addWidget(self.labelId, 1, 0, 1, 1)
        self.id = QtGui.QLineEdit(importSkinImages)
        self.id.setText(_fromUtf8(""))
        self.id.setObjectName(_fromUtf8("id"))
        self.gridLayout.addWidget(self.id, 1, 1, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName(_fromUtf8("horizontalLayout_2"))
        self.buttonBox = QtGui.QDialogButtonBox(importSkinImages)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.horizontalLayout_2.addWidget(self.buttonBox)
        self.gridLayout_2.addLayout(self.horizontalLayout_2, 1, 0, 1, 1)

        self.retranslateUi(importSkinImages)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), importSkinImages.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), importSkinImages.reject)
        QtCore.QMetaObject.connectSlotsByName(importSkinImages)
        importSkinImages.setTabOrder(self.browse, self.id)
        importSkinImages.setTabOrder(self.id, self.buttonBox)
        importSkinImages.setTabOrder(self.buttonBox, self.directory)

    def retranslateUi(self, importSkinImages):
        importSkinImages.setWindowTitle(QtGui.QApplication.translate("importSkinImages", "Import Skin Images", None, QtGui.QApplication.UnicodeUTF8))
        self.labelDirectory.setText(QtGui.QApplication.translate("importSkinImages", "Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.directory.setPlaceholderText(QtGui.QApplication.translate("importSkinImages", "source image directory", None, QtGui.QApplication.UnicodeUTF8))
        self.browse.setText(QtGui.QApplication.translate("importSkinImages", "Browse", None, QtGui.QApplication.UnicodeUTF8))
        self.labelId.setText(QtGui.QApplication.translate("importSkinImages", "Name", None, QtGui.QApplication.UnicodeUTF8))
        self.id.setPlaceholderText(QtGui.QApplication.translate("importSkinImages", "new skin name", None, QtGui.QApplication.UnicodeUTF8))

