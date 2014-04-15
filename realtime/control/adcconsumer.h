#ifndef ADCCONSUMER_H
#define ADCCONSUMER_H

#include <boost/noncopyable.hpp>

class ADCConsumer : public boost::noncopyable {
public:
    virtual void setADCValue(unsigned int adcValue) = 0;
};

#endif // ADCCONSUMER_H
