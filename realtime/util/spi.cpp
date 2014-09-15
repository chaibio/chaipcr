#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

#include "pcrincludes.h"
#include "spi.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class SPIPort
SPIPort::SPIPort(const string& spiDevicePath) :
	spiDevicePath_(spiDevicePath),
	deviceFile_(0) {

	deviceFile_ = open(spiDevicePath.c_str(), O_RDWR);
	if (deviceFile_ < 0)
		throw SPIError("Unable to open SPI device", errno);
}

SPIPort::SPIPort(const SPIPort &other) :
    spiDevicePath_(other.spiDevicePath_),
    deviceFile_(0) {

    deviceFile_ = open(spiDevicePath_.c_str(), O_RDWR);
    if (deviceFile_ < 0)
        throw SPIError("Unable to open SPI device", errno);
}

SPIPort::SPIPort(SPIPort &&other) {
    spiDevicePath_ = std::move(other.spiDevicePath_);
    deviceFile_ = other.deviceFile_;

    other.deviceFile_ = 0;
}

SPIPort::~SPIPort() {
	if (deviceFile_ > 0)
		close(deviceFile_);
}

SPIPort& SPIPort::operator= (const SPIPort &other) {
    spiDevicePath_ = other.spiDevicePath_;
    deviceFile_ = 0;

    deviceFile_ = open(spiDevicePath_.c_str(), O_RDWR);
    if (deviceFile_ < 0)
        throw SPIError("Unable to open SPI device", errno);

    return *this;
}

SPIPort& SPIPort::operator= (SPIPort &&other) {
    spiDevicePath_ = std::move(other.spiDevicePath_);
    deviceFile_ = other.deviceFile_;

    other.deviceFile_ = 0;

    return *this;
}

void SPIPort::setMode(uint8_t mode) {
	if (ioctl(deviceFile_, SPI_IOC_WR_MODE, &mode) < 0)
		throw SPIError("Unable to change SPI mode", errno);
}

void SPIPort::readBytes(char* rxbuffer, char* txbuffer, unsigned int length, unsigned int speedHz) {
    //create transfer descriptor
	struct spi_ioc_transfer spiTransfer;
	spiTransfer.tx_buf = (unsigned long)txbuffer;
	spiTransfer.rx_buf = (unsigned long)rxbuffer;
	spiTransfer.len = length;
	spiTransfer.delay_usecs = 0;
	spiTransfer.speed_hz = speedHz;
    spiTransfer.bits_per_word = 0;
    spiTransfer.cs_change = 0;
    spiTransfer.pad = 0;

	//execute transfer
	if (ioctl(deviceFile_, SPI_IOC_MESSAGE(1), &spiTransfer) < 0)
        throw SPIError("SPI read bytes failed", errno);
}
