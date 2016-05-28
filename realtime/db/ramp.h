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

    inline void setExcitationIntensity(double intensity) {_excitationIntensity = intensity;}
    inline double excitationIntensity() const {return _excitationIntensity;}

private:
    int _id;

    double _rate;

    bool _collectData;

    double _excitationIntensity;
};

#endif // RAMP_H
