#ifndef RAMP_H
#define RAMP_H

class Ramp
{
public:
    Ramp(int id);
    Ramp(const Ramp &other);
    Ramp(Ramp &&other);
    ~Ramp();

    Ramp& operator= (const Ramp &other);
    Ramp& operator= (Ramp &&other);

    inline int id() const { return _id; }

    inline void setRate(double rate) {_rate = rate;}
    inline double rate() const {return _rate;}

    inline void setCollectData(bool collectData) {_collectData = collectData;}
    inline double collectData() const {return _collectData;}

private:
    int _id;

    double _rate;

    bool _collectData;
};

#endif // RAMP_H
