#ifndef ADCCONSUMER_H
#define ADCCONSUMER_H

#include <boost/noncopyable.hpp>

class ADCConsumer : public boost::noncopyable {
public:
    virtual void setADCValue(unsigned int /*adcValue*/) {}
    virtual void setADCValues(unsigned int /*differentialADCValue*/, unsigned int /*singularADCValue*/) {}
};

#endif // ADCCONSUMER_H
