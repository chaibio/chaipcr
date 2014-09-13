#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <vector>

class Stage;
class Step;
class Ramp;

class Protocol
{
public:
    Protocol();
    Protocol(const Protocol &other);
    Protocol(Protocol &&other);
    ~Protocol();

    Protocol& operator= (const Protocol &other);
    Protocol& operator= (Protocol &&other);

    inline void setLidTemperature(double temperature) {_lidTemperature = temperature;}
    inline double lidTemperature() const {return _lidTemperature;}

    void setStages(const std::vector<Stage> &stages);
    void setStages(std::vector<Stage> &&stages);
    void appendStage(const Stage &stage);
    void appendStage(Stage &&stage);
    inline const std::vector<Stage>& stages() const {return _stages;}

    void resetCurrentStep();
    inline Stage* currentStage() const {return &*_currentStage;}
    Step* currentStep() const;
    Ramp* currentRamp() const;
    Step* advanceNextStep();
    bool hasNextStep() const;

private:
    double _lidTemperature;

    std::vector<Stage> _stages;
    std::vector<Stage>::iterator _currentStage;
};

#endif // PROTOCOL_H
