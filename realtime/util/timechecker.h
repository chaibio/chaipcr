#ifndef TIMECHECKER_H
#define TIMECHECKER_H

#include <boost/chrono.hpp>
#include <boost/signals2.hpp>

namespace Poco { class Timer; }

class TimeChecker
{
public:
    TimeChecker();
    ~TimeChecker();

    boost::signals2::signal<void(bool)> timeStateChanged;

private:
    void timeCheckCallback(Poco::Timer &timer);

    void saveCurrentTime();
    boost::chrono::seconds getSavedTime() const;

    void setCurrentTime(const boost::chrono::seconds &timestamp);

private:
    Poco::Timer *_timer;

    bool _firstTryState;
    bool _timeState;
};

#endif // TIMECHECKER_H
