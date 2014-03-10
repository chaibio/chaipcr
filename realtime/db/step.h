#ifndef STEP_H
#define STEP_H

class Step
{
public:
    Step();
    Step(const Step &other);
    Step(Step &&other);
    ~Step();

    Step& operator= (const Step &other);
    Step& operator= (Step &&other);

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = name;}
    inline const std::string name() const {return _name;}

    inline void setTemperature(int temperature) {_temperature = temperature;}
    inline int temperature() const {return _temperature;}

    inline void setHoldTime(const Poco::Timestamp& holdTime) {_holdTime = holdTime;}
    inline const Poco::Timestamp& holdTime() const {return _holdTime;}

    inline void setOrderNumber(int orderNumber) {_orderNumber = orderNumber;}
    inline int orderNumber() const {return _orderNumber;}

private:
    std::string _name;

    double _temperature;
    Poco::Timestamp _holdTime;
    int _orderNumber;
};

#endif // STEP_H
