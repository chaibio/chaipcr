#include "protocol.h"
#include "experiment.h"

Experiment::Experiment()
{
    _definationId = -1;
    _id = -1;
    _type = NoneType;
    _startedAt = boost::posix_time::not_a_date_time;
    _completedAt = boost::posix_time::not_a_date_time;
    _completionStatus = None;
    _estimatedDuration = 0;
    _pausedDuration = 0;
    _lastPauseTime = boost::posix_time::not_a_date_time;
    _protocol = nullptr;
}

Experiment::Experiment(int id, int definationId)
    :Experiment()
{
    _definationId = definationId;
    _id = id;
}

Experiment::Experiment(const Experiment &other)
    :Experiment(other.id(), other.definationId())
{
    setName(other.name());
    setType(other.type());
    setStartedAt(other.startedAt());
    setCompletedAt(other.completedAt());
    setCompletionStatus(other.completionStatus());
    setEstimatedDuration(other.estimatedDuration());
    setPausedDuration(other.pausedDuration());
    setPauseTime(other.lastPauseTime());

    if (other.protocol())
        setProtocol(*other.protocol());
}

Experiment::Experiment(Experiment &&other)
{
    _definationId = other._definationId;
    _id = other._id;
    _name = std::move(other._name);
    _type = other._type;
    _startedAt = other._startedAt;
    _completedAt = other._completedAt;
    _completionStatus = other._completionStatus;
    _completionMessage = std::move(other._completionMessage);
    _estimatedDuration = other._estimatedDuration;
    _pausedDuration = other._pausedDuration;
    _lastPauseTime = other._lastPauseTime;
    _protocol = other._protocol;

    other._definationId = -1;
    other._id = -1;
    other._type = NoneType;
    other._startedAt = boost::posix_time::not_a_date_time;
    other._completedAt = boost::posix_time::not_a_date_time;
    other._completionStatus = None;
    other._estimatedDuration = 0;
    other._pausedDuration = 0;
    other._lastPauseTime = boost::posix_time::not_a_date_time;
    other._protocol = nullptr;
}

Experiment::~Experiment()
{
    delete _protocol;
}

Experiment& Experiment::operator= (const Experiment &other)
{
    setDefinationId(other.definationId());
    setId(other.id());
    setName(other.name());
    setType(other.type());
    setStartedAt(other.startedAt());
    setCompletedAt(other.completedAt());
    setCompletionStatus(other.completionStatus());
    setCompletionMessage(other.completionMessage());
    setEstimatedDuration(other.estimatedDuration());
    setPausedDuration(other.pausedDuration());
    setPauseTime(other.lastPauseTime());

    if (other.protocol())
        setProtocol(*other.protocol());
    else
        setProtocol(nullptr);

    return *this;
}

Experiment& Experiment::operator= (Experiment &&other)
{
    _definationId = other._definationId;
    _id = other._id;
    _name = std::move(other._name);
    _type = other._type;
    _startedAt = other._startedAt;
    _completedAt = other._completedAt;
    _completionMessage = std::move(other._completionMessage);
    _estimatedDuration = other._estimatedDuration;
    _pausedDuration = other._pausedDuration;
    _lastPauseTime = other._lastPauseTime;
    _completionStatus = other._completionStatus;

    if (_protocol)
        delete _protocol;

    _protocol = other._protocol;

    other._definationId = -1;
    other._id = -1;
    other._type = NoneType;
    other._startedAt = boost::posix_time::not_a_date_time;
    other._completedAt = boost::posix_time::not_a_date_time;
    other._completionStatus = None;
    other._estimatedDuration = 0;
    other._pausedDuration = 0;
    other._lastPauseTime = boost::posix_time::not_a_date_time;
    other._protocol = nullptr;

    return *this;
}

void Experiment::setProtocol(const Protocol &protocol)
{
    if (_protocol)
        *_protocol = protocol;
    else
        _protocol = new Protocol(protocol);
}

void Experiment::setProtocol(Protocol &&protocol)
{
    if (_protocol)
        *_protocol = std::move(protocol);
    else
        _protocol = new Protocol(std::move(protocol));
}

void Experiment::setProtocol(Protocol *protocol)
{
    if (_protocol)
        delete _protocol;

    _protocol = protocol;
}
