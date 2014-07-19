#ifndef ADCCONSUMER_H
#define ADCCONSUMER_H

#include <boost/noncopyable.hpp>

class ADCConsumer : public boost::noncopyable {
public:
    virtual void setADCValues(unsigned int firstADCValue, unsigned int secondADCValue = 0) = 0;
};

#endif // ADCCONSUMER_H
