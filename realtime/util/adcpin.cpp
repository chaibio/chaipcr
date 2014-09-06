#include "adcpin.h"

#include <fstream>
#include <sstream>

#define REF_VOLTAGE 1.8
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
    std::stringstream channelPath;
    channelPath << path() << "/in_voltage" << channel() << "_raw";

    std::ifstream channelFile(channelPath.str().c_str());

    int value = 0;
    channelFile >> value;

    return REF_VOLTAGE * value / MAX_VALUE;
}

double ADCPin::resistance() const
{
    double voltage = readVoltage();

    return (6.8 * voltage) / (REF_VOLTAGE - voltage);
}

void ADCPin::changeMode()
{
    std::ofstream modeFile(std::string(path() + "/mode").c_str());
    modeFile << "oneshot";
}
