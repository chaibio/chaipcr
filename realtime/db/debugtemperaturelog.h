#ifndef DEBUGTEMPERATURELOG_H
#define DEBUGTEMPERATURELOG_H

class DebugTemperatureLog
{
public:
    DebugTemperatureLog(int experimentId)
    {
        _experimentId = experimentId;
        _elapsedTime = 0;
        _lidTemperature = 0;
        _heatBlockZone1Drive = 0;
        _heatBlockZone2Drive = 0;
    }

    inline int experimentId() const { return _experimentId; }

    inline long elapsedTime() const { return _elapsedTime; }
    inline void setElapsedTime(long time) { _elapsedTime = time; }

    inline double lidTemperature() const { return _lidTemperature; }
    inline void setLidTemperature(double temperature) { _lidTemperature = temperature; }

    inline double heatBlockZone1Drive() const { return _heatBlockZone1Drive; }
    inline void setHeatBlockZone1Drive(double drive) { _heatBlockZone1Drive = drive; }

    inline double heatBlockZone2Drive() const { return _heatBlockZone2Drive; }
    inline void setHeatBlockZone2Drive(double drive) { _heatBlockZone2Drive = drive; }

private:
    int _experimentId;
    long _elapsedTime;
    double _lidTemperature;
    double _heatBlockZone1Drive;
    double _heatBlockZone2Drive;
};


#endif // DEBUGTEMPERATURELOG_H
