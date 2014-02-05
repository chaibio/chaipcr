#ifndef INSTANCE_H
#define INSTANCE_H

#include <boost/utility.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/weak_ptr.hpp>
#include <boost/make_shared.hpp>
#include <boost/atomic.hpp>

template <class T>
class Instance : boost::noncopyable
{
public:
    template <typename... Args>
    static boost::shared_ptr<T> getInstance(Args... args)
    {
        auto instance = _instance.lock();
        if(instance == nullptr)
        {
            instance = boost::make_shared<T>(args...);
            _instance = instance;
        }

        return instance;
    }

    ~Instance() {}

private:
    static boost::weak_ptr<T> _instance;
 }; //great work Paul, but it is not thread safe yeah?

template <class T>
boost::weak_ptr<T> Instance<T>::_instance;

#endif // INSTANCE_H
