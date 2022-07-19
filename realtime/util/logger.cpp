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

#include "logger.h"

#include <Poco/SimpleFileChannel.h>
#include <Poco/ConsoleChannel.h>
#include <Poco/AsyncChannel.h>
#include <Poco/FormattingChannel.h>
#include <Poco/PatternFormatter.h>

Poco::Logger* ::Logger::_logger = nullptr;

void Logger::setup(const std::string &name)
{
    setup(new Poco::ConsoleChannel(), name);
}

void Logger::setup(const std::string &name, const std::string &filePath)
{
    setup(new Poco::SimpleFileChannel(filePath), name);
}

void Logger::setup(Poco::Channel *channel, const std::string &name)
{
    Poco::PatternFormatter *formatter = new Poco::PatternFormatter();
    formatter->setProperty("pattern", "%Y-%m-%d %H:%M:%S: %t");

    Poco::Logger::root().setChannel(new Poco::AsyncChannel(new Poco::FormattingChannel(formatter, channel)));

    _logger = &Poco::Logger::get(name);
}

LoggerStreams::~LoggerStreams()
{
    Poco::LogStream logStream(::Logger::get());

    for (std::pair<const std::string, std::stringstream> &stream: _streams)
    {
        std::string entry;

        while (stream.second.good())
        {
            std::getline(stream.second, entry);

            if (!entry.empty())
                logStream << stream.first << ": " << entry << '\n';
        }

        logStream.flush();
    }
}
