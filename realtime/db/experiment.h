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

#ifndef EXPERIMENT_H
#define EXPERIMENT_H

#include <string>

#include <boost/chrono.hpp>
#include <boost/date_time/posix_time/ptime.hpp>

class Protocol;

class Experiment
{
public:
    enum CompletionStatus
    {
        None,
        Success,
        Failed,
        Aborted
    };

    enum Type
    {
        NoneType,
        DiagnosticType,
        CalibrationType
    };

    Experiment();
    Experiment(int id, int definationId = -1);
    Experiment(const Experiment &other);
    Experiment(Experiment &&other);
    ~Experiment();

    Experiment& operator= (const Experiment &other);
    Experiment& operator= (Experiment &&other);

    inline bool empty() const { return _definationId == -1 || _id == -1; }

    inline void setDefinationId(int id) { _definationId = id; }
    inline int definationId() const { return _definationId; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    inline void setType(Type type) {_type = type;}
    inline Type type() const {return _type;}

    inline void setId(int id) { _id = id; }
    inline int id() const { return _id; }

    inline void setStartedAt(const boost::posix_time::ptime &startedAt) {_startedAt = startedAt;}
    inline const boost::posix_time::ptime& startedAt() const {return _startedAt;}

    inline void setCompletedAt(const boost::posix_time::ptime &completedAt) {_completedAt = completedAt;}
    inline const boost::posix_time::ptime& completedAt() const {return _completedAt;}

    inline void setCompletionStatus(CompletionStatus status) {_completionStatus = status;}
    inline CompletionStatus completionStatus() const {return _completionStatus;}

    inline void setCompletionMessage(const std::string &message) {_completionMessage = message;}
    inline void setCompletionMessage(std::string &&message) {_completionMessage = std::move(message);}
    inline const std::string& completionMessage() const {return _completionMessage;}

    inline const boost::chrono::steady_clock::time_point& startedAtPoint() const { return _startedAtPoint; }
    void setStartedAtPoint(const boost::chrono::steady_clock::time_point &time) { _startedAtPoint = time; }

    inline const boost::chrono::steady_clock::time_point& completedAtPoint() const { return _startedAtPoint; }
    void setCompletedAtPoint(const boost::chrono::steady_clock::time_point &time) { _startedAtPoint = time; }

    inline const boost::chrono::milliseconds& estimatedDuration() const { return _estimatedDuration; }
    inline void setEstimatedDuration(const boost::chrono::milliseconds &duration) { _estimatedDuration = duration; }

    inline const boost::chrono::milliseconds& pausedDuration() const { return _pausedDuration; }
    inline void setPausedDuration(const boost::chrono::milliseconds &duration) { _pausedDuration = duration; }

    inline const boost::chrono::steady_clock::time_point& lastPauseTime() const { return _lastPauseTime; }
    void setPauseTime(const boost::chrono::steady_clock::time_point &time) { _lastPauseTime = time; }

    inline bool isExtended() const { return _extendedState; }
    inline void setExtended(bool state) { _extendedState = state; }

    inline bool hasBeganStep() const { return _stepBeganState; }
    inline void setStepBegan(bool state) { _stepBeganState = state; }

    void setProtocol(const Protocol &protocol);
    void setProtocol(Protocol &&protocol);
    void setProtocol(Protocol *protocol);
    inline Protocol* protocol() const {return _protocol;}

    void setStartedTime();
    void setCompletedTime();

private:
    int _definationId;
    std::string _name;
    Type _type;

    int _id;
    boost::posix_time::ptime _startedAt;
    boost::posix_time::ptime _completedAt;
    CompletionStatus _completionStatus;
    std::string _completionMessage;

    boost::chrono::steady_clock::time_point _startedAtPoint;
    boost::chrono::steady_clock::time_point _completedAtPoint;

    boost::chrono::milliseconds _estimatedDuration;
    boost::chrono::milliseconds _pausedDuration;
    boost::chrono::steady_clock::time_point _lastPauseTime;

    bool _extendedState;
    bool _stepBeganState;

    Protocol *_protocol;
};

#endif // EXPERIMENT_H
