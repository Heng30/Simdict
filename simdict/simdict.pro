QT += quick xml core gui widgets

TEMPLATE = app
TARGET = simdict
CONFIG += c++11

LIBS +=
DEFINES +=

RC_ICONS = favicon.ico
INCLUDEPATH +=

CONFIG(debug, debug|release) {
    LIBS +=
}

CONFIG(release, debug|release) {
    LIBS +=
}

SOURCES += \
        https.cpp \
        main.cpp \

RESOURCES += qml.qrc

HEADERS += \
    https.h \


MOC_DIR = $$PWD/../build/$$TARGET
RCC_DIR = $$PWD/../build/$$TARGET
DESTDIR = $$PWD/../build/$$TARGET
OBJECTS_DIR = $$PWD/../build/$$TARGET
