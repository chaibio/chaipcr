#ifndef UTIL_H
#define UTIL_H

#include <ctime>
#include <string>
#include <functional>
#include <algorithm>

#include <boost/date_time/posix_time/ptime.hpp>

namespace Util
{

template <typename Iterator>
inline double median(Iterator begin, Iterator end)
{
    std::size_t size = std::distance(begin, end);

    std::nth_element(begin, begin + size / 2, end);

    Iterator it = begin + size / 2;

    return size % 2 != 0 ? *it : (*(it - 1) + *it) / 2;
}

boost::posix_time::ptime parseIsoTime(const std::string &str);

void watchProcess(const std::string &command, std::function<void(const char[1024])> outCallback, std::function<void(const char[1024])> errorCallback = std::function<void(const char[1024])>());
bool watchProcess(const std::string &command, int eventFd, std::function<void(const char[1024])> outCallback, std::function<void(const char[1024])> errorCallback = std::function<void(const char[1024])>());

bool getFileChecksum(const std::string &filePath, int eventFd, std::string &checksum);

}

#endif // UTIL_H
