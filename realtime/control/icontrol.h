#ifndef ICONTROL_H
#define ICONTROL_H

#include <thread>
#include <functional>

class IControl
{
public:
    virtual ~IControl() {}

    virtual void process() = 0;
};

//Don't destroy IThreadControl within its thread
class IThreadControl : protected IControl, public std::thread
{
public:
    inline void start()
    {
        this->thread::operator =(std::move(std::thread(std::bind(&IThreadControl::process, this))));
    }

    virtual void stop() = 0;

protected:
    void process() = 0;
};

#endif // ICONTROL_H
