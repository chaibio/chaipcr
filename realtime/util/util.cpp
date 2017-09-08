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

#include "util.h"
#include "exceptions.h"

#include <fstream>
#include <sstream>
#include <system_error>

#include <cstring>

#include <boost/date_time.hpp>

#include <signal.h>
#include <poll.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/statvfs.h>

#define WATCH_PROCESS_BUFFER_SIZE 4096

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

void watchProcess(const std::string &command, WatchProcessCallback outCallback, WatchProcessCallback errorCallback, bool ignoreErrors)
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

        sigset_t signalSet;
        sigemptyset(&signalSet);
        sigprocmask(SIG_BLOCK, nullptr, &signalSet);
        sigprocmask(SIG_UNBLOCK, &signalSet, nullptr);

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
                char buffer[WATCH_PROCESS_BUFFER_SIZE];
                memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                std::size_t size = 0;

                while ((size = read(fdArray[0].fd, buffer, WATCH_PROCESS_BUFFER_SIZE)) == WATCH_PROCESS_BUFFER_SIZE)
                {
                    outCallback(buffer, size);
                    memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                    size = 0;
                }

                outCallback(buffer, size);
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
                char buffer[WATCH_PROCESS_BUFFER_SIZE];
                memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                std::size_t size = 0;

                while ((size = read(fdArray[1].fd, buffer, WATCH_PROCESS_BUFFER_SIZE)) == WATCH_PROCESS_BUFFER_SIZE)
                {
                    if (errorCallback)
                        errorCallback(buffer, size);

                    memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                    size = 0;
                }

                if (errorCallback)
                    errorCallback(buffer, size);
            }
            else if (fdArray[1].revents & POLLHUP)
            {
                processFinished = true;
                break;
            }
            else if (fdArray[1].revents & POLLNVAL || fdArray[1].revents & POLLERR)
                break;
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

        if (pid != -1)
        {
            if (status == 0)
                return;
            else if (!ignoreErrors)
                throw ProcessError(status, "Error in subprocess - " + command);
        }
        else if (!ignoreErrors)
            throw std::system_error(errno, std::generic_category(), "Error with subprocess - " + command);
    }
    else
    {
        killpg(getpgid(pid), SIGTERM);

        if (!ignoreErrors)
            throw std::runtime_error("Unknown error with subprocess - " + command);
    }
}

bool watchProcess(const std::string &command, int eventFd, WatchProcessCallback outCallback, WatchProcessCallback errorCallback, bool ignoreErrors)
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

        sigset_t signalSet;
        sigemptyset(&signalSet);
        sigprocmask(SIG_BLOCK, nullptr, &signalSet);
        sigprocmask(SIG_UNBLOCK, &signalSet, nullptr);

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
                char buffer[WATCH_PROCESS_BUFFER_SIZE];
                memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                std::size_t size = 0;

                while ((size = read(fdArray[0].fd, buffer, WATCH_PROCESS_BUFFER_SIZE)) == WATCH_PROCESS_BUFFER_SIZE)
                {
                    outCallback(buffer, size);
                    memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                    size = 0;
                }

                if (size > 0)
                    outCallback(buffer, size);
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
                char buffer[WATCH_PROCESS_BUFFER_SIZE];
                memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                std::size_t size = 0;

                while ((size = read(fdArray[1].fd, buffer, WATCH_PROCESS_BUFFER_SIZE)) == WATCH_PROCESS_BUFFER_SIZE)
                {
                    if (errorCallback)
                        errorCallback(buffer, size);

                    memset(buffer, 0, WATCH_PROCESS_BUFFER_SIZE);

                    size = 0;
                }

                if (errorCallback && size > 0)
                    errorCallback(buffer, size);
            }
            else if (fdArray[1].revents & POLLHUP)
            {
                processFinished = true;
                break;
            }
            else if (fdArray[1].revents & POLLNVAL || fdArray[1].revents & POLLERR)
                break;
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
        int status = 0;
        pid = waitpid(pid, &status, 0);

        if (pid != -1)
        {
            if (status == 0)
                return true;
            else if (!ignoreErrors)
                throw ProcessError(status, "Error in subprocess - " + command);
        }
        else if (!ignoreErrors)
            throw std::system_error(errno, std::generic_category(), "Error with subprocess - " + command);
    }
    else
    {
        killpg(getpgid(pid), SIGTERM);

        if (fdArray[2].revents == 0 && !ignoreErrors)
            throw std::runtime_error("Unknown error with subprocess - " + command);
    }

    return false;
}

bool getFileChecksum(const std::string &filePath, int eventFd, std::string &checksum)
{
    std::ifstream file(filePath.c_str());
    if (file.is_open())
    {
        file.close();

        std::stringstream stream, outStream;
        stream << "sha256sum " << filePath;

        if (Util::watchProcess(stream.str(), eventFd, [&outStream](const char *buffer, std::size_t size){ outStream.write(buffer, size); }))
        {
            outStream >> checksum;

            return true;
        }

        return false;
    }
    else
        return true;
}

unsigned long getPartitionAvailableSpace(const std::string &path)
{
    struct statvfs stat;
    std::memset(&stat, 0, sizeof(stat));

    statvfs(path.c_str(), &stat);

    return stat.f_bfree * 4;
}

}
