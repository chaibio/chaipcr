#ifndef STAGE_H
#define STAGE_H

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

    Stage();
    Stage(const Stage &other);
    Stage(Stage &&other);
    ~Stage();

    Stage& operator= (const Stage &other);
    Stage& operator= (Stage &&other);

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    void setNumCycles(int numCycles);
    inline int numCycles() const {return _numCycles;}
    inline int currentCycle() const {return _cycleIteration;}

    inline void setOrderNumber(int orderNumber) {_orderNumber = orderNumber;}
    inline int orderNumber() const {return _orderNumber;}

    inline void setType(Type type) {_type = type;}
    inline Type type() const {return _type;}

    void setComponents(const std::vector<StageComponent> &components);
    void setComponents(std::vector<StageComponent> &&components);
    void appendComponent(const StageComponent &component);
    void appendComponent(StageComponent &&component);
    inline const std::vector<StageComponent>& components() const {return _components;}

    void resetCurrentStep();
    Step* currentStep() const;
    Ramp* currentRamp() const;
    Step* nextStep();
    bool hasNextStep() const;

private:
    std::string _name;

    int _numCycles;
    std::atomic<int> _cycleIteration;

    int _orderNumber;
    Type _type;

    std::vector<StageComponent> _components;
    std::vector<StageComponent>::iterator _currentComponent;
};

#endif // STAGE_H
