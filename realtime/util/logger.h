/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef LOGGER_H
#define LOGGER_H

#include <string>
#include <sstream>
#include <map>

#include <Poco/Logger.h>
#include <Poco/LogStream.h>

namespace Poco { class Channel; }

class Logger
{
public:
    static void setup(const std::string &name);
    static void setup(const std::string &name, const std::string &filePath);

    static Poco::Logger& get() { return *_logger; }
    static bool isSetup() { return _logger; }

private:
    static void setup(Poco::Channel *channel, const std::string &name);

private:
    static Poco::Logger *_logger;
};

class LoggerStreams
{
public:
    ~LoggerStreams();

    inline std::stringstream& stream(const std::string &key) { return _streams[key]; }

private:
    std::map<std::string, std::stringstream> _streams;
};

#define APP_LOGGER Poco::LogStream(::Logger::get())

#endif // LOGGER_H
