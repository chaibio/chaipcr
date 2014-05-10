#ifndef TEMPERATURELOG_H
#define TEMPERATURELOG_H

class TemperatureLog
{
public:
    TemperatureLog(int experimentId)
    {
        _experimentId = experimentId;
        _elapsedTime = 0;
        _lidTemperature = 0;
        _heatBlockZone1Temperature = 0;
        _heatBlockZone2Temperature = 0;
    }

    inline int experimentId() const { return _experimentId; }

    inline time_t elapsedTime() const { return _elapsedTime; }
    inline void setElapsedTime(time_t time) { _elapsedTime = time; }

    inline double lidTemperature() const { return _lidTemperature; }
    inline void setLidTemperature(double temperature) { _lidTemperature = temperature; }

    inline double heatBlockZone1Temperature() const { return _heatBlockZone1Temperature; }
    inline void setHeatBlockZone1Temperature(double temperature) { _heatBlockZone1Temperature = temperature; }

    inline double heatBlockZone2Temperature() const { return _heatBlockZone2Temperature; }
    inline void setHeatBlockZone2Temperature(double temperature) { _heatBlockZone2Temperature = temperature; }

private:
    int _experimentId;
    time_t _elapsedTime;
    double _lidTemperature;
    double _heatBlockZone1Temperature;
    double _heatBlockZone2Temperature;
};

#endif // TEMPERATURELOG_H
