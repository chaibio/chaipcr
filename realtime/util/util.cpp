#include "util.h"

#include <fstream>
#include <sstream>
#include <system_error>

#include <cstring>

#include <boost/date_time.hpp>

#include <poll.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>

namespace Util
{

boost::posix_time::ptime parseIsoTime(const std::string &str)
{
    std::stringstream stream;
    stream << str;

    int year = 0, month = 0, day = 0, hours = 0, minutes = 0, seconds = 0;

    stream >> year;
    stream.ignore();
    stream >> month;
    stream.ignore();
    stream >> day;
    stream.ignore();
    stream >> hours;
    stream.ignore();
    stream >> minutes;
    stream.ignore();
    stream >> seconds;

    return boost::posix_time::ptime(boost::gregorian::date(year, month, day), boost::posix_time::time_duration(hours, minutes, seconds));
}

void watchProcess(const std::string &command, std::function<void(const char[1024])> outCallback, std::function<void(const char[1024])> errorCallback)
{
    int outPipes[2] = {-1};
    int errorPipes[2] = {-1};

    if (pipe2(outPipes, O_CLOEXEC) == -1)
        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to create out pipes:");

    if (pipe2(errorPipes, O_CLOEXEC) == -1)
    {
        close(outPipes[0]);
        close(outPipes[1]);

        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to create error pipes:");
    }

    pid_t pid = vfork();

    if (pid == -1)
    {
        close(outPipes[0]);
        close(outPipes[1]);

        close(errorPipes[0]);
        close(errorPipes[1]);

        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to fork:");
    }

    if (pid == 0) //Child process
    {
        setpgrp();

        if (outPipes[1] != fileno(stdout))
        {
            dup2(outPipes[1], fileno(stdout));
            close(outPipes[1]);
        }

        if (errorPipes[1] != fileno(stderr))
        {
            dup2(errorPipes[1], fileno(stderr));
            close(errorPipes[1]);
        }

        close(outPipes[0]);
        close(errorPipes[0]);

        setpriority(PRIO_PROCESS, getpid(), 20);

        execl("/bin/sh", "sh", "-c", command.c_str(), NULL);
        _exit(127);

        //It will never reach this line
    }

    close(outPipes[1]);
    close(errorPipes[1]);

    bool processFinished = false;

    pollfd fdArray[2];
    fdArray[0].fd = outPipes[0];
    fdArray[0].events = POLLIN | POLLPRI;
    fdArray[0].revents = 0;

    fdArray[1].fd = errorPipes[0];
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
                    outCallback(buffer);
                    memset(buffer, 0, 1024);
                }

                outCallback(buffer);
            }
            else if (fdArray[0].revents & POLLHUP)
            {
                processFinished = true;
                break;
            }
            else if (fdArray[0].revents & POLLNVAL || fdArray[0].revents & POLLERR)
                break;
        }

        if (fdArray[1].revents > 0)
        {
            if (fdArray[1].revents & POLLIN || fdArray[1].revents & POLLPRI)
            {
                char buffer[1024];
                memset(buffer, 0, 1024);

                while (read(fdArray[1].fd, buffer, 1023) == 1023)
                {
                    if (errorCallback)
                        errorCallback(buffer);

                    memset(buffer, 0, 1024);
                }

                if (errorCallback)
                    errorCallback(buffer);
            }
        }

        fdArray[0].revents = 0;
        fdArray[1].revents = 0;
    }

    close(outPipes[0]);
    close(errorPipes[0]);

    if (processFinished)
    {
        int status = -1;
        pid = waitpid(pid, &status, 0);

        if (pid != -1 && status == 0)
            return;
        else
            throw std::runtime_error("Unknown error with subprocess - " + command);
    }
    else
    {
        killpg(getpgid(pid), SIGTERM);

        throw std::runtime_error("Unknown error with subprocess - " + command);
    }
}

