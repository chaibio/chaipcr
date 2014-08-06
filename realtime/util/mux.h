#ifndef MUX_H
#define MUX_H

#include <vector>

class GPIO;

////////////////////////////////////////////////////////////////////////////////
// Class MUX
class MUX {
public:
    MUX(std::vector<GPIO> &&muxControlPins);
    MUX(MUX &&other);
    ~MUX();

    MUX& operator= (MUX &&other);

    void setChannel(int channel);   //channel is 0 to ....n
    int getChannel();

private:

private:

    std::vector<GPIO> _muxControlPins;
    int _channel;
};
#endif // MUX_H
