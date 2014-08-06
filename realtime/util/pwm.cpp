#include <sstream>
#include <fstream>

#include "pwm.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
PWMPin::PWMPin(const string& pwmDevicePath) :
	pwmDevicePath_ (pwmDevicePath) {
}

PWMPin::~PWMPin() {
}

void PWMPin::setPWM(unsigned long duty, unsigned long period, unsigned int polarity) {  //should add some locks here
	//write values
	writePWMFile("/duty", duty);
	writePWMFile("/period", period);
	writePWMFile("/polarity", polarity);
}

void PWMPin::writePWMFile(const string& relativePath, unsigned long value) {
	ostringstream filePath;
	filePath << pwmDevicePath_ << relativePath;
	ofstream file;
	file.open(filePath.str());
	file << value;
    file.close();
}
