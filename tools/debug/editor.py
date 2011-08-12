#-------------------------------------------------------------------------
# qsci_simple_pythoneditor.pyw
#
# QScintilla sample with PyQt
#
# Eli Bendersky (eliben@gmail.com)
# This code is in the public domain
#-------------------------------------------------------------------------
import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.Qsci import QsciScintilla, QsciLexerLua

class LuaEditor(QsciScintilla):
    ARROW_MARKER_NUM = 8

    def __init__(self, parent=None):
        super(LuaEditor, self).__init__(parent)

        self.setTabWidth(4)
        
        self.setBraceMatching(QsciScintilla.SloppyBraceMatch)
        self.setAutoIndent(1)
        self.setIndentationWidth(4)
        self.setIndentationGuides(1)
        self.setIndentationsUseTabs(0)
        self.setAutoCompletionThreshold(2)
        #self.SendScintilla(QsciScintilla.SCI_SETTABWIDTH, 4)
    
        # Set the default font
        font = QFont()
        font.setFamily('Monospace')
        font.setFixedPitch(True)
        font.setPointSize(10)
        self.setFont(font)
        self.setMarginsFont(font)

        # Margin 0 is used for line numbers
        fontmetrics = QFontMetrics(font)
        self.setMarginsFont(font)
        self.setMarginWidth(0, fontmetrics.width("00000") + 6)
        self.setMarginLineNumbers(0, True)
        self.setMarginsBackgroundColor(QColor("#E6E6E6"))

        # Clickable margin 1 for showing markers
        self.setMarginSensitivity(1, True)
        self.connect(self,
            SIGNAL('marginClicked(int, int, Qt::KeyboardModifiers)'),
            self.on_margin_clicked)
        self.markerDefine(QsciScintilla.RightArrow,
            self.ARROW_MARKER_NUM)
        self.setMarkerBackgroundColor(QColor("#ee1111"),
            self.ARROW_MARKER_NUM)

        # Brace matching: enable for a brace immediately before or after
        # the current position
        #
        self.setBraceMatching(QsciScintilla.SloppyBraceMatch)

        # Current line visible with special background color
        self.setCaretLineVisible(True)
        self.setCaretLineBackgroundColor(QColor("#ffe4e4"))

        # Set Python lexer
        # Set style for Python comments (style number 1) to a fixed-width
        # courier.
        #
        lexer = QsciLexerLua()
        lexer.setDefaultFont(font)
        self.setLexer(lexer)
        #self.SendScintilla(QsciScintilla.SCI_STYLESETSIZE, 1, 12)
        #self.SendScintilla(QsciScintilla.SCI_STYLESETFORE, 1, 0xBFBFBF)
        #self.SendScintilla(QsciScintilla.SCI_STYLESETFONT, 1, 'Monospace')

        # Don't want to see the horizontal scrollbar at all
        # Use raw message to Scintilla here (all messages are documented
        # here: http://www.scintilla.org/ScintillaDoc.html)
        #self.SendScintilla(QsciScintilla.SCI_SETHSCROLLBAR, 0)

        # not too small
        self.setMinimumSize(600, 450)

    def on_margin_clicked(self, nmargin, nline, modifiers):
        # Toggle marker for the line the margin was clicked on
        if self.markersAtLine(nline) != 0:
            self.markerDelete(nline, self.ARROW_MARKER_NUM)
        else:
            self.markerAdd(nline, self.ARROW_MARKER_NUM)
            
    def readFile(self, path):
        self.setText(open(path).read())
        
    def save(self, statusBar):
        path = self.path
        try:
            f = open(path,'w+')
        except:
            statusBar.message('Could not write to %s' % (path),2000)
            return

        f.write(self.text())
        f.close()

        statusBar.showMessage('File %s saved' % (path), 2000)
            
if __name__ == "__main__":
    app = QApplication(sys.argv)
    editor = LuaEditor()
    editor.show()
    editor.setText(open(sys.argv[0]).read())
    app.exec_()
