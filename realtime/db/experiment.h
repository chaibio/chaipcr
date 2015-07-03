#ifndef EXPERIMENT_H
#define EXPERIMENT_H

#include <string>
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

    Experiment();
    Experiment(int definationId);
    Experiment(const Experiment &other);
    Experiment(Experiment &&other);
    ~Experiment();

    Experiment& operator= (const Experiment &other);
    Experiment& operator= (Experiment &&other);

    inline bool empty() const { return _definationId == -1; }

    inline int definationId() const { return _definationId; }

    inline void setId(int id) { _id = id; }
    inline int id() const { return _id; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    inline void setStartedAt(const boost::posix_time::ptime &startedAt) {_startedAt = startedAt;}
    inline const boost::posix_time::ptime& startedAt() const {return _startedAt;}

    inline void setCompletedAt(const boost::posix_time::ptime &completedAt) {_completedAt = completedAt;}
    inline const boost::posix_time::ptime& completedAt() const {return _completedAt;}

    inline void setCompletionStatus(CompletionStatus status) {_completionStatus = status;}
    inline CompletionStatus completionStatus() const {return _completionStatus;}

    inline void setCompletionMessage(const std::string &message) {_completionMessage = message;}
    inline void setCompletionMessage(std::string &&message) {_completionMessage = std::move(message);}
    inline const std::string& completionMessage() const {return _completionMessage;}

    inline std::time_t estimatedDuration() const { return _estimatedDuration; }
    inline void setEstimatedDuration(std::time_t duration) { _estimatedDuration = duration; }

    inline std::time_t pausedDuration() const { return _pausedDuration; }
    inline void setPausedDuration(std::time_t duration) { _pausedDuration = duration; }

    inline const boost::posix_time::ptime& lastPauseTime() const { return _lastPauseTime; }
    void setPauseTime(const boost::posix_time::ptime &time) { _lastPauseTime = time; }

    void setProtocol(const Protocol &protocol);
    void setProtocol(Protocol &&protocol);
    void setProtocol(Protocol *protocol);
    inline Protocol* protocol() const {return _protocol;}

private:
    int _definationId;
    std::string _name;

    int _id;
    boost::posix_time::ptime _startedAt;
    boost::posix_time::ptime _completedAt;
    CompletionStatus _completionStatus;
    std::string _completionMessage;

    std::time_t _estimatedDuration;
    std::time_t _pausedDuration;
    boost::posix_time::ptime _lastPauseTime;

    Protocol *_protocol;
};

#endif // EXPERIMENT_H
