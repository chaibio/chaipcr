#ifndef _MCPADC_H_
#define _MCPADC_H_

class GPIOPin;

////////////////////////////////////////////////////////////////////////////////
// Class MCPADC
class MCPADC {
public:
	MCPADC(unsigned int csPinNumber) throw();
	~MCPADC();
	
private:
	GPIOPin* csPin_;
};

#endif
