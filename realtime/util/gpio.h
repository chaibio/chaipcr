#ifndef _GPIO_H_
#define _GPIO_H_

////////////////////////////////////////////////////////////////////////////////
// Class GPIO
class GPIO {
public:
	enum Direction {
		kInput = 0,
		kOutput = 1
	};

	enum Value {
		kLow = 0,
		kHigh = 1
	};
	
	GPIO(unsigned int pinNumber, Direction direction) throw();
	~GPIO();
	
	Value value() const throw();
	void setValue(Value value) throw();
	
	Direction direction() const { return direction_; }
	void setDirection(Direction direction) throw();
	
private:
	void exportPin() throw();
	void unexportPin() throw();
	
private:
	unsigned int pinNumber_; //BeagleBone GPIO Pin Number
	Direction direction_;
};

#endif
