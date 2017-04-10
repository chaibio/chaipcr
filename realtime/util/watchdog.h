#ifndef WATCHDOG_H
#define WATCHDOG_H

#include <string>
#include <atomic>
#include <boost/chrono.hpp>

namespace Watchdog
{

class Watchable
{
public:
    Watchable(const std::string &name, const boost::chrono::seconds &watchInterval = boost::chrono::seconds(1));
    virtual ~Watchable();

    inline const std::string& name() const noexcept { return _name; }
    inline const boost::chrono::seconds& watchInterval() const noexcept { return _watchInterval; }

    inline void checkin() noexcept { _watchState = true; }
    inline bool checkout() noexcept { return _watchState.exchange(false); }

private:
    std::string _name;
    boost::chrono::seconds _watchInterval;
    std::atomic<bool> _watchState;
};

void start();

}

#endif // WATCHDOG_H
