#ifndef INSTANCE_H
#define INSTANCE_H

#include <boost/noncopyable.hpp>

template <class T>
class Instance : public boost::noncopyable
{
public:
    static std::shared_ptr<T> getInstance()
    {
        return _instance.lock();
    }

    template <typename ...Args>
    static std::shared_ptr<T> createInstance(Args&&... args)
    {
        std::shared_ptr<T> ptr(new T(std::forward<Args>(args)...));

        _instance = ptr;

        return ptr;
    }

protected:
    virtual ~Instance() {}

private:
    static std::weak_ptr<T> _instance;
};

template <class T>
std::weak_ptr<T> Instance<T>::_instance;


#endif // INSTANCE_H
