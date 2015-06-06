obj-m := ili210x.o
KDIR := /lib/modules/$(shell uname -r)/build
#KDIR := /home/engkan2kit/kerneldev/ft5x0x
all:
	make -C $(KDIR) M=$(shell pwd) modules
clean:
	make -C $(KDIR) M=$(shell pwd) clean

