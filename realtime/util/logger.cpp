#include "logger.h"

#include <Poco/SimpleFileChannel.h>
#include <Poco/ConsoleChannel.h>
#include <Poco/AsyncChannel.h>

Poco::Logger* Logger::_logger = nullptr;

void Logger::setup(const std::string &name)
{
    Poco::Logger::root().setChannel(new Poco::AsyncChannel(new Poco::ConsoleChannel()));

    _logger = &Poco::Logger::get(name);
    _logger->information("--------------------------------- Session started ---------------------------------");
}

void Logger::setup(const std::string &name, const std::string &filePath)
{
    Poco::Logger::root().setChannel(new Poco::AsyncChannel(new Poco::SimpleFileChannel(filePath)));

    _logger = &Poco::Logger::get(name);
    _logger->information("--------------------------------- Session started ---------------------------------");
}
