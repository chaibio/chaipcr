#ifndef PID_H
#define PID_H

#include "filters.h"

#include <vector>
#include <mutex>
#include <boost/date_time/posix_time/ptime.hpp>

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
    void reset();

private:
    const SPIDTuning& determineGainSchedule(double setpoint) const;
    bool latchValue(double& value, double minValue, double maxValue);

private:
    std::vector<SPIDTuning> _gainSchedule;
    SinglePoleRecursiveFilter _processValueFilter;
    const int _minOutput, _maxOutput;

    double _previousProcessValue;
    double _integratorS;
    boost::posix_time::ptime _previousExecutionTime;

    mutable std::mutex _lock;
};

#endif // PID_H
