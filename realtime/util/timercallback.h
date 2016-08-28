#ifndef TIMERCALLBACK_H
#define TIMERCALLBACK_H

#include <functional>

#include <Poco/Timer.h>

class TimerCallback : public Poco::AbstractTimerCallback
{
public:
    template <typename Callback>
    TimerCallback(Callback callback)
    {
        _callback = callback;
    }

    TimerCallback(const TimerCallback &other)
        :AbstractTimerCallback(other)
    {
        _callback = other._callback;
    }

    TimerCallback& operator= (const TimerCallback &other)
    {
        _callback = other._callback;

        return *this;
    }

    void invoke(Poco::Timer &/*timer*/) const
    {
        if (_callback)
            _callback();
    }

    AbstractTimerCallback* clone() const
    {
        return new TimerCallback(*this);
    }

private:
    std::function<void()> _callback;
};

#endif // TIMERCALLBACK_H
