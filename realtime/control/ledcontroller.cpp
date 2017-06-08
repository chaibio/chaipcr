//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include "pcrincludes.h"
#include "spi.h"
#include "ledcontroller.h"
#include "constants.h"

#include <sstream>
#include <limits>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
// Class LEDController
LEDController::LEDController(shared_ptr<SPIPort> spiPort,unsigned int potCSPin,
                             unsigned int ledXLATPin, const string &ledBlankPWMPath, float dutyCyclePercentage):
    _spiPort(spiPort),
    _potCSPin(potCSPin, GPIO::kOutput),
    _ledXLATPin(ledXLATPin, GPIO::kOutput),
    _ledBlankPWM(ledBlankPWMPath),
    _ledGSPin(kLEDControlGSPinNumber, GPIO::kOutput),
    _intensityFine(kWellCount, 0x3F){

    _intensity = 0;
    _lastLedNumber = std::numeric_limits<unsigned>::max();

    _dutyCyclePercentage.store(dutyCyclePercentage);

    _ledBlankPWM.setPWM(kLedBlankPwmDutyNs, kLedBlankPwmPeriodNs, 0);
    setIntensity(kDefaultLEDCurrent);
    disableLEDs();

    _potCSPin.setValue(GPIO::kHigh);
    _ledXLATPin.setValue(GPIO::kLow);
    _ledGSPin.setValue(GPIO::kLow);
}

LEDController::~LEDController() {
	
}

void LEDController::setIntensity(double onCurrentMilliamps) {
    if (_intensity == onCurrentMilliamps)
        return;

    if (onCurrentMilliamps > 0)
    {
        if (onCurrentMilliamps < kMinLEDCurrent)
        {
            std::stringstream stream;
            stream << "Requested LED intensity of " << onCurrentMilliamps << " below limit of " << kMinLEDCurrent;

            throw InvalidArgument(stream.str().c_str());
        }

        if (onCurrentMilliamps > kMaxInstantaneousLEDCurrent)
        {
            std::stringstream stream;
            stream << "Requested LED intensity of " << onCurrentMilliamps << " above limit of " << kMaxInstantaneousLEDCurrent;

            throw InvalidArgument(stream.str().c_str());
        }

        double avgCurrentMilliamps = onCurrentMilliamps * _dutyCyclePercentage / 100;

        if (avgCurrentMilliamps > kMaxAverageLEDCurrent)
        {
            std::stringstream stream;
            stream << "Requested LED intensity of " << onCurrentMilliamps << " will exceed the max average current of " << kMaxAverageLEDCurrent;

            throw InvalidArgument(stream.str().c_str());
        }

        //calculate
        double rIref = 1.24 / (onCurrentMilliamps / 1000) * 31.5; //reference resistance for TLC5940
        if (rIref > kLEDPotMaxResistance || rIref < kLEDPotMinResistance)
        {
            std::stringstream stream;
            stream << "Requested LED intensity of " << onCurrentMilliamps << " requires a resistance outside the valid range of [ " << kLEDPotMinResistance << ", " << kLEDPotMaxResistance << " ]";

            throw InvalidArgument(stream.str().c_str());
        }
        int rN = (rIref - kLEDPotMinResistance) * 256 / (kLEDPotMaxResistance - kLEDPotMinResistance);
        char txBuf[] = {0, static_cast<uint8_t>(rN)};

        //send resistance
        _potCSPin.setValue(GPIO::kLow);
        _spiPort->setMode(0);
        _spiPort->readBytes(NULL, txBuf, sizeof(txBuf), kLEDSpiSpeed_Hz);
        _potCSPin.setValue(GPIO::kHigh);

        sendLEDIntensityFineValues();
        sendLEDGrayscaleValues();
    }
    else {
        disableLEDs(false);
    }

    _intensity = onCurrentMilliamps;
}

