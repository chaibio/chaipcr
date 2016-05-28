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

#ifndef TEMPERATURECONTROLLER_H
#define TEMPERATURECONTROLLER_H

#include "icontrol.h"

#include <memory>
#include <atomic>
#include <mutex>

class Thermistor;
class PIDController;

class TemperatureController : public IControl
{
public:
    struct Settings
    {
        Settings(): minTargetTemp(0), maxTargetTemp(0), minTempThreshold(0), maxTempThreshold(0), pidController(nullptr) {}

        std::shared_ptr<Thermistor> thermistor;

        std::string name;

        double minTargetTemp;
        double maxTargetTemp;
        double minTempThreshold;
        double maxTempThreshold;

        PIDController *pidController;
    };

    enum Direction
    {
        EHeat,
        ECool
    };

    TemperatureController(Settings settings);
    ~TemperatureController();

    inline bool enableMode() const { return _enableMode; }
    void setEnableMode(bool enableMode);

    inline double minTargetTemperature() const { return _minTargetTemp; }
    inline double maxTargetTemperature() const { return _maxTargetTemp; }

    void setTargetTemperature(double temperature);
    inline double targetTemperature() const { return _targetTemperature.load(); }
    double currentTemperature() const;

    virtual Direction outputDirection() const = 0;
    virtual void setOutput(double value) = 0;

    void process() final;

protected:
    virtual void resetOutput() = 0;
    virtual void processOutput() = 0;

private:
    void computePid(double currentTemperature);

protected:
    std::shared_ptr<Thermistor> _thermistor;

private:
    std::string _name;

    PIDController *_pidController;
    bool _pidState;
    double _pidResult;
    std::mutex _pidMutex;

    std::atomic<bool> _enableMode;

    std::atomic<double> _targetTemperature;
    double _minTargetTemp;
    double _maxTargetTemp;

    double _minTempThreshold;
    double _maxTempThreshold;
};

#endif // TEMPERATURECONTROLLER_H
