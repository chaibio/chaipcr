#ifndef ADCPIN_H
#define ADCPIN_H

#include <string>

class ADCPin
{
public:
    ADCPin(const std::string &path, unsigned int channel = 0);
    ADCPin(const ADCPin &other);

    ADCPin& operator= (const ADCPin &other);

    inline const std::string& path() const { return _path; }

    inline unsigned int channel() const { return _channel; }
    inline void setChannel(unsigned int channel) { _channel = channel; }

    double readValue() const;

private:
    void changeMode();

private:
    std::string _path;
    unsigned int _channel;
};

#endif // ADCPIN_H
