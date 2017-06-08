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

#ifndef TEMPERATURELOG_H
#define TEMPERATURELOG_H

class TemperatureLog
{
public:
    TemperatureLog(int experimentId = 0, int stageId = 0, bool temperatureInfo = true, bool debugInfo = false)
    {
        _experimentId = experimentId;
        _stageId = stageId;
        _stepId = -1;
        _rampId = -1;

        _cycleNum = 0;
        _elapsedTime = 0;

        _temperatureState = temperatureInfo;
        _lidTemperature = 0;
        _heatBlockZone1Temperature = 0;
        _heatBlockZone2Temperature = 0;

        _debugState = debugInfo;
        _lidDrive = 0;
        _heatBlockZone1Drive = 0;
        _heatBlockZone2Drive = 0;
    }

    inline int experimentId() const { return _experimentId; }
    inline int stageId() const { return _stageId; }

    inline int stepId() const { return _stepId; }
    inline void setStepId(int id) { _stepId = id; }

    inline int rampId() const { return _rampId; }
    inline void setRampId(int id) { _rampId = id; }

    inline unsigned cycleNum() const { return _cycleNum; }
    inline void setCycleNum(unsigned num) { _cycleNum = num; }

    inline long elapsedTime() const { return _elapsedTime; }
    inline void setElapsedTime(long time) { _elapsedTime = time; }

    inline bool hasTemperatureInfo() const { return _temperatureState; }
    inline void setTemperatureState(bool state) { _temperatureState = state; }

    inline double lidTemperature() const { return _lidTemperature; }
    inline void setLidTemperature(double temperature) { _lidTemperature = temperature; }

    inline double heatBlockZone1Temperature() const { return _heatBlockZone1Temperature; }
    inline void setHeatBlockZone1Temperature(double temperature) { _heatBlockZone1Temperature = temperature; }

    inline double heatBlockZone2Temperature() const { return _heatBlockZone2Temperature; }
    inline void setHeatBlockZone2Temperature(double temperature) { _heatBlockZone2Temperature = temperature; }

    inline bool hasDebugInfo() const { return _debugState; }
    inline void setDebugState(bool state) { _debugState = state; }

    inline double lidDrive() const { return _lidDrive; }
    inline void setLidDrive(double drive) { _lidDrive = drive; }

    inline double heatBlockZone1Drive() const { return _heatBlockZone1Drive; }
    inline void setHeatBlockZone1Drive(double drive) { _heatBlockZone1Drive = drive; }

    inline double heatBlockZone2Drive() const { return _heatBlockZone2Drive; }
    inline void setHeatBlockZone2Drive(double drive) { _heatBlockZone2Drive = drive; }

    inline double heatSinkTemperature() const { return _heatSinkTemperature; }
    inline void setHeatSinkTemperature(double temperature) { _heatSinkTemperature = temperature; }

    inline double heatSinkDrive() const { return _heatSinkDrive; }
    inline void setHeatSinkDrive(double drive) { _heatSinkDrive = drive; }

private:
    int _experimentId;
    int _stageId;
    int _stepId;
    int _rampId;

    unsigned _cycleNum;
    long _elapsedTime;

    bool _temperatureState;
    double _lidTemperature;
    double _heatBlockZone1Temperature;
    double _heatBlockZone2Temperature;

    bool _debugState;
    double _lidDrive;
    double _heatBlockZone1Drive;
    double _heatBlockZone2Drive;
    double _heatSinkTemperature;
    double _heatSinkDrive;
};

#endif // TEMPERATURELOG_H
