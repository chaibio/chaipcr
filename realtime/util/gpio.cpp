//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "gpio.h"
#include "exceptions.h"
#include "logger.h"

#include <limits>
#include <system_error>
#include <sstream>
#include <cstring>

#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <sys/stat.h>
#include <sys/eventfd.h>

GPIO::GPIO(unsigned int pinNumber, Direction direction, Type type)
{
    if (pinNumber == std::numeric_limits<unsigned int>::max())
        std::logic_error("Invalid pin number");

    _pinNumber = pinNumber;
    _type = type;
    _pollFd = -1;
    _cancelPollFd = -1;
    _savedValue = kLow;

    exportPin();
#ifdef KERNEL_49
    if(direction==kInput)
  	changeEdge();
#else  	
    changeEdge();
#endif
    setDirection(direction);

    if (type == kDirect)
        setupStream();
    else if (type == kPoll)
        setupPoll();
}

GPIO::GPIO(GPIO &&other)
{
    if (other._pinNumber == std::numeric_limits<unsigned int>::max())
        std::logic_error("GPIO has already been moved");

    _pinNumber = other._pinNumber;
    _direction = other._direction;
    _type = other._type;
    _pollFd = other._pollFd;
    _cancelPollFd = other._cancelPollFd;

    if (_type == kDirect) //The current version of the compiler does not support move for streams
        setupStream();

    other._pinNumber = std::numeric_limits<unsigned int>::max();
    other._pinStream.close();
    other._pollFd = -1;
    other._cancelPollFd = -1;
}

GPIO::~GPIO()
{
    close(_pollFd);
    close(_cancelPollFd);
}

GPIO& GPIO::operator =(GPIO &&other)
{
    if (other._pinNumber == std::numeric_limits<unsigned int>::max())
        std::logic_error("GPIO has already been moved");

    close(_pollFd);
    close(_cancelPollFd);

    _pinStream.close();

    _pinNumber = other._pinNumber;
    _direction = other._direction;
    _type = other._type;
    _pollFd = other._pollFd;
    _cancelPollFd = other._cancelPollFd;
    _savedValue = other._savedValue.load();

    if (_type == kDirect) //The current version of the compiler does not support move for streams
        setupStream();

    other._pinNumber = std::numeric_limits<unsigned int>::max();
    other._pinStream.close();
    other._pollFd = -1;
    other._cancelPollFd = -1;

    return *this;
}

GPIO::Value GPIO::value() const
{
    if (_type != kDirect)
        std::logic_error("GPIO is not setup for direct access");

    if (_pinNumber == std::numeric_limits<unsigned int>::max())
        throw std::logic_error("GPIO has been moved");

    if (_direction == kOutput)
        return _savedValue;

    char buffer[2] = { 0, 0 };

    {
        std::lock_guard<std::mutex> lock(_pinStreamMutex);

        try
        {
            _pinStream >> buffer;
            _pinStream.clear();
            _pinStream.seekg(0);
        }
        catch (...)
        {
            throw std::system_error(errno, std::generic_category(), "Unable to read a pin (" + std::to_string(_pinNumber) + "):");
        }
    }

    switch (buffer[0])
    {
    case '0':
        return kLow;

    case '1':
        return kHigh;

    default:
        throw std::runtime_error("Unexpected GPIO value");
    }
}

void GPIO::setValue(Value value, bool forceUpdate)
{
    if (value != kLow || value != kHigh)
        std::logic_error("Invalid GPIO value");

    if (_type != kDirect)
        std::logic_error("GPIO is not setup for direct access");

    if (_pinNumber == std::numeric_limits<unsigned int>::max())
        throw std::logic_error("GPIO has been moved");

    if (_direction != kOutput)
        throw std::logic_error("Attempt to set a value to a non-output GPIO pin");

    std::lock_guard<std::mutex> lock(_pinStreamMutex);

    if (!forceUpdate && value == _savedValue)
        return;

    char buffer[2] = { 0, 0 };

    try
    {
        _pinStream << value;
        _pinStream.flush();
        _pinStream.seekp(0);

        _pinStream >> buffer;
        _pinStream.clear();
        _pinStream.seekg(0);
    }
    catch (...)
    {
        APP_LOGGER << "GPIO::setValue - Unable to change a pin (" << _pinNumber << "): " << std::strerror(errno) << std::endl;
        return;
    }

    switch (buffer[0])
    {
    case '0':
        _savedValue = kLow;
        break;

    case '1':
        _savedValue = kHigh;
        break;

    default:
        throw std::runtime_error("Unexpected GPIO value");
    }

    if (value != _savedValue)
        APP_LOGGER << "GPIO::setValue - Unable to change GPIO's (" << _pinNumber << ") value from " << _savedValue << " to " << value << std::endl;
}

