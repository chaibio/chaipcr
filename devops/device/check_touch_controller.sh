#!/bin/sh

        echo "check touchscreen controller"
        if [ -e /dev/input/event1 ]
        then
                echo "Touch device node detected"
        else
                if  i2cdetect -r -y 2 | grep 38
                then
                        if [ -e  /sys/class/i2c-dev/i2c-2/device/2-0038/driver/module/drivers/i2c\:ft5x0x_ts ]
                        then
                                echo Driver is binded
                        else
                                echo Touch controller has no driver binded
                                echo ft5x0x_ts 0x38> /sys/bus/i2c/devices/i2c-2/new_device
                                ls /dev/input/
                        fi
                else
                        echo "Focal Tech contorller was not detected"
                fi
        fi

