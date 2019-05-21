#include "watchdog.h"
#include "qpcrapplication.h"
#include "logger.h"

#include <thread>
#include <mutex>
#include <vector>
#include <algorithm>
#include <csignal>
#include <map>

#include <unistd.h>

std::mutex watchableListMutex;
bool watchableListState;
std::vector<Watchdog::Watchable*> watchableList;

void watch();

namespace Watchdog
{

Watchable::Watchable(const std::string &name, const boost::chrono::seconds &watchInterval)
{
    _name = name;
    _watchInterval = watchInterval;
    _watchState = true;


    std::lock_guard<std::mutex> lock(watchableListMutex);
    watchableListState = true;
    watchableList.emplace_back(this);
}

Watchable::~Watchable()
{
    std::lock_guard<std::mutex> lock(watchableListMutex);
    watchableListState = true;
    watchableList.erase(std::find(watchableList.begin(), watchableList.end(), this));
}

void start()
{
    std::thread(watch).detach();
}

}

void watch()
{
    std::map<Watchdog::Watchable*, boost::chrono::steady_clock::time_point> watchTimes;

    timespec time;
    time.tv_sec = 1;
    time.tv_nsec = 0;

    while (qpcrApp.isWorking())
    {
        {
            std::lock_guard<std::mutex> lock(watchableListMutex);

            if (watchableListState)
            {
                std::map<Watchdog::Watchable*, boost::chrono::steady_clock::time_point> tmp = std::move(watchTimes);

                for (Watchdog::Watchable *watchable: watchableList)
                {
                    auto it = tmp.find(watchable);

                    watchTimes.emplace(watchable, it != tmp.end() ? it->second : boost::chrono::steady_clock::now());
                }

                watchableListState = false;
            }
        }

        for (auto &watchable: watchTimes)
        {
            if (watchable.first->checkout())
                watchable.second = boost::chrono::steady_clock::now();
            else if ((boost::chrono::steady_clock::now() - watchable.second) > watchable.first->watchInterval())
            {
                APP_LOGGER << watchable.first->name() << " thread has blocked for over " << watchable.first->watchInterval().count() << " seconds. Killing the app" << std::endl;

                time.tv_sec = 0;
                time.tv_nsec = 100 * 1000 * 1000;

                nanosleep(&time, nullptr); //Letting the logger to write the line above
                kill(0, SIGKILL);

                //It will never reach this point
            }
        }

        nanosleep(&time, nullptr);
    }
}
