obj-m := ft5x0x_ts.o
KDIR := /usr/src/kernel
#KDIR := /home/engkan2kit/kerneldev/ft5x0x
all:
	make -C $(KDIR) M=$(shell pwd) modules
clean:
	make -C $(KDIR) M=$(shell pwd) clean

