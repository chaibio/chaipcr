#ifndef PID_H
#define PID_H

namespace Poco { class Timer; class RWLock; }

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
    ~CPIDController();

    //accessors
    double getIntegrator() const;
    void setIntegrator(double integrator);

    double getPreviousError() const;
    void setPreviousError(double error);

    inline int getMinOutput() const { return iMinOutput; }
    inline int getMaxOutput() const { return iMaxOutput; }

    //computation
    double compute(double target, double currentValue);

private:
    const SPIDTuning& determineGainSchedule(double target) const;
    void latchValue(double* pValue, double minValue, double maxValue);

private:
    std::vector<SPIDTuning> ipGainSchedule;
    const int iMinOutput, iMaxOutput;
    double iPreviousError;
    double iIntegrator;

    mutable Poco::RWLock *lock;
};

class PIDControl {
public:
    PIDControl(CPIDController *pidController, long pidTimerInterval);
    virtual ~PIDControl();

protected:
    void startPid();
    void stopPid();

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
