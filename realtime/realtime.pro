QT -= core gui

INCLUDEPATH += ./app/
INCLUDEPATH += ./control/
INCLUDEPATH += ./server/
INCLUDEPATH += ./util/
INCLUDEPATH += ./libraries/include/
INCLUDEPATH += $(BOOST_INCLUDE_PATH)

LIBS += ../realtime/libraries/lib/libPocoFoundation.so
LIBS += ../realtime/libraries/lib/libPocoNet.so
LIBS += ../realtime/libraries/lib/libPocoUtil.so
LIBS += ../realtime/libraries/lib/libPocoXML.so

QMAKE_CC = arm-linux-gnueabi-gcc
QMAKE_CXX = arm-linux-gnueabi-g++
QMAKE_LINK = arm-linux-gnueabi-g++
QMAKE_CXXFLAGS -= -m64
QMAKE_LFLAGS -= -m64
QMAKE_CXXFLAGS += -std=c++11

HEADERS += \
    app/pins.h \
    app/pcrincludes.h \
    app/exceptions.h \
    app/constants.h \
    app/chaistatus.h \
    control/thermistor.h \
    control/qpcrcycler.h \
    control/optics.h \
    control/ltc2444.h \
    control/ledcontroller.h \
    control/heatsink.h \
    control/heatblockzone.h \
    control/heatblock.h \
    control/fan.h \
    control/adccontroller.h \
    server/StatusHandler.h \
    server/RequestHandlerFactory.h \
    server/qpcrserver.h \
    util/spi.h \
    util/pwm.h \
    util/gpio.h

SOURCES += \
    app/pins.cpp \
    app/main.cpp \
    app/exceptions.cpp \
    control/thermistor.cpp \
    control/qpcrcycler.cpp \
    control/optics.cpp \
    control/ltc2444.cpp \
    control/ledcontroller.cpp \
    control/heatsink.cpp \
    control/heatblockzone.cpp \
    control/heatblock.cpp \
    control/fan.cpp \
    control/adccontroller.cpp \
    server/StatusHandler.cpp \
    server/RequestHandlerFactory.cpp \
    server/qpcrserver.cpp \
    util/spi.cpp \
    util/pwm.cpp \
    util/gpio.cpp
