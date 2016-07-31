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

////////////////////////////////////////////////////////////////////////////////
// Class GPIO
class GPIO {
public:
	enum Direction {
		kInput = 0,
		kOutput = 1
	};

	enum Value {
		kLow = 0,
		kHigh = 1
	};
	
    GPIO(unsigned int pinNumber, Direction direction, bool waitinigAvailable = false);
    GPIO(const GPIO &other) = delete;
    GPIO(GPIO &&other);
	~GPIO();

    GPIO& operator= (const GPIO &other) = delete;
    GPIO& operator= (GPIO &&other);
	
    Value value() const;
    void setValue(Value value, bool forceUpdate = true);

    Value waitValue(Value value);
    void stopWaitinigValue();
	
	Direction direction() const { return direction_; }
    void setDirection(Direction direction);

    void setupWaiting();
	
private:
    void exportPin();
    void unexportPin();

    void changeEdge();
	
private:
	unsigned int pinNumber_; //BeagleBone GPIO Pin Number
	Direction direction_;

    int waitingFd_;
    int stopWaitinigFd_;

    mutable Value savedValue_;
};

#endif
