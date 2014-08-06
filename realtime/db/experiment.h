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

    Experiment(int id);
    Experiment(const Experiment &other);
    Experiment(Experiment &&other);
    ~Experiment();

    Experiment& operator= (const Experiment &other);
    Experiment& operator= (Experiment &&other);

    inline int id() const { return _id; }

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = std::move(name);}
    inline const std::string& name() const {return _name;}

    inline void setQpcr(bool qpcr) {_qpcr = qpcr;}
    inline bool qpcr() const {return _qpcr;}

    inline void setStartedAt(const boost::posix_time::ptime &startedAt) {_startedAt = startedAt;}
    inline const boost::posix_time::ptime& startedAt() const {return _startedAt;}

    inline void setCompletedAt(const boost::posix_time::ptime &completedAt) {_completedAt = completedAt;}
    inline const boost::posix_time::ptime& completedAt() const {return _completedAt;}

    inline void setCompletionStatus(CompletionStatus status) {_completionStatus = status;}
    inline CompletionStatus completionStatus() const {return _completionStatus;}

    void setProtocol(const Protocol &protocol);
    void setProtocol(Protocol &&protocol);
    void setProtocol(Protocol *protocol);
    inline Protocol* protocol() const {return _protocol;}

private:
    int _id;

    std::string _name;
    bool _qpcr;
    boost::posix_time::ptime _startedAt;
    boost::posix_time::ptime _completedAt;
    CompletionStatus _completionStatus;

    Protocol *_protocol;
};

#endif // EXPERIMENT_H
