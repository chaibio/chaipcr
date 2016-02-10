#ifndef EXCEPTIONHANDLER_H
#define EXCEPTIONHANDLER_H

#include "logger.h"

#include <cstdio>
#include <cstring>
#include <dlfcn.h>
#include <execinfo.h>

#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *) -1l)
#endif

#define BACKTRACE_SIZE 32

extern "C" {

typedef void (*ThrowHandler)(void*,void*,void(*)(void*));

void __cxa_throw(void *exception, void *info, void (*destination)(void *)) {
    void *trace[BACKTRACE_SIZE];
    int size = backtrace(trace, BACKTRACE_SIZE);
    char **buffer = backtrace_symbols(trace, size);

    if (!strstr(buffer[1], "libPocoNet.so")) //To ignore annoying internal Poco exceptions
    {
        Poco::LogStream logStream(Logger::get());

        logStream << "Catched an exception (" << reinterpret_cast<std::exception*>(exception)->what() << "). Backtrace:" << std::endl;

        for (int i = 0; i < size; ++i)
            logStream << buffer[i] << std::endl;
    }

    free(buffer);

    static ThrowHandler handler __attribute__ ((noreturn)) = (ThrowHandler)dlsym(RTLD_NEXT, "__cxa_throw");
    handler(exception, info, destination);
}

}

#endif // EXCEPTIONHANDLER_H
