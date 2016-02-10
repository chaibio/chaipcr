#ifndef LOGGER_H
#define LOGGER_H

#include <string>

#include <Poco/Logger.h>
#include <Poco/LogStream.h>

class Logger
{
public:
    static void setup(const std::string &name);
    static void setup(const std::string &name, const std::string &filePath);

    static Poco::Logger& get() { return *_logger; }
    static bool isSetup() { return _logger; }

private:
    static Poco::Logger *_logger;
};

#define APP_LOGGER Poco::LogStream(Logger::get())

#endif // LOGGER_H
