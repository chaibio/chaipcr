#ifndef STAGE_H
#define STAGE_H

#include <string>
#include <vector>
#include <atomic>

class StageComponent;
class Step;
class Ramp;

class Stage
{
public:
    enum Type
    {
        None,
        Holding,
        Cycling,
        Meltcurve
    };

    Stage(int id);
    Stage(const Stage &other);
    Stage(Stage &&other);
    ~Stage();

    Stage& operator= (const Stage &other);
    Stage& operator= (Stage &&other);

    inline int id() const { return _id; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    void setNumCycles(unsigned numCycles, unsigned currentCycle = 1);
    inline unsigned numCycles() const {return _numCycles;}
    inline unsigned currentCycle() const {return _cycleIteration;}

    inline void setOrderNumber(int orderNumber) {_orderNumber = orderNumber;}
    inline int orderNumber() const {return _orderNumber;}

    inline void setType(Type type) {_type = type;}
    inline Type type() const {return _type;}

    inline void setAutoDelta(bool state) {_autoDelta = state;}
    inline bool autoDelta() const {return _autoDelta;}

    inline void setAutoDeltaStartCycle(unsigned cycle) {_autoDeltaStartCycle = cycle;}
    inline unsigned autoDeltaStartCycle() const {return _autoDeltaStartCycle;}

    void setComponents(const std::vector<StageComponent> &components);
    void setComponents(std::vector<StageComponent> &&components);
    void appendComponent(const StageComponent &component);
    void appendComponent(StageComponent &&component);
    inline const std::vector<StageComponent>& components() const {return _components;}

    void resetCurrentStep();
    Step* currentStep() const;
    Ramp* currentRamp() const;
    Step* advanceNextStep();
    bool hasNextStep() const;

private:
    int _id;
    std::string _name;

    unsigned _numCycles;
    std::atomic<unsigned> _cycleIteration;

    int _orderNumber;
    Type _type;

    bool _autoDelta;
    unsigned _autoDeltaStartCycle;

    std::vector<StageComponent> _components;
    std::vector<StageComponent>::iterator _currentComponent;
};

#endif // STAGE_H
