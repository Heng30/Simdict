QT += quick xml core gui widgets

CONFIG += c++11

linux {
    QT += x11extras
    LIBS += -lX11 -lxcb
}

INCLUDEPATH += qglobalshortcut

SOURCES += \
        globalshortcutforward.cpp \
        https.cpp \
        main.cpp \
        qglobalshortcut/qglobalshortcut.cc

RESOURCES += qml.qrc

HEADERS += \
    globalshortcutforward.h \
    https.h \
    qglobalshortcut/qglobalshortcut.h

win32:SOURCES += qglobalshortcut/qglobalshortcut_win.cc
linux:SOURCES += qglobalshortcut/qglobalshortcut_x11.cc
macx:SOURCES  += qglobalshortcut/sqglobalshortcut_macx.cc
