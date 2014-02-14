#include "pcrincludes.h"

#include "gpio.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class GPIO
GPIO::GPIO(unsigned int pinNumber, Direction direction) :
	pinNumber_(pinNumber) {
	
	exportPin();
	setDirection(direction);
}

GPIO::~GPIO() {
	try {
		unexportPin();
	} catch (exception& e) {
		assert(false);
	}
}
	
GPIO::Value GPIO::value() const {
	ostringstream filePath;
	ifstream valueFile;
	char buf[2];
	
	filePath << "/sys/class/gpio/gpio" << pinNumber_ << "/value";
	valueFile.open(filePath.str());
	valueFile >> buf;
	valueFile.close();
	
	switch (buf[0]) {
	case '0':
		return kLow;
	
	case '1':
		return kHigh;
		
	default:
		throw GPIOError("Unexpected GPIO value");
	}
}

void GPIO::setValue(Value value, bool checkValue) {
    if (checkValue && value == this->value())
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
}

void GPIO::setDirection(Direction direction) {
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
	ofstream exportFile;
	exportFile.open("/sys/class/gpio/export");
	exportFile << pinNumber_;
}

void GPIO::unexportPin() {
	ofstream unexportFile;
	unexportFile.open("/sys/class/gpio/unexport");
	unexportFile << pinNumber_;
}
