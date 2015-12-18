#ifndef UTIL_H
#define UTIL_H

#include <ctime>
#include <string>
#include <functional>

#include <boost/date_time/posix_time/ptime.hpp>

namespace Util
{

boost::posix_time::ptime parseIsoTime(const std::string &str);

bool watchProcess(const std::string &command, int eventFd, std::function<void(const char[1024])> readCallback);

}

#endif // UTIL_H
