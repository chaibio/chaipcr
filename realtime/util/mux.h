#ifndef MUX_H
#define MUX_H

class GPIO;

////////////////////////////////////////////////////////////////////////////////
// Class MUX
class MUX {
public:
    MUX(std::vector<GPIO> &&muxControlPins);
    ~MUX();

    void setChannel(int channel);   //channel is 0 to ....n
    int getChannel();

private:

private:

    std::vector<GPIO> _muxControlPins;
    int _channel;
};
#endif // MUX_H
