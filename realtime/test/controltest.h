#ifdef TEST_BUILD

#ifndef CONTROLTEST_H
#define CONTROLTEST_H

#include "apptest.h"

class TemperatureController;

class ControlTest : public AppTest
{
public:
    ControlTest();

    void testMinMaxTargetTemp();
};

#endif // CONTROLTEST_H
#endif // TEST_BUILD
