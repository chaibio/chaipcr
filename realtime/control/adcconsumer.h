#ifndef ADCCONSUMER_H
#define ADCCONSUMER_H

#include <boost/noncopyable.hpp>

class ADCConsumer : public boost::noncopyable {
public:
    virtual void setADCValue(unsigned int /*adcValue*/) {}
    virtual void setADCValue(unsigned int /*adcValue*/, std::size_t /*channel*/) {}
    virtual void setADCValues(unsigned int /*differentialADCValue*/, unsigned int /*singularADCValue*/) {}
    virtual void setADCValues(unsigned int /*differentialADCValue*/, unsigned int /*singularADCValue*/, std::size_t /*channel*/) {}

    virtual void setADCValueMock(double /*adcValue*/) {}
};

#endif // ADCCONSUMER_H
