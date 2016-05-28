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

#ifndef STEP_H
#define STEP_H

#include <string>
#include <ctime>

class Step
{
public:
    Step(int id);
    Step(const Step &other);
    Step(Step &&other);
    ~Step();

    Step& operator= (const Step &other);
    Step& operator= (Step &&other);

    inline int id() const { return _id; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    inline void setTemperature(double temperature) {_temperature = temperature;}
    inline double temperature() const {return _temperature;}

    inline void setHoldTime(time_t holdTime) {_holdTime = holdTime;}
    inline time_t holdTime() const {return _holdTime;}

    inline void setOrderNumber(int orderNumber) {_orderNumber = orderNumber;}
    inline int orderNumber() const {return _orderNumber;}

    inline void setCollectData(bool collectData) {_collectData = collectData;}
    inline int collectData() const {return _collectData;}

    inline void setDeltaTemperature(double temperature) {_deltaTemperature = temperature;}
    inline double deltaTemperature() const {return _deltaTemperature;}

    inline void setDeltaDuration(time_t duration) {_deltaDuration = duration;}
    inline time_t deltaDuration() const {return _deltaDuration;}

    inline void setPauseState(bool state) {_pauseState = state;}
    inline bool pauseState() const {return _pauseState;}

    inline void setExcitationIntensity(double intensity) {_excitationIntensity = intensity;}
    inline double excitationIntensity() const {return _excitationIntensity;}

private:
    int _id;

    std::string _name;

    double _temperature;
    time_t _holdTime;
    int _orderNumber;

    bool _collectData;

    double _deltaTemperature;
    time_t _deltaDuration;

    bool _pauseState;

    double _excitationIntensity;
};

#endif // STEP_H
