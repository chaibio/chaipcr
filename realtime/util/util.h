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

#ifndef UTIL_H
#define UTIL_H

#include <ctime>
#include <string>
#include <functional>
#include <algorithm>
#include <numeric>

#include <boost/date_time/posix_time/ptime.hpp>

namespace Util
{

typedef std::function<void(const char*, std::size_t)> WatchProcessCallback;

template <typename Iterator>
inline double median(Iterator begin, Iterator end)
{
    std::size_t size = std::distance(begin, end);

    std::nth_element(begin, begin + size / 2, end);

    Iterator it = begin + size / 2;

    return size % 2 != 0 ? *it : (*(it - 1) + *it) / 2;
}

template <typename Iterator>
inline double average(Iterator begin, Iterator end)
{ return std::accumulate(begin, end, 0) / static_cast<double>(std::distance(begin, end)); }

template <class Container>
inline double average(const Container &container) { return average(std::begin(container), std::end(container)); }

boost::posix_time::ptime parseIsoTime(const std::string &str);

void watchProcess(const std::string &command, WatchProcessCallback outCallback, WatchProcessCallback errorCallback = WatchProcessCallback(), bool ignoreErrors = false);
bool watchProcess(const std::string &command, int eventFd, WatchProcessCallback outCallback, WatchProcessCallback errorCallback = WatchProcessCallback(), bool ignoreErrors = false);

bool getFileChecksum(const std::string &filePath, int eventFd, std::string &checksum);

bool getPartitionAvailableSpace(const std::string &path, unsigned long &space);

int isVersionGreater(const std::string &currentVersion, const std::string &newVersion);

struct NullMutex
{
     void lock() {}
     void unlock() {}
     bool try_lock() { return true; }
};

}

#endif // UTIL_H
