QT += quick xml core gui widgets

TEMPLATE = app
TARGET = simdict
CONFIG += c++11

RC_ICONS = favicon.ico

window {
    DEFINES += Q_O_WINDOW
}

linux {
    QT += x11extras
    LIBS += -lX11 -lxcb -lXmu
    DEFINES += Q_O_LINUX

    INCLUDEPATH += $$PWD/../xclip

    CONFIG(debug, debug|release) {
        LIBS += -L$$PWD/../build/xclip -lxclipd
    }

    CONFIG(release, debug|release) {
        LIBS += -L$$PWD/../build/xclip -lxclip
    }
}

DEFINES += NO_XCLIP_PROGRAM

INCLUDEPATH += qglobalshortcut
INCLUDEPATH += dictapi

SOURCES += \
        dictapi/youdaoapi.cpp \
        globalshortcutforward.cpp \
        https.cpp \
        main.cpp \
        process.cpp \
        qglobalshortcut/qglobalshortcut.cc

RESOURCES += qml.qrc

HEADERS += \
    dictapi/youdaoapi.h \
    globalshortcutforward.h \
    https.h \
    process.h \
    qglobalshortcut/qglobalshortcut.h

win32:SOURCES += qglobalshortcut/qglobalshortcut_win.cc
linux:SOURCES += qglobalshortcut/qglobalshortcut_x11.cc
macx:SOURCES  += qglobalshortcut/sqglobalshortcut_macx.cc

isEmpty(BINDIR):BINDIR=/usr/bin
isEmpty(APPDIR):APPDIR=/usr/share/applications
isEmpty(DSRDIR):DSRDIR=/usr/share/simdict

target.path = $$INSTROOT$$BINDIR
icon_files.path = $$PREFIX/share/icons/hicolor/scalable/apps/
icon_files.files = $$PWD/favicon.ico

desktop.path = $$INSTROOT$$APPDIR
desktop.files = simdict.desktop

INSTALLS += target desktop icon_files
