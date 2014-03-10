#ifndef STAGECOMPONENT_H
#define STAGECOMPONENT_H

class Step;
class Ramp;

class StageComponent
{
public:
    StageComponent();
    StageComponent(const StageComponent &other);
    StageComponent(StageComponent &&other);
    ~StageComponent();

    StageComponent& operator= (const StageComponent &other);
    StageComponent& operator= (StageComponent &&other);

    void setStep(const Step &step);
    void setStep(Step &&step);
    inline Step* step() const {return _step;}

    void setRamp(const Ramp &ramp);
    void setRamp(Ramp &&ramp);
    inline Ramp* ramp() const {return _ramp;}

private:
    Step *_step;
    Ramp *_ramp;
};

#endif // STAGECOMPONENT_H
