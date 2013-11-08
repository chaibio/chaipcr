#ifndef _EXCEPTIONS_H_
#define _EXCEPTIONS_H_

#include <stdexcept>

class GPIOError: public std::runtime_error {
public:
	GPIOError(const char* message);
};

class InvalidState: public std::runtime_error {
public:
	InvalidState(const char* message);
};

#endif
