TEMPLATE = app

QT += qml quick sql websockets

CONFIG += c++11

SOURCES += main.cpp \
    sqlcontactmodel.cpp \
    sqlconversationmodel.cpp \
    connect.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =


DISTFILES += \
    backend.js

HEADERS += \
    sqlcontactmodel.h \
    sqlconversationmodel.h
