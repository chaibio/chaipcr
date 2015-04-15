#include "gpio.h"
#include "mux.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class MUX
MUX::MUX(vector<GPIO> &&muxControlPins) :
    _muxControlPins(move(muxControlPins)) {
}

MUX::MUX(MUX &&other) {
    _muxControlPins = move(other._muxControlPins);
    _channel = other._channel;

    other._channel = 0;
}

MUX::~MUX() {

}

MUX& MUX::operator =(MUX &&other) {
    _muxControlPins = move(other._muxControlPins);
    _channel = other._channel;

    other._channel = 0;

    return *this;
}

void MUX::setChannel(int channel) {
    for(GPIO &muxControlPin : this->_muxControlPins) {
        muxControlPin.setValue(static_cast<GPIO::Value>(channel&0x1), true);
        channel>>=1;
    }
    _channel=channel;

}

int MUX::getChannel() {
    return _channel;
}
