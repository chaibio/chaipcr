#ifndef PID_H
#define PID_H

namespace Poco { class Timer; }

struct SPIDTuning {
    int maxValueInclusive;
    double kP;
    double kI;
    double kD;
};

////////////////////////////////////////////////////////////////////
// Class CPIDController
class CPIDController {
public:
    CPIDController(const std::vector<SPIDTuning>& pGainSchedule, int minOutput, int maxOutput);

    //accessors
    inline double getIntegrator() { return iIntegrator; }

    //computation
    double compute(double target, double currentValue);

private:
    const SPIDTuning& determineGainSchedule(double target);
    void latchValue(double* pValue, double minValue, double maxValue);

private:
    std::vector<SPIDTuning> ipGainSchedule;
    int iMinOutput, iMaxOutput;
    double iPreviousError;
    double iIntegrator;
};

class PIDControl {
public:
    PIDControl(CPIDController *pidController, long pidTimerInterval);
    virtual ~PIDControl();

    void startPid();
    void stopPid();

protected:
    virtual void pidCallback(double pidResult) = 0;

private:
    void pidCallback(Poco::Timer &timer);

protected:
    CPIDController *_pidController;
    std::atomic<double> _pidResult;

    Poco::Timer *_pidTimer;
    long _pidTimerInterval;

    std::function<double()> _targetValue;
    std::function<double()> _currentValue;
};

#endif // PID_H
