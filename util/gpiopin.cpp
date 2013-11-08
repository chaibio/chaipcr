#include "pcrincludes.h"
#include "gpiopin.h"

#include <sstream>
#include <fstream>
#include <cassert>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class GPIOPin
GPIOPin::GPIOPin(unsigned int pinNumber, unsigned int direction) throw():
	pinNumber_(pinNumber) {
	
	exportPin();
	setDirection(direction);
}

GPIOPin::~GPIOPin() {
	try {
		unexportPin();
	} catch (exception& e) {
		assert(false);
	}
}
	
unsigned int GPIOPin::value() const throw() {
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

void GPIOPin::setValue(unsigned int value) throw() {
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

void GPIOPin::setDirection(unsigned int direction) throw() {
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

void GPIOPin::exportPin() throw() {
	ofstream exportFile;
	exportFile.open("/sys/class/gpio/export");
	exportFile << pinNumber_;
	exportFile.close();
}

void GPIOPin::unexportPin() throw() {
	ofstream unexportFile;
	unexportFile.open("/sys/class/gpio/unexport");
	unexportFile << pinNumber_;
	unexportFile.close();	
}
