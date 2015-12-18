#include "util.h"

#include <sstream>
#include <system_error>

#include <cstring>

#include <boost/date_time.hpp>

#include <poll.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/wait.h>

namespace Util
{

boost::posix_time::ptime parseIsoTime(const std::string &str)
{
    std::stringstream stream;
    stream << str;

    int year = 0, month = 0, day = 0, hours = 0, minutes = 0, seconds = 0;

    stream >> year;
    stream.ignore();
    stream >> day;
    stream.ignore();
    stream >> month;
    stream.ignore();
    stream >> hours;
    stream.ignore();
    stream >> minutes;
    stream.ignore();
    stream >> seconds;

    return boost::posix_time::ptime(boost::gregorian::date(year, month, day), boost::posix_time::time_duration(hours, minutes, seconds));
}

bool watchProcess(const std::string &command, int eventFd, std::function<void(const char[1024])> readCallback)
{
    int processPipes[2] = {-1};

    if (pipe2(processPipes, O_CLOEXEC) == -1)
        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to create pipes:");

    pid_t pid = vfork();

    if (pid == -1)
    {
        close(processPipes[0]);
        close(processPipes[1]);

        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to fork:");
    }

    if (pid == 0) //Child process
    {
        if (processPipes[1] != fileno(stdout))
        {
            dup2(processPipes[1], fileno(stdout));
            close(processPipes[1]);
        }

        close(processPipes[0]);

        execl("/bin/sh", "sh", "-c", command.c_str(), NULL);
        _exit(127);

        //It will never reach this line
    }

    close(processPipes[1]);

    bool processFinished = false;

    pollfd fdArray[2];
    fdArray[0].fd = processPipes[0];
    fdArray[0].events = POLLIN | POLLPRI;
    fdArray[0].revents = 0;

    fdArray[1].fd = eventFd;
    fdArray[1].events = POLLIN | POLLPRI;
    fdArray[1].revents = 0;

    while (poll(fdArray, 2, -1) > 0)
    {
        if (fdArray[0].revents > 0)
        {
            if (fdArray[0].revents & POLLIN || fdArray[0].revents & POLLPRI)
            {
                char buffer[1024];
                memset(buffer, 0, 1024);

                while (read(fdArray[0].fd, buffer, 1023) == 1023)
                {
                    readCallback(buffer);
                    memset(buffer, 0, 1024);
                }

                readCallback(buffer);
            }
            else if (fdArray[0].revents & POLLHUP)
            {
                processFinished = true;
                break;
            }
            else if (fdArray[0].revents & POLLNVAL || fdArray[0].revents & POLLERR)
                break;
        }
        else
        {
            uint64_t i = 0;
            read(eventFd, &i, sizeof(i));

            break;
        }

        fdArray[0].revents = 0;
        fdArray[1].revents = 0;
    }

    close(processPipes[0]);

    if (processFinished)
    {
        int status = -1;
        pid = waitpid(pid, &status, 0);

        if (pid != -1 && status == 0)
            return true;
        else
            throw std::runtime_error("Util::watchProcess - unknown error occured upon watching a process.");
    }
    else
    {
        kill(pid, SIGTERM);

        if (fdArray[1].revents == 0)
            throw std::runtime_error("Util::watchProcess - unknown error occured upon watching a process.");
        else
            return false;
    }
}

}
