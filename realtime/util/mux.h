#ifndef MUX_H
#define MUX_H

class GPIO;

using namespace std;
////////////////////////////////////////////////////////////////////////////////
// Class MUX
class MUX {
public:
    MUX(vector<shared_ptr<GPIO>> muxControlPins);
    ~MUX();

    void setChannel(int channel);   //channel is 0 to ....n
    int getChannel();

private:

private:

    vector<shared_ptr<GPIO>> _muxControlPins;
    int _channel;
};
#endif // MUX_H
