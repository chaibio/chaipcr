#ifndef STEP_H
#define STEP_H

#include <string>
#include <ctime>

class Step
{
public:
    Step(int id);
    Step(const Step &other);
    Step(Step &&other);
    ~Step();

    Step& operator= (const Step &other);
    Step& operator= (Step &&other);

    inline int id() const { return _id; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    inline void setTemperature(double temperature) {_temperature = temperature;}
    inline double temperature() const {return _temperature;}

    inline void setHoldTime(time_t holdTime) {_holdTime = holdTime;}
    inline time_t holdTime() const {return _holdTime;}

    inline void setOrderNumber(int orderNumber) {_orderNumber = orderNumber;}
    inline int orderNumber() const {return _orderNumber;}

private:
    int _id;

    std::string _name;

    double _temperature;
    time_t _holdTime;
    int _orderNumber;
};

#endif // STEP_H
