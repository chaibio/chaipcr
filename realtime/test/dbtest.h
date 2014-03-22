#ifdef TEST_BUILD

#ifndef DBTEST_H
#define DBTEST_H

#include <gtest/gtest.h>

class DBControl;
class Experiment;

class DBTest : public testing::Test
{
public:
    DBTest();
    ~DBTest();

    void testExperiment();

private:
    void printExperiment(Experiment *experiment);

    DBControl *_db;
};

#endif // DBTEST_H
#endif // TEST_BUILD
