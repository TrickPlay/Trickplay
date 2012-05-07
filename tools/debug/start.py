#!/usr/bin/env python

# Allow keyboard interrupt with ^C
import os
import sys
import signal

from wizard import Wizard
from main import MainWindow

from PyQt4.QtGui import QApplication
from PyQt4.QtCore import QCoreApplication, QSettings, QT_VERSION_STR, QProcessEnvironment, QEvent

signal.signal(signal.SIGINT, signal.SIG_DFL)

class MyApp(QApplication):
  def __init__(self, argv):
    QApplication.__init__(self, argv)

  def event(self, e):
    if e.type() == QEvent.ApplicationActivate :
        if hasattr(self.main, 'editorManager'):
            if hasattr(self.main.editorManager, 'tab'):
                if self.main.editorManager.tab is not None:
                    if self.main.editorManager.tab.count() > 0 : 
                        index = self.main.editorManager.tab.currentIndex()
                        self.main.editorManager.tab.changeTab(index)

    return QApplication.event(self, e)

def main(argv):

    path = None
    first_arg = None
    second_arg = None
    config = None
    apath = None
    print("QT VERSION %s" % QT_VERSION_STR )

    try:
        first_arg = argv[1]
        second_arg = argv[2]
    except IndexError:
        pass

    if first_arg is not None:
        if first_arg == "-c":
            config = True 
            if second_arg is not None:
                path = second_arg
        else:
            path = first_arg
        
    try:
        #app = QApplication(argv)
        app = MyApp(argv)

        QCoreApplication.setOrganizationDomain('www.trickplay.com');
        QCoreApplication.setOrganizationName('Trickplay');
        QCoreApplication.setApplicationName('Trickplay Debugger');
        QCoreApplication.setApplicationVersion('0.0.1');
            
        s = QProcessEnvironment.systemEnvironment().toStringList()
        for item in s:
            k , v = str( item ).split( "=" , 1 )
            if k == 'PWD':
                apath = v

        apath = os.path.join(apath, os.path.dirname(str(argv[0])))
        main = MainWindow(app, apath)
        main.config = config

        main.show()
        main.raise_()
        wizard = Wizard()
        app.main = main

        path = wizard.start(path)
        if path:
            settings = QSettings()
            settings.setValue('path', path)

            app.setActiveWindow(main)
            main.start(path, wizard.filesToOpen())
            main.show()

        sys.exit(app.exec_())

    # TODO, better way of doing this for 'clean' exit...
    except KeyboardInterrupt:
		exit("Exited")


if __name__ == '__main__':
    main(sys.argv)
