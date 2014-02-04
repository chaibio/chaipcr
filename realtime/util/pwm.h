#ifndef _PWM_H_
#define _PWM_H_

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

#endif
