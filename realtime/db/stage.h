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

#ifndef STAGE_H
#define STAGE_H

#include <string>
#include <vector>
#include <atomic>

class StageComponent;
class Step;
class Ramp;

class Stage
{
public:
    enum Type
    {
        None,
        Holding,
        Cycling,
        Meltcurve
    };

    Stage(int id);
    Stage(const Stage &other);
    Stage(Stage &&other);
    ~Stage();

    Stage& operator= (const Stage &other);
    Stage& operator= (Stage &&other);

    inline int id() const { return _id; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    void setNumCycles(unsigned numCycles);
    inline unsigned numCycles() const {return _numCycles;}
    inline unsigned currentCycle() const {return _cycleIteration;}

    inline void setOrderNumber(int orderNumber) {_orderNumber = orderNumber;}
    inline int orderNumber() const {return _orderNumber;}

    inline void setType(Type type) {_type = type;}
    inline Type type() const {return _type;}

    inline void setAutoDelta(bool state) {_autoDelta = state;}
    inline bool autoDelta() const {return _autoDelta;}

    inline void setAutoDeltaStartCycle(unsigned cycle) {_autoDeltaStartCycle = cycle;}
    inline unsigned autoDeltaStartCycle() const {return _autoDeltaStartCycle;}

    void setComponents(const std::vector<StageComponent> &components);
    void setComponents(std::vector<StageComponent> &&components);
    void appendComponent(const StageComponent &component);
    void appendComponent(StageComponent &&component);
    inline const std::vector<StageComponent>& components() const {return _components;}

    void resetCurrentStep();
    Step* currentStep() const;
    Ramp* currentRamp() const;
    Step* advanceNextStep();
    bool hasNextStep() const;

private:
    int _id;
    std::string _name;

    unsigned _numCycles;
    std::atomic<unsigned> _cycleIteration;

    int _orderNumber;
    Type _type;

    bool _autoDelta;
    unsigned _autoDeltaStartCycle;

    std::vector<StageComponent> _components;
    std::vector<StageComponent>::iterator _currentComponent;
};

#endif // STAGE_H
