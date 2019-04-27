obj-m := ilitek_aimv20.o
KDIR := /lib/modules/$(shell uname -r)/build

all: mod dtb

mod:
	make -C $(KDIR) M=$(shell pwd) modules

dtb:
	dtc -O dtb -o CHAI-LCDtouch5-00A0.dtbo -b 0 -@ CHAI-LCDtouch5-00A0.dts

install:
	cp CHAI-LCDtouch5-00A0.dtbo /lib/firmware/CHAI-LCDtouch5-00A0.dtbo
	cp ilitek_aimv20.ko /lib/modules/$(shell uname -r)/kernel/drivers/input/touchscreen
	depmod -a
	echo ilitek_aimv20 > /etc/modules-load.d/ilitek_aimv20.conf
	rm -rf /etc/modules-load.d/ft5x0x_ts.conf
	sync

install_mod:
        cp ilitek_aimv20.ko /lib/modules/$(shell uname -r)/kernel/drivers/input$
        depmod -a
        echo ilitek_aimv20 > /etc/modules-load.d/ilitek_aimv20.conf
        sync

clean:
	make -C $(KDIR) M=$(shell pwd) clean
	rm CHAI-LCDtouch5-00A0.dtbo

