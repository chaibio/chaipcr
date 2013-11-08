#include "pcrincludes.h"
#include "exceptions.h"

GPIOError::GPIOError(const char* message):
	std::runtime_error(message) {}

InvalidState::InvalidState(const char* message):
	std::runtime_error(message) {}
