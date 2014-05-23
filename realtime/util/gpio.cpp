#include "pcrincludes.h"

#include "gpio.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class GPIO
GPIO::GPIO(unsigned int pinNumber, Direction direction) :
	pinNumber_(pinNumber) {
	
	exportPin();
	setDirection(direction);

    savedValue = value();
}

GPIO::GPIO(GPIO &&other) {
    pinNumber_ = other.pinNumber_;
    direction_ = other.direction_;
    savedValue = other.savedValue;

    other.pinNumber_ = UINT_MAX;
}

GPIO::~GPIO() {
	try {
		unexportPin();
	} catch (exception& e) {
		assert(false);
	}
}

GPIO& GPIO::operator= (GPIO &&other) {
    pinNumber_ = other.pinNumber_;
    direction_ = other.direction_;
    savedValue = other.savedValue;

    other.pinNumber_ = UINT_MAX;

    return *this;
}
	
GPIO::Value GPIO::value() const {
    if (pinNumber_ == UINT_MAX)
        throw GPIOError("GPIO is moved");

	ostringstream filePath;
	ifstream valueFile;
	char buf[2];
	
	filePath << "/sys/class/gpio/gpio" << pinNumber_ << "/value";
	valueFile.open(filePath.str());
	valueFile >> buf;
	valueFile.close();
	
	switch (buf[0]) {
	case '0':
        savedValue = kLow;
		return kLow;
	
	case '1':
        savedValue = kHigh;
		return kHigh;
		
	default:
		throw GPIOError("Unexpected GPIO value");
	}
}

void GPIO::setValue(Value value, bool checkValue) {
    if (pinNumber_ == UINT_MAX)
        throw GPIOError("GPIO is moved");

    if (checkValue && value == savedValue)
        return;

	if (direction_ != kOutput)
		throw InvalidState("Attempt to set value of non-output GPIO pin");
	
	ostringstream filePath;
	ofstream valueFile;
	
	filePath << "/sys/class/gpio/gpio" << pinNumber_ << "/value";
	valueFile.open(filePath.str());
	
	switch (value) {
	case kLow:
		valueFile << "0";
		break;
	
	case kOutput:
		valueFile << "1";
		break;
	
	default:
		throw invalid_argument("Invalid GPIO value");
	}
	
	valueFile.close();
    savedValue = value;
}

void GPIO::setDirection(Direction direction) {
    if (pinNumber_ == UINT_MAX)
        throw GPIOError("GPIO is moved");

	ostringstream filePath;
	ofstream directionFile;
	
	filePath << "/sys/class/gpio/gpio" << pinNumber_ << "/direction";
	directionFile.open(filePath.str());
	
	switch (direction) {
	case kInput:
		directionFile << "in";
		break;
	
	case kOutput:
		directionFile << "out";
		break;
	
	default:
		throw invalid_argument("Invalid direction");
	}
	
	directionFile.close();
	
	direction_ = direction;
}

void GPIO::exportPin() {
    if (pinNumber_ != UINT_MAX) {
        ofstream exportFile;
        exportFile.open("/sys/class/gpio/export");
        exportFile << pinNumber_;
    }
}

void GPIO::unexportPin() {
    if (pinNumber_ != UINT_MAX) {
        ofstream unexportFile;
        unexportFile.open("/sys/class/gpio/unexport");
        unexportFile << pinNumber_;
    }
}
