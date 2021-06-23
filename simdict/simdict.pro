QT += quick xml core gui widgets

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

SOURCES += \
        globalshortcutforward.cpp \
        https.cpp \
        main.cpp \
        process.cpp \
        qglobalshortcut/qglobalshortcut.cc

RESOURCES += qml.qrc

HEADERS += \
    globalshortcutforward.h \
    https.h \
    process.h \
    qglobalshortcut/qglobalshortcut.h

win32:SOURCES += qglobalshortcut/qglobalshortcut_win.cc
linux:SOURCES += qglobalshortcut/qglobalshortcut_x11.cc
macx:SOURCES  += qglobalshortcut/sqglobalshortcut_macx.cc
