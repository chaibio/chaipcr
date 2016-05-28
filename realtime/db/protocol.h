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

#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <vector>

class Stage;
class Step;
class Ramp;

class Protocol
{
public:
    Protocol();
    Protocol(const Protocol &other);
    Protocol(Protocol &&other);
    ~Protocol();

    Protocol& operator= (const Protocol &other);
    Protocol& operator= (Protocol &&other);

    inline void setLidTemperature(double temperature) {_lidTemperature = temperature;}
    inline double lidTemperature() const {return _lidTemperature;}

    void setStages(const std::vector<Stage> &stages);
    void setStages(std::vector<Stage> &&stages);
    void appendStage(const Stage &stage);
    void appendStage(Stage &&stage);
    inline const std::vector<Stage>& stages() const {return _stages;}

    void resetCurrentStep();
    inline Stage* currentStage() const {return _currentStage != _stages.end() ? &*_currentStage : nullptr;}
    Step* currentStep() const;
    Ramp* currentRamp() const;
    Step* advanceNextStep();
    bool hasNextStep() const;

private:
    double _lidTemperature;

    std::vector<Stage> _stages;
    std::vector<Stage>::iterator _currentStage;
};

#endif // PROTOCOL_H
