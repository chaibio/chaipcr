#include "pwm.h"

#include <system_error>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
PWMPin::PWMPin(const string& pwmDevicePath) {
    dutyFile.exceptions(ofstream::failbit | ofstream::badbit);
    periodFile.exceptions(ofstream::failbit | ofstream::badbit);
    polarityFile.exceptions(ofstream::failbit | ofstream::badbit);

    try {
        dutyFile.open(pwmDevicePath + "/duty", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/duty) -");
    }

    try {
        periodFile.open(pwmDevicePath + "/period", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/period) -");
    }

    try {
        polarityFile.open(pwmDevicePath + "/polarity", ofstream::out);
    }
    catch (const exception&) {
        throw system_error(errno, generic_category(), "Unexpected PWM error: unable to open pin (" + pwmDevicePath + "/polarity) -");
    }
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
