#include "pcrincludes.h"

#include "mux.h"
#include "gpio.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class MUX
MUX::MUX(vector<GPIO> &&muxControlPins) :
    _muxControlPins(move(muxControlPins)) {
}

MUX::~MUX() {

}

void MUX::setChannel(int channel) {
    for(GPIO &muxControlPin : this->_muxControlPins) {
        muxControlPin.setValue(static_cast<GPIO::Value>(channel&0x1), true);
        channel>>=1;
    }

}

int MUX::getChannel() {
    return _channel;
}
