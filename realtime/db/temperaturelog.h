#ifndef TEMPERATURELOG_H
#define TEMPERATURELOG_H

class TemperatureLog
{
public:
    TemperatureLog(int experimentId, bool debugState = false)
    {
        _experimentId = experimentId;
        _elapsedTime = 0;
        _lidTemperature = 0;
        _heatBlockZone1Temperature = 0;
        _heatBlockZone2Temperature = 0;

        _debugState = debugState;
        _lidDrive = 0;
        _heatBlockZone1Drive = 0;
        _heatBlockZone2Drive = 0;
    }

    inline int experimentId() const { return _experimentId; }

    inline long elapsedTime() const { return _elapsedTime; }
    inline void setElapsedTime(long time) { _elapsedTime = time; }

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

private:
    int _experimentId;
    long _elapsedTime;
    double _lidTemperature;
    double _heatBlockZone1Temperature;
    double _heatBlockZone2Temperature;

    bool _debugState;
    double _lidDrive;
    double _heatBlockZone1Drive;
    double _heatBlockZone2Drive;
};

#endif // TEMPERATURELOG_H
