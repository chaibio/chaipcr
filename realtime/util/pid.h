#ifndef PID_H
#define PID_H

#include "filters.h"

#include <vector>
#include <boost/date_time/posix_time/ptime.hpp>
#include <Poco/RWLock.h>

struct SPIDTuning {
    int maxValueInclusive;
    double kControllerGain;
    double kIntegralTimeS;
    double kDerivativeTimeS;
};

////////////////////////////////////////////////////////////////////
// Class PIDController
class PIDController {
public:
    PIDController(const std::vector<SPIDTuning>& pGainSchedule, int minOutput, int maxOutput, const SinglePoleRecursiveFilter& processValueFilter);
    ~PIDController();

    inline int getMinOutput() const { return _minOutput; }
    inline int getMaxOutput() const { return _maxOutput; }

    //computation
    double compute(double setpoint, double processValue);

private:
    const SPIDTuning& determineGainSchedule(double setpoint) const;
    bool latchValue(double* value, double minValue, double maxValue);

private:
    std::vector<SPIDTuning> _gainSchedule;
    SinglePoleRecursiveFilter _processValueFilter;
    const int _minOutput, _maxOutput;

    double _previousProcessValue;
    double _integratorS;
    boost::posix_time::ptime _previousExecutionTime;

    mutable Poco::RWLock lock;
};

/*class PIDControl {
public:
    PIDControl(PIDController *pidController, long pidTimerInterval);
    virtual ~PIDControl();

protected:
    void startPid();
    void stopPid();

    virtual void pidCallback(double pidResult) = 0;

private:
    void pidCallback(Poco::Timer &timer);

protected:
    PIDController *_pidController;
    std::atomic<double> _pidResult;

    Poco::Timer *_pidTimer;
    long _pidTimerInterval;

    std::function<double()> _targetValue;
    std::function<double()> _currentValue;
};*/

#endif // PID_H
