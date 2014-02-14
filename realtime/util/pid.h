#ifndef PID_H
#define PID_H

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

#endif // PID_H
