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

#ifndef STAGECOMPONENT_H
#define STAGECOMPONENT_H

class Step;
class Ramp;

class StageComponent
{
public:
    StageComponent();
    StageComponent(const StageComponent &other);
    StageComponent(StageComponent &&other);
    ~StageComponent();

    StageComponent& operator= (const StageComponent &other);
    StageComponent& operator= (StageComponent &&other);

    void setStep(const Step &step);
    void setStep(Step &&step);
    void setStep(Step *step);
    inline Step* step() const {return _step;}

    void setRamp(const Ramp &ramp);
    void setRamp(Ramp &&ramp);
    void setRamp(Ramp *ramp);
    inline Ramp* ramp() const {return _ramp;}

private:
    Step *_step;
    Ramp *_ramp;
};

#endif // STAGECOMPONENT_H
