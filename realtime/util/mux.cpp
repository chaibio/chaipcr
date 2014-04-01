#include "pcrincludes.h"

#include "mux.h"
#include "gpio.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class MUX
MUX::MUX(vector<shared_ptr<GPIO>> muxControlPins) :
    _muxControlPins{muxControlPins}{
}

MUX::~MUX() {

}

void MUX::setChannel(int channel) {
    for(auto muxControlPin : this->_muxControlPins) {
        muxControlPin->setValue(static_cast<GPIO::Value>(channel&0x1), true);
        channel>>=1;
    }

}

int MUX::getChannel() {
    return _channel;
}
