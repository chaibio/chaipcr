#ifndef LOCKFREESIGNAL_H
#define LOCKFREESIGNAL_H

#include <boost/signals2.hpp>

namespace boost
{

namespace signals2
{

template <typename Func>
using lockfree_signal = typename signal_type<Func, keywords::mutex_type<dummy_mutex>>::type;

}

}

#endif // LOCKFREESIGNAL_H

