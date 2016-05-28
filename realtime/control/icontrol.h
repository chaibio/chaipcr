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

#ifndef ICONTROL_H
#define ICONTROL_H

#include <thread>
#include <functional>
#include <thread>
#include <string>

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

    void setMaxRealtimePriority()
    {
        sched_param params;
        params.__sched_priority = sched_get_priority_max(SCHED_FIFO);

        pthread_setschedparam(native_handle(), SCHED_FIFO, &params);
    }

    void setThreadName(const std::string &name)
    {
        pthread_setname_np(native_handle(), name.c_str());
    }

protected:
    void process() = 0;
};

#endif // ICONTROL_H
