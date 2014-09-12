#include "pcrincludes.h"
#include "adcpin.h"

#include <fstream>
#include <sstream>

#define MAX_VALUE 4095

ADCPin::ADCPin(const std::string &path, unsigned int channel)
{
    _path = path;
    _channel = channel;

    changeMode();
}

ADCPin::ADCPin(const ADCPin &other)
    :ADCPin(other.path(), other.channel())
{
}

ADCPin& ADCPin::operator= (const ADCPin &other)
{
    _path = other.path();
    _channel = other.channel();

    return *this;
}

double ADCPin::readVoltage() const
{
    return kBeagleboneADCReverenceVoltage * readValue() / MAX_VALUE;
}

double ADCPin::readValue() const {
    std::stringstream channelPath;
    channelPath << path() << "/in_voltage" << channel() << "_raw";

    std::ifstream channelFile(channelPath.str());

    int value = 0;
    channelFile >> value;
    return value;
}

void ADCPin::changeMode()
{
    std::ofstream modeFile(path() + "/mode");
    modeFile << "oneshot";
}
