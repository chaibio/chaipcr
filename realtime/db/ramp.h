#ifndef RAMP_H
#define RAMP_H

class Ramp
{
public:
    Ramp();
    Ramp(const Ramp &other);
    Ramp(Ramp &&other);
    ~Ramp();

    Ramp& operator= (const Ramp &other);
    Ramp& operator= (Ramp &&other);

    inline void setRate(double rate) {_rate = rate;}
    inline double rate() const {return _rate;}

private:
    double _rate;
};

#endif // RAMP_H
