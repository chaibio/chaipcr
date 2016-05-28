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

#ifndef ADCCONSUMER_H
#define ADCCONSUMER_H

#include <boost/noncopyable.hpp>

class ADCConsumer : public boost::noncopyable {
public:
    virtual void setADCValue(unsigned int /*adcValue*/) {}
    virtual void setADCValue(unsigned int /*adcValue*/, std::size_t /*channel*/) {}
    virtual void setADCValues(unsigned int /*differentialADCValue*/, unsigned int /*singularADCValue*/) {}
    virtual void setADCValues(unsigned int /*differentialADCValue*/, unsigned int /*singularADCValue*/, std::size_t /*channel*/) {}

    virtual void setADCValueMock(double /*adcValue*/) {}
};

#endif // ADCCONSUMER_H
