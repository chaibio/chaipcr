#ifndef _EXCEPTIONS_H_
#define _EXCEPTIONS_H_

#include <exception>
#include <stdexcept>

class GPIOError: public std::runtime_error {
public:
	GPIOError(const char* message);
};

class InvalidState: public std::runtime_error {
public:
	InvalidState(const char* message);
};

class InvalidArgument: public std::runtime_error {
public:
	InvalidArgument(const char* message);
};

class SPIError: public std::runtime_error {
public:
	SPIError(const char* message, int errorNumber);
};

class TemperatureLimitError : public std::runtime_error {
public:
    TemperatureLimitError(const std::string &message);
};

#endif
