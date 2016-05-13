#ifndef EXCEPTIONHANDLER_H
#define EXCEPTIONHANDLER_H

#include "logger.h"

#include <string>
#include <typeinfo>
#include <cstdio>
#include <dlfcn.h>
#include <execinfo.h>

#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *) -1l)
#endif

#define BACKTRACE_SIZE 32

extern "C" {

typedef void (*ThrowHandler)(void*,void*,void(*)(void*));

bool ignore_exception(void *exception, void *info)
{
    if (reinterpret_cast<std::type_info*>(info)->before(typeid(std::exception)))
    {
        std::string message = reinterpret_cast<std::exception*>(exception)->what();

        return message == "Net Exception" || message == "No message received" || //Poco internal exceptions
                (message.find("iwlist") != std::string::npos && message.find("list") != std::string::npos); //Wifi scan attempts on non wifi interfaces. They might be too many to have them in the log file
    }

    return false;
}

void __cxa_throw(void *exception, void *info, void (*destination)(void *))
{
    if (!ignore_exception(exception, info))
    {
        void *trace[BACKTRACE_SIZE];
        int size = backtrace(trace, BACKTRACE_SIZE);
        char **buffer = backtrace_symbols(trace, size);

        Poco::LogStream logStream(Logger::get());

        if (reinterpret_cast<std::type_info*>(info)->before(typeid(std::exception)))
            logStream << "Catched an exception (" << reinterpret_cast<std::exception*>(exception)->what() << "). Backtrace:" << std::endl;
        else
            logStream << "Catched an unknown exception. Backtrace:" << std::endl;

        for (int i = 0; i < size; ++i)
            logStream << buffer[i] << std::endl;

        free(buffer);
    }

    /*void *trace[BACKTRACE_SIZE];
    int size = backtrace(trace, BACKTRACE_SIZE);
    char **buffer = backtrace_symbols(trace, size);

    if (!strstr(buffer[1], "libPocoNet.so")) //To ignore annoying internal Poco exceptions
    {
        Poco::LogStream logStream(Logger::get());

        logStream << "Catched an exception (" << reinterpret_cast<std::exception*>(exception)->what() << "). Backtrace:" << std::endl;

        for (int i = 0; i < size; ++i)
            logStream << buffer[i] << std::endl;
    }

    free(buffer);*/

    static ThrowHandler handler __attribute__ ((noreturn)) = (ThrowHandler)dlsym(RTLD_NEXT, "__cxa_throw");
    handler(exception, info, destination);
}

}

#endif // EXCEPTIONHANDLER_H
