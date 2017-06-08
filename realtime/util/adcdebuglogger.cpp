#include "adcdebuglogger.h"
#include "maincontrollers.h"
#include "qpcrapplication.h"

BaseADCDebugLogger::BaseADCDebugLogger(const std::string &storeFile)
{
    _storeFile = storeFile;
    _preSamplesCount = 0;
    _postSamplesCount = 0;
    _workState = NotWorkingState;
    _triggerState = false;
}

bool BaseADCDebugLogger::start(std::size_t preSamplesCount, std::size_t postSamplesCount)
{
    if (preSamplesCount == 0 || postSamplesCount == 0)
         std::logic_error("Pre/post samples cound must not be 0");

     std::lock_guard<std::mutex> lock(_mutex);

     _triggerState = false;
     _preSamplesCount = preSamplesCount;
     _postSamplesCount = postSamplesCount;

     if (_workState == SavingState)
         return false;

     starting();

     _workState = WorkingState;

     return true;
}

void BaseADCDebugLogger::stop()
{
    std::lock_guard<std::mutex> lock(_mutex);

    _triggerState = false;
    _preSamplesCount = 0;
    _postSamplesCount = 0;

    if (_workState == SavingState)
        return;

    _workState = NotWorkingState;

    stopping();
}
