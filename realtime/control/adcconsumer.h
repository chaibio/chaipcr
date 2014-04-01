#ifndef ADCCONSUMER_H
#define ADCCONSUMER_H

//Interface ADCConsumer
class ADCConsumer {
public:
    virtual ~ADCConsumer() {}

    ADCConsumer(ADCConsumer const&) = delete;
    ADCConsumer& operator=(ADCConsumer const&) = delete;

    virtual void setADCValue(unsigned int adcValue) = 0;

protected:
    ADCConsumer() {}

};

#endif // ADCCONSUMER_H