bool GPIO::pollValue(Value expectedValue, Value &value)
{
    if (_pollFd == -1)
        throw std::logic_error("GPIO is not setup for polling");

    char buffer[sizeof(int64_t)];

    if (read(_pollFd, buffer, sizeof(buffer) - 1) == -1)
        throw std::system_error(errno, std::generic_category(), "Unable to read GPIO:");

    if (lseek(_pollFd, 0, SEEK_SET) == -1)
        throw std::system_error(errno, std::generic_category(), "Unable to seek GPIO:");

    if ((buffer[0] == '0' && expectedValue == kLow) || (buffer[0] == '1' && expectedValue == kHigh))
    {
        value = expectedValue;
        return true;
    }

    pollfd fdArray[2];
    fdArray[0].fd = _pollFd;
    fdArray[0].events = POLLPRI;
    fdArray[0].revents = 0;

    fdArray[1].fd = _cancelPollFd;
    fdArray[1].events = POLLIN;
    fdArray[1].revents = 0;

    if (poll(fdArray, 2, -1) > 0)
    {
        if (fdArray[0].revents > 0) //GPIO event
        {
            if (fdArray[0].revents | POLLIN || fdArray[0].revents | POLLPRI)
            {
                if (read(_pollFd, buffer, sizeof(buffer) - 1) == -1)
                    throw std::system_error(errno, std::generic_category(), "Unable to read GPIO:");

                if (lseek(_pollFd, 0, SEEK_SET) == -1)
                    throw std::system_error(errno, std::generic_category(), "Unable to seek GPIO:");

                switch (buffer[0])
                {
                case '0':
                    value = kLow;
                    break;

                case '1':
                    value = kHigh;
                    break;

                default:
                    throw std::runtime_error("Unexpected GPIO value");
                }
            }
            else
                throw std::runtime_error("Unexpected GPIO event occured");
        }
        else //Cancel
        {
            read(_cancelPollFd, buffer, sizeof(int64_t));
            return false;
        }
    }
    else
        throw std::system_error(errno, std::generic_category(), "Unable to poll a pin (" + std::to_string(_pinNumber) + "):");

    return true;
}

void GPIO::cancelPolling()
{
    if (_cancelPollFd != -1)
    {
        int64_t i = 1;
        write(_cancelPollFd, &i, sizeof(i));
    }
}

void GPIO::exportPin()
{
    try
    {
        std::ofstream exportFile;
        exportFile.exceptions(std::ofstream::failbit | std::ofstream::badbit);
        exportFile.open("/sys/class/gpio/export");
        exportFile << _pinNumber;
    }
    catch (...)
    {
        throw std::system_error(errno, std::generic_category(), "Unable to export a pin (" + std::to_string(_pinNumber) + "):");
    }
}

void GPIO::changeEdge()
{
    try
    {
        std::ofstream edgeFile;
        edgeFile.exceptions(std::ofstream::failbit | std::ofstream::badbit);
        edgeFile.open("/sys/class/gpio/gpio" + std::to_string(_pinNumber) + "/edge");
        edgeFile << "both";
    }
    catch (...)
    {
        throw std::system_error(errno, std::generic_category(), "Unable to set the edge of a pin (" + std::to_string(_pinNumber) + "):");
    }
}

void GPIO::setDirection(Direction direction)
{
    _direction = direction;

    try
    {
        std::ofstream directionFile;
        directionFile.exceptions(std::ofstream::failbit | std::ofstream::badbit);
        directionFile.open("/sys/class/gpio/gpio" + std::to_string(_pinNumber) + "/direction");

        switch (direction)
        {
        case kInput:
            directionFile << "in";
            break;

        case kOutput:
            directionFile << "out";
            break;

        default:
            throw std::logic_error("Invalid GPIO direction");
        }
    }
    catch (const std::logic_error &/*ex*/)
    {
        throw;
    }
    catch (...)
    {
        throw std::system_error(errno, std::generic_category(), "Unable to set the direction of a pin (" + std::to_string(_pinNumber) + "):");
    }
}

void GPIO::setupStream()
{
    try
    {
        _pinStream.exceptions(std::fstream::failbit | std::fstream::badbit);
        _pinStream.open("/sys/class/gpio/gpio" + std::to_string(_pinNumber) + "/value");
    }
    catch (...)
    {
        throw std::system_error(errno, std::generic_category(), "Unable to open a pin (" + std::to_string(_pinNumber) + "):");
    }

    char buffer[2] = { 0, 0 };

    try
    {
        _pinStream >> buffer;
        _pinStream.clear();
        _pinStream.seekg(0);
    }
    catch (...)
    {
        throw std::system_error(errno, std::generic_category(), "Unable to read a pin (" + std::to_string(_pinNumber) + "):");
    }

    switch (buffer[0])
    {
    case '0':
        _savedValue = kLow;
        break;

    case '1':
        _savedValue = kHigh;
        break;

    default:
        throw std::runtime_error("Unexpected GPIO value");
    }
}

void GPIO::setupPoll()
{
    std::stringstream filePath;
    filePath << "/sys/class/gpio/gpio" << _pinNumber << "/value";

    _pollFd = open(filePath.str().c_str(), O_RDONLY | O_NONBLOCK);

    if (_pollFd == -1)
        throw std::system_error(errno, std::generic_category(), "Unable to open a pin (" + std::to_string(_pinNumber) + "):");

    _cancelPollFd = eventfd(0, EFD_NONBLOCK);

    if (_cancelPollFd == -1)
    {
        close(_pollFd);

        throw std::system_error(errno, std::generic_category(), "Unable to create an even fd:");
    }
}

void GPIO::unexportPin()
{
    std::ofstream unexportFile;
    unexportFile.open("/sys/class/gpio/unexport");
    unexportFile << _pinNumber;
}
