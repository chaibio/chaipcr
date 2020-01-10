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

#ifndef _THERMISTOR_H_
#define _THERMISTOR_H_

#include "adcconsumer.h"
#include "lockfreesignal.h"

#include <atomic>
#include <functional>

// Class Thermistor
class Thermistor: public ADCConsumer {
public:
    Thermistor(unsigned int voltageDividerResistance, unsigned int adcBits);
    virtual ~Thermistor() {}
	
	//accessors
    inline double temperature() const { return _temperature; }

    //ADCConsumer
    void setADCValue(int32_t adcValue);
    void setADCValues(int32_t differentialADCValue, int32_t singularADCValue);
    void setADCValueMock(double adcValue);

    template <typename Callback>
    void setTemperatureChangeCallback(Callback callback) { _temperatureChangeCallback = callback; }

protected:
    virtual double temperatureForResistance(double resistanceOhms) = 0;
	
private:
    std::atomic<double> _temperature;

    const unsigned int _maxADCValue;
    const unsigned int _voltageDividerResistance;

    std::function<void(double)> _temperatureChangeCallback;
};

class SteinhartHartThermistorC0123: public Thermistor {
public:
    SteinhartHartThermistorC0123(unsigned int voltageDividerResistance, unsigned int adcBits,
        double c0, double c1, double c2, double c3);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _c0, _c1, _c2, _c3; //steinhart-hart coefficients
};

class SteinhartHartThermistorC0135: public Thermistor {
public:
    SteinhartHartThermistorC0135(unsigned int voltageDividerResistance, unsigned int adcBits,
        double c0, double c1, double c3, double c5);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _c0, _c1, _c3, _c5; //steinhart-hart coefficients
};

class SteinhartHartThermistorC0135_V2: public Thermistor {
public:
    SteinhartHartThermistorC0135_V2(unsigned int voltageDividerResistance, unsigned int adcBits,
        double a, double b, double c);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _a, _b, _c; //steinhart-hart coefficients
};

class BetaThermistor: public Thermistor {
public:
    BetaThermistor(unsigned int voltageDividerResistance, unsigned int adcBits,
        double beta, double r0, double t0);

    double temperatureForResistance(double resistanceOhms) override;

private:
    const double _beta; //beta coefficients
    const double _r0;   //resistance at _t0
    const double _t0;   //in kelvins - usually 298.15K
    double _rInfinity;  //calculated from _r0 and _beta
};

#endif
