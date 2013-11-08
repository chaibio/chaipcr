#ifndef _GPIOPIN_H_
#define _GPIOPIN_H_

////////////////////////////////////////////////////////////////////////////////
// Class GPIOPin
class GPIOPin {
public:
	enum Direction {
		kInput = 0,
		kOutput = 1
	};

	enum Value {
		kLow = 0,
		kHigh = 1
	};
	
	GPIOPin(unsigned int pinNumber, unsigned int direction) throw();
	~GPIOPin();
	
	unsigned int value() const throw();
	void setValue(unsigned int value) throw();
	
	unsigned int direction() const { return direction_; }
	void setDirection(unsigned int direction) throw();
	
private:
	void exportPin() throw();
	void unexportPin() throw();
	
private:
	unsigned int pinNumber_; //BeagleBone GPIO Pin Number
	unsigned int direction_;
};

#endif
