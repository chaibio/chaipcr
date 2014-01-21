#ifndef _OPTICS_H_
#define _OPTICS_H_

#include "pwm.h"
#include "gpiopin.h"

////////////////////////////////////////////////////////////////////////////////
// Class Optics
class Optics {
public:
	Optics() throw();
	virtual ~Optics();
	
	//accessors
	bool lidOpen() { return lidOpen_; }
	
	void process() throw();
	
private:
	bool lidOpen_;
	GPIOPin lidSensePin_;
};

#endif
