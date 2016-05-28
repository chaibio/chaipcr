//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifdef TEST_BUILD

#include "dbincludes.h"
#include "dbtest.h"

inline std::string ptime_to_string(const boost::posix_time::ptime &date_time)
{
    if (date_time.is_not_a_date_time())
        return std::string();

    std::stringstream stream;
    stream << date_time.date().year() << "-" << date_time.date().month() << "-" << date_time.date().day() << " "
           << date_time.time_of_day().hours() << ":" << date_time.time_of_day().minutes() << ":" << date_time.time_of_day().seconds();

    return stream.str();
}

DBTest::DBTest()
{
    srand(time(NULL));

    _db = new DBControl;
}

DBTest::~DBTest()
{
    delete _db;
}

void DBTest::testExperiment()
{
    std::vector<int> idList = _db->getEperimentIdList();

    if (!idList.empty())
    {
        try
        {
            Experiment *experiment = nullptr;
            for (size_t i = 0, id; i < (idList.size() > 10 ? 10 : idList.size()); ++i)
            {
                id = idList.at(rand() % idList.size());

                std::cout << "Trying to get experiment by id " << id << '\n';
                experiment = _db->getExperiment(id);

                ASSERT_TRUE(experiment);
                printExperiment(experiment);

                delete experiment;
                experiment = nullptr;
            }
        }
        catch (std::exception &ex)
        {
            FAIL() << ex.what() << '\n';
        }
    }
    else
        std::cout << "Experiments table is empty\n";
}

void DBTest::printExperiment(Experiment *experiment)
{
    std::cout << "Experiment:\n";
    std::cout << "name - " << experiment->name() << '\n';
    std::cout << "qpcr - " << experiment->qpcr() << '\n';
    std::cout << "started_at - " << ptime_to_string(experiment->startedAt()) << '\n';
    std::cout << "completed_at - " << ptime_to_string(experiment->completedAt()) << '\n';
    std::cout << "completion_status - " << experiment->completionStatus() << "\n\n";

    std::cout << "Protocol:\n";
    if (experiment->protocol())
    {
        std::cout << "lid_temperature - " << experiment->protocol()->lidTemperature() << "\n\n";

        std::cout << "Stages:\n";
        if (!experiment->protocol()->stages().empty())
        {
            for (const Stage &stage: experiment->protocol()->stages())
            {
                std::cout << "Stage - " << stage.orderNumber() << '\n';
                std::cout << "name - " << stage.name() << '\n';
                std::cout << "num_cycles - " << stage.numCycles() << '\n';
                std::cout << "stage_type - " << stage.type() << "\n\n";

                std::cout << "Stage components:\n\n";
                if (!stage.components().empty())
                {
                    for (const StageComponent &component: stage.components())
                    {
                        std::cout << "Step:\n";
                        if (component.step())
                        {
                            std::cout << "order_number - " << component.step()->orderNumber() << '\n';
                            std::cout << "name - " << component.step()->name() << '\n';
                            std::cout << "temperature - " << component.step()->temperature() << '\n';
                            std::cout << "hold_time - " << component.step()->holdTime() << "\n\n";
                        }
                        else
                            std::cout << "None\n\n";

                        std::cout << "Ramp:\n";
                        if (component.ramp())
                        {
                            std::cout << "rate - " << component.ramp()->rate() << "\n\n";
                        }
                        else
                            std::cout << "None\n\n";
                    }
                }
                else
                    std::cout << "None\n\n";
            }
        }
        else
            std::cout << "None\n\n";
    }
    else
        std::cout << "None\n\n";
}

TEST_F(DBTest, experiments)
{
    testExperiment();
}

#endif // TEST_BUILD
