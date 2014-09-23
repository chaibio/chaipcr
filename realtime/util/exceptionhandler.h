#ifndef EXCEPTIONHANDLER_H
#define EXCEPTIONHANDLER_H

#include <iostream>
#include <cstdio>
#include <dlfcn.h>
#include <execinfo.h>

#define BACKTRACE_SIZE 16

extern "C" {

typedef void (*throwHandler)(void*,void*,void(*)(void*));

void __cxa_throw(void *exception, void *info, void (*destination)(void *)) {
    void *trace[BACKTRACE_SIZE];
    int size = backtrace(trace, BACKTRACE_SIZE);

    std::cout << "Catched an exception. Backtrace:\n";
    backtrace_symbols_fd(trace, size, STDOUT_FILENO);

    static throwHandler handler __attribute__ ((noreturn)) = nullptr;
    if (!handler)
        handler = (throwHandler)dlsym(RTLD_NEXT, "__cxa_throw");

    handler(exception, info, destination);
}

}

#endif // EXCEPTIONHANDLER_H
