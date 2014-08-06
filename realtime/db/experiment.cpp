#include "protocol.h"
#include "experiment.h"

Experiment::Experiment(int id)
{
    _id = id;
    _qpcr = true;
    _startedAt = boost::posix_time::not_a_date_time;
    _completedAt = boost::posix_time::not_a_date_time;
    _completionStatus = None;
    _protocol = nullptr;
}

Experiment::Experiment(const Experiment &other)
    :Experiment(other.id())
{
    setName(other.name());
    setQpcr(other.qpcr());
    setStartedAt(other.startedAt());
    setCompletedAt(other.completedAt());
    setCompletionStatus(other.completionStatus());

    if (other.protocol())
        setProtocol(*other.protocol());
}

Experiment::Experiment(Experiment &&other)
    :Experiment(other._id)
{
    _name = std::move(other._name);
    _qpcr = other._qpcr;
    _startedAt = other._startedAt;
    _completedAt = other._completedAt;
    _completionStatus = other._completionStatus;
    _protocol = other._protocol;

    other._id = -1;
    other._qpcr = true;
    other._startedAt = boost::posix_time::not_a_date_time;
    other._completedAt = boost::posix_time::not_a_date_time;
    other._completionStatus = None;
    other._protocol = nullptr;
}

Experiment::~Experiment()
{
    delete _protocol;
}

Experiment& Experiment::operator= (const Experiment &other)
{
    _id = other.id();
    setName(other.name());
    setQpcr(other.qpcr());
    setStartedAt(other.startedAt());
    setCompletedAt(other.completedAt());
    setCompletionStatus(other.completionStatus());

    if (other.protocol())
        setProtocol(*other.protocol());
    else
        setProtocol(nullptr);

    return *this;
}

Experiment& Experiment::operator= (Experiment &&other)
{
    _id = other._id;
    _name = std::move(other._name);
    _qpcr = other._qpcr;
    _startedAt = other._startedAt;
    _completedAt = other._completedAt;
    _completionStatus = other._completionStatus;

    if (_protocol)
        delete _protocol;

    _protocol = other._protocol;

    other._id = -1;
    other._qpcr = true;
    other._startedAt = boost::posix_time::not_a_date_time;
    other._completedAt = boost::posix_time::not_a_date_time;
    other._completionStatus = None;
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
