#include "pcrincludes.h"
#include "boostincludes.h"
#include "utilincludes.h"
#include "controlincludes.h"

int ADCConsumer::channel() const {
    if (!ADCControllerInstance::getInstance())
        return -1;

    return ADCControllerInstance::getInstance()->consumerChannel(this);
}
