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

#ifndef ADCPIN_H
#define ADCPIN_H

#include <string>

class ADCPin
{
public:
    ADCPin(const std::string &path, unsigned int channel = 0);
    ADCPin(const ADCPin &other);

    ADCPin& operator= (const ADCPin &other);

    inline const std::string& path() const { return _path; }

    inline unsigned int channel() const { return _channel; }
    inline void setChannel(unsigned int channel) { _channel = channel; }

    uint32_t readValue() const;

private:
    void changeMode();

private:
    std::string _path;
    unsigned int _channel;
};

#endif // ADCPIN_H