void LEDController::activateLED(unsigned int ledNumber) {

    _lastLedNumber = kWellToLedMappingList.at(ledNumber);

    if (_intensity > 0)
    {
        sendLEDIntensityFineValues();
        sendLEDGrayscaleValues();
    }
}

void LEDController::setIntensityFine(uint8_t ledIntensity, int ledNumber){

    if(ledIntensity > kLEDFineIntensityMax){
        std::stringstream stream;
        stream << "Invalid intensity value: " << (int) ledIntensity;

        throw InvalidArgument(stream.str().c_str());
    }

    if(ledNumber > kWellCount - 1){
        std::stringstream stream;
        stream << "Invalid LED number of " << ledNumber;

        throw InvalidArgument(stream.str().c_str());
    }

    if(ledNumber < 0){
        std::fill(_intensityFine.begin(), _intensityFine.end(), ledIntensity);
    }
    else{
        _intensityFine[kWellToLedMappingList.at(ledNumber)] = ledIntensity;
    }

    sendLEDIntensityFineValues();
    sendLEDGrayscaleValues(false);
}

void LEDController::sendLEDIntensityFineValues(){

    uint8_t fine_int_values[kWellCount] = {0};
    if (_lastLedNumber != std::numeric_limits<unsigned>::max()){
            fine_int_values[_lastLedNumber] = _intensityFine[_lastLedNumber] ;
    }

    uint8_t packed_data[12] = {0};
    for (int i = 15; i > 0; i -= 4) {
        int pack_index = (15 - i) / 4 * 3;
        packed_data[pack_index + 0] = ((fine_int_values[i-0] << 2 ) & 0xFC) | (( fine_int_values[i-1] >> 4) & 0x03 );
        packed_data[pack_index + 1] = ((fine_int_values[i-1] << 4 ) & 0xF0) | (( fine_int_values[i-2] >> 2) & 0x0F );
        packed_data[pack_index + 2] = ((fine_int_values[i-2] << 6 ) & 0xC0) | (( fine_int_values[i-3] >> 0) & 0x3F );
    }

    _ledGSPin.setValue(GPIO::kHigh);
    _spiPort->setMode(0);
    _spiPort->readBytes(NULL, (char*)packed_data, sizeof(packed_data), kLEDSpiSpeed_Hz);
    _ledXLATPin.setValue(GPIO::kHigh);
    _ledXLATPin.setValue(GPIO::kLow);
    _ledGSPin.setValue(GPIO::kLow);

}

void LEDController::sendLEDGrayscaleValues(bool latch){

    uint16_t gs_values[kWellCount] = {0};
    if (_lastLedNumber != std::numeric_limits<unsigned>::max()){
            gs_values[_lastLedNumber] = 0xFFF;
    }

    uint8_t packed_data[24] = {0};
    for (int i = 15; i > 0; i -= 2) {
        int pack_index = (15 - i) / 2 * 3;
        packed_data[pack_index + 0] = ((gs_values[i]   >> 4 ) & 0x00FF);
        packed_data[pack_index + 1] = ((gs_values[i]   << 4 ) & 0x00F0) | ((gs_values[i-1] >> 8 ) & 0x000F);
        packed_data[pack_index + 2] =                                     ((gs_values[i-1] >> 0 ) & 0x00FF);
    }

    _spiPort->setMode(0);
    _spiPort->readBytes(NULL, (char*)packed_data, sizeof(packed_data), kLEDSpiSpeed_Hz);

    if(latch){
        _ledXLATPin.setValue(GPIO::kHigh);
        _ledXLATPin.setValue(GPIO::kLow);
    }
}

void LEDController::disableLEDs(bool clearLastLed) {

    unsigned tmp = _lastLedNumber;
    _lastLedNumber = std::numeric_limits<unsigned>::max();

    sendLEDIntensityFineValues();
    sendLEDGrayscaleValues();

    if (!clearLastLed){
        _lastLedNumber = tmp;
    }
}
