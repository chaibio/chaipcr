#include "pcrincludes.h"

#include <cstring>

using namespace std;

GPIOError::GPIOError(const char* message):
	runtime_error(message) {}

InvalidState::InvalidState(const char* message):
	runtime_error(message) {}
	
InvalidArgument::InvalidArgument(const char* message):
	runtime_error(message) {}
	
SPIError::SPIError(const char* message, int errorNumber):
	runtime_error(string(message) + ": " + strerror(errorNumber)) {}

TemperatureLimitError::TemperatureLimitError(const string &message):
    runtime_error(message) {}
