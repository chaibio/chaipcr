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

#ifndef INSTANCE_H
#define INSTANCE_H

#include <boost/noncopyable.hpp>

#include <memory>

template <class T>
class Instance : public boost::noncopyable
{
public:
    inline static std::shared_ptr<T> getInstance()
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
