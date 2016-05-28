/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _LEDCONTROLLER_H_
#define _LEDCONTROLLER_H_

#include "pwm.h"
#include "gpio.h"

#include <memory>

class SPIPort;

// Class LEDController
class LEDController {
public:
    LEDController(std::shared_ptr<SPIPort> spiPort, unsigned int potCSPin,
                  unsigned int ledXLATPin, const std::string &ledBlankPWMPath, float dutyCyclePercentage);
	virtual ~LEDController();
	
    void setIntensity(double onCurrentMilliamps);
    inline double intensity() const { return _intensity; }
    void activateLED(unsigned int ledNumber);
    inline void disableLEDs() { disableLEDs(true); }

private:
    void disableLEDs(bool clearLastLed);

    void sendLEDGrayscaleValues(const uint8_t (&values)[24]);
	
private:
    std::atomic<float> _dutyCyclePercentage;
    double _intensity;

    unsigned _lastLedNumber;
	
	//components
    std::shared_ptr<SPIPort> _spiPort;
    GPIO _potCSPin;
    GPIO _ledXLATPin;
    GPIO _ledGSPin;
    PWMPin _ledBlankPWM;
};

#endif
