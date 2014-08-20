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
	
    GPIO(unsigned int pinNumber, Direction direction);
    GPIO(const GPIO &other) = delete;
    GPIO(GPIO &&other);
	~GPIO();

    GPIO& operator= (const GPIO &other) = delete;
    GPIO& operator= (GPIO &&other);
	
    Value value() const;
    void setValue(Value value, bool checkValue = false);

    Value waitValue(Value value);
    void stopWaitinigValue();
	
	Direction direction() const { return direction_; }
    void setDirection(Direction direction);
	
private:
    void exportPin();
    void unexportPin();
	
private:
	unsigned int pinNumber_; //BeagleBone GPIO Pin Number
	Direction direction_;

    int stopWaitinigFd_;

    mutable Value savedValue_;
};

#endif
