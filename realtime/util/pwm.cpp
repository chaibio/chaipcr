#include "pwm.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
PWMPin::PWMPin(const string& pwmDevicePath) {
    dutyFile.exceptions(ofstream::failbit | ofstream::badbit);
    periodFile.exceptions(ofstream::failbit | ofstream::badbit);
    polarityFile.exceptions(ofstream::failbit | ofstream::badbit);

    dutyFile.open(pwmDevicePath + "/duty", ofstream::out);
    periodFile.open(pwmDevicePath + "/period", ofstream::out);
    polarityFile.open(pwmDevicePath + "/polarity", ofstream::out);
}

PWMPin::~PWMPin() {
}

void PWMPin::setPWM(unsigned long duty, unsigned long period, unsigned int polarity) {  //should add some locks here
    //write values
    writePWMFile(dutyFile, duty);
    writePWMFile(periodFile, period);
    writePWMFile(polarityFile, polarity);
}

void PWMPin::writePWMFile(ostream &stream, unsigned long value) {
    stream << value;
    stream.flush();

    stream.seekp(0, ostream::beg);
}
