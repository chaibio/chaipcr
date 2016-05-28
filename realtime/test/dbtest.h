/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

private:
    DBControl *_db;
};

#endif // DBTEST_H
#endif // TEST_BUILD