bool watchProcess(const std::string &command, int eventFd, std::function<void(const char[1024])> outCallback, std::function<void(const char[1024])> errorCallback)
{
    int outPipes[2] = {-1};
    int errorPipes[2] = {-1};

    if (pipe2(outPipes, O_CLOEXEC) == -1)
        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to create out pipes:");

    if (pipe2(errorPipes, O_CLOEXEC) == -1)
    {
        close(outPipes[0]);
        close(outPipes[1]);

        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to create error pipes:");
    }

    pid_t pid = vfork();

    if (pid == -1)
    {
        close(outPipes[0]);
        close(outPipes[1]);

        close(errorPipes[0]);
        close(errorPipes[1]);

        throw std::system_error(errno, std::generic_category(), "Util::watchProcess - unable to fork:");
    }

    if (pid == 0) //Child process
    {
        setpgrp();

        if (outPipes[1] != fileno(stdout))
        {
            dup2(outPipes[1], fileno(stdout));
            close(outPipes[1]);
        }

        if (errorPipes[1] != fileno(stderr))
        {
            dup2(errorPipes[1], fileno(stderr));
            close(errorPipes[1]);
        }

        close(outPipes[0]);
        close(errorPipes[0]);

        setpriority(PRIO_PROCESS, getpid(), 20);

        execl("/bin/sh", "sh", "-c", command.c_str(), NULL);
        _exit(127);

        //It will never reach this line
    }

    close(outPipes[1]);
    close(errorPipes[1]);

    bool processFinished = false;

    pollfd fdArray[3];
    fdArray[0].fd = outPipes[0];
    fdArray[0].events = POLLIN | POLLPRI;
    fdArray[0].revents = 0;

    fdArray[1].fd = errorPipes[0];
    fdArray[1].events = POLLIN | POLLPRI;
    fdArray[1].revents = 0;

    fdArray[2].fd = eventFd;
    fdArray[2].events = POLLIN | POLLPRI;
    fdArray[2].revents = 0;

    while (poll(fdArray, 3, -1) > 0)
    {
        if (fdArray[0].revents > 0)
        {
            if (fdArray[0].revents & POLLIN || fdArray[0].revents & POLLPRI)
            {
                char buffer[1024];
                memset(buffer, 0, 1024);

                while (read(fdArray[0].fd, buffer, 1023) == 1023)
                {
                    outCallback(buffer);
                    memset(buffer, 0, 1024);
                }

                outCallback(buffer);
            }
            else if (fdArray[0].revents & POLLHUP)
            {
                processFinished = true;
                break;
            }
            else if (fdArray[0].revents & POLLNVAL || fdArray[0].revents & POLLERR)
                break;
        }

        if (fdArray[1].revents > 0)
        {
            if (fdArray[1].revents & POLLIN || fdArray[1].revents & POLLPRI)
            {
                char buffer[1024];
                memset(buffer, 0, 1024);

                while (read(fdArray[1].fd, buffer, 1023) == 1023)
                {
                    if (errorCallback)
                        errorCallback(buffer);

                    memset(buffer, 0, 1024);
                }

                if (errorCallback)
                    errorCallback(buffer);
            }
        }

        if (fdArray[2].revents > 0)
        {
            uint64_t i = 0;
            read(eventFd, &i, sizeof(i));

            break;
        }

        fdArray[0].revents = 0;
        fdArray[1].revents = 0;
        fdArray[2].revents = 0;
    }

    close(outPipes[0]);
    close(errorPipes[0]);

    if (processFinished)
    {
        int status = -1;
        pid = waitpid(pid, &status, 0);

        if (pid != -1 && status == 0)
            return true;
        else
            throw std::runtime_error("Unknown error with subprocess - " + command);
    }
    else
    {
        killpg(getpgid(pid), SIGTERM);

        if (fdArray[1].revents == 0)
            throw std::runtime_error("Unknown error with subprocess - " + command);
        else
            return false;
    }
}

bool getFileChecksum(const std::string &filePath, int eventFd, std::string &checksum)
{
    std::ifstream file(filePath.c_str());
    if (file.is_open())
    {
        file.close();

        std::stringstream stream;
        stream << "sha256sum " << filePath;

        return Util::watchProcess(stream.str(), eventFd, [&checksum](const char buffer[]){ std::stringstream stream; stream << buffer; checksum.clear(); stream >> checksum; });
    }
    else
        return true;
}

}
