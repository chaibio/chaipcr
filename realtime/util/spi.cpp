#include "pcrincludes.h"
#include "spi.h"

#include <cerrno>
#include <cstdio>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

////////////////////////////////////////////////////////////////////////////////
// Class SPIPort
SPIPort::SPIPort(const char* spiDevicePath) throw():
	spiDevicePath_(spiDevicePath),
	deviceFile_(0) {

	deviceFile_ = open(spiDevicePath, O_RDWR);
	if (deviceFile_ < 0)
		throw SPIError("Unable to open SPI device", errno);
}

SPIPort::~SPIPort() {
	if (deviceFile_ > 0)
		close(deviceFile_);
}

void SPIPort::setMode(uint8_t mode) throw() {
	if (ioctl(deviceFile_, SPI_IOC_WR_MODE, &mode) < 0)
		throw SPIError("Unable to change SPI mode", errno);
}

void SPIPort::readBytes(char* rxbuffer, char* txbuffer, unsigned int length, unsigned int speedHz) throw() {
	//create transfer descriptor
	struct spi_ioc_transfer spiTransfer;
	spiTransfer.tx_buf = (__u64)&txbuffer;
	spiTransfer.rx_buf = (__u64)&rxbuffer;
	spiTransfer.len = length;
	spiTransfer.delay_usecs = 0;
	spiTransfer.speed_hz = speedHz;
	spiTransfer.bits_per_word = 0;
	
	//execute transfer
	if (ioctl(deviceFile_, SPI_IOC_MESSAGE(1), &spiTransfer) < 0)
		throw SPIError("SPI read bytes failed", errno);
}
