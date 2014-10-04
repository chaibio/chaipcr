#ifndef EXCEPTIONHANDLER_H
#define EXCEPTIONHANDLER_H

#include <cstdio>
#include <dlfcn.h>
#include <execinfo.h>

#ifndef RTLD_NEXT
#define RTLD_NEXT ((void *) -1l)
#endif

#define BACKTRACE_SIZE 16

extern "C" {

typedef void (*ThrowHandler)(void*,void*,void(*)(void*));

void __cxa_throw(void *exception, void *info, void (*destination)(void *)) {
    void *trace[BACKTRACE_SIZE];
    int size = backtrace(trace, BACKTRACE_SIZE);

    printf("Catched an exception. Backtrace:\n");
    backtrace_symbols_fd(trace, size, STDOUT_FILENO);

    static ThrowHandler handler __attribute__ ((noreturn)) = (ThrowHandler)dlsym(RTLD_NEXT, "__cxa_throw");
    handler(exception, info, destination);
}

}

#endif // EXCEPTIONHANDLER_H
