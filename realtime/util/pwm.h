#ifndef _PWM_H_
#define _PWM_H_

#include <string>
#include <atomic>
#include <memory>

////////////////////////////////////////////////////////////////////////////////
// Class PWMPin
class PWMPin {
public:
    PWMPin(const std::string& pwmDevicePath);
	~PWMPin();
	
    void setPWM(unsigned long duty, unsigned long period, unsigned int polarity);

private:
    void writePWMFile(const std::string& relativePath, unsigned long value);

private:
	const std::string& pwmDevicePath_;
};

class PWMControl {
public:
    PWMControl(const std::string &devicePath, unsigned long period, unsigned int polarity = 0)
        :_pwm(devicePath) {
        _period = period;
        _polarity = polarity;
        _dutyCycle = 0;
    }

    virtual ~PWMControl() {}

    inline unsigned long pwmPeriod() const { return _period; }
    inline void setPWMPeriod(unsigned long period) { _period = period; processPWM(); }

    inline unsigned long pwmDutyCycle() const { return _dutyCycle; }
    inline void setPWMDutyCycle(unsigned long dutyCycle) { dutyCycle <= _period ? _dutyCycle = dutyCycle : _dutyCycle = _period.load(); processPWM(); }
    inline void setPWMDutyCycle(double dutyCycle) { dutyCycle *= _period.load(); dutyCycle <= _period ? _dutyCycle = dutyCycle : _dutyCycle = _period.load(); processPWM(); }

    inline unsigned int pwmPolarity() const { return _polarity; }
    inline void setPWMPolarity(unsigned int polarity) { _polarity = polarity; processPWM(); }

    inline double drive() const { return !_drive ? ((double)pwmDutyCycle() / pwmPeriod()) : *_drive; }
    inline void setDrive(double drive) { _drive.reset(new double(drive)); }
    inline void resetDrive() { _drive.reset(); }

protected:
    inline void processPWM() { _pwm.setPWM(pwmDutyCycle(), pwmPeriod(), pwmPolarity()); }

private:
    PWMPin _pwm;
    std::atomic<unsigned long> _period;
    std::atomic<unsigned long> _dutyCycle;
    std::atomic<unsigned int> _polarity;

    std::shared_ptr<double> _drive;
};

#endif
