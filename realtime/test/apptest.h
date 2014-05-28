#ifdef TEST_BUILD

#ifndef APPTEST_H
#define APPTEST_H

#include <gtest/gtest.h>
#include "qpcrapplication.h"

class AppTest : public testing::Test
{
public:
    AppTest();
    virtual ~AppTest();

protected:
    QPCRApplication _app;
    std::thread _appThread;
};

#endif // APPTEST_H
#endif // TEST_BUILD
