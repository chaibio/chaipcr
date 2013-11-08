#include "pcrincludes.h"
#include "exceptions.h"

#include <string>
#include <cstring>

using namespace std;

GPIOError::GPIOError(const char* message):
	runtime_error(message) {}

InvalidState::InvalidState(const char* message):
	runtime_error(message) {}
	
SPIError::SPIError(const char* message, int errorNumber):
	runtime_error(string(message) + ": " + strerror(errorNumber)) {}
