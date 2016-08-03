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

#ifndef _GPIO_H_
#define _GPIO_H_

#include <fstream>
#include <mutex>
#include <atomic>

class GPIO
{
public:
    enum Direction {
        kInput = 0,
        kOutput = 1
    };

    enum Value {
        kLow = 0,
        kHigh = 1
    };

    enum Type
    {
        kDirect,
        kPoll
    };

    GPIO(unsigned int pinNumber, Direction direction, Type type = kDirect);
    GPIO(const GPIO &other) = delete;
    GPIO(GPIO &&other);
    ~GPIO();

    GPIO& operator =(const GPIO &other) = delete;
    GPIO& operator =(GPIO &&other);

    inline unsigned int pinNumber() const { return _pinNumber; }
    inline Direction direction() const { return _direction; }
    inline Type type() const { return _type; }

    Value value() const;
    void setValue(Value value, bool forceUpdate = true);

    bool pollValue(Value expectedValue, Value &value); //Checks if GPIO has expectedValue before polling
    void cancelPolling();

private:
    void exportPin();
    void changeEdge();
    void setDirection(Direction direction);
    void setupStream();
    void setupPoll();

    void unexportPin();

private:
    unsigned int _pinNumber; //BeagleBone GPIO Pin Number
    Direction _direction;
    Type _type;

    mutable std::fstream _pinStream;
    mutable std::mutex _pinStreamMutex;

    int _pollFd;
    int _cancelPollFd;

    std::atomic<Value> _savedValue;
};

#endif
