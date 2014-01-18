#include <sstream>
#include <fstream>

#include "pwm.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
PWMPin::PWMPin(const string& pwmDevicePath) throw():
	pwmDevicePath_ (pwmDevicePath) {
}

PWMPin::~PWMPin() {
}

void PWMPin::setPWM(unsigned long duty, unsigned long period, unsigned int polarity) throw() {
	//write values
	writePWMFile("/duty", duty);
	writePWMFile("/period", period);
	writePWMFile("/polarity", polarity);
}

void PWMPin::writePWMFile(const string& relativePath, unsigned long value) throw() {
	ostringstream filePath;
	filePath << pwmDevicePath_ << relativePath;
	ofstream file;
	file.open(filePath.str());
	file << value;
}
