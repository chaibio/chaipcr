#include "pcrincludes.h"
#include "boostincludes.h"

#include "protocol.h"
#include "experiment.h"

Experiment::Experiment()
{
    _qpcr = true;
    _runAt = boost::posix_time::not_a_date_time;
    _protocol = nullptr;
}

Experiment::Experiment(const Experiment &other)
{
    setName(other.name());
    setQpcr(other.qpcr());
    setRunAt(other.runAt());
    setProtocol(*other.protocol());
}

Experiment::Experiment(Experiment &&other)
{
    _name = std::move(other._name);
    _qpcr = other._qpcr;
    _runAt = other._runAt;

    if (_protocol)
        delete _protocol;

    _protocol = other._protocol;

    other._qpcr = true;
    other._runAt = boost::posix_time::not_a_date_time;
    other._protocol = nullptr;
}

Experiment::~Experiment()
{
    delete _protocol;
}

Experiment& Experiment::operator= (const Experiment &other)
{
    setName(other.name());
    setQpcr(other.qpcr());
    setRunAt(other.runAt());
    setProtocol(*other.protocol());

    return *this;
}

Experiment& Experiment::operator= (Experiment &&other)
{
    _name = std::move(other._name);
    _qpcr = other._qpcr;
    _runAt = other._runAt;

    if (_protocol)
        delete _protocol;

    _protocol = other._protocol;

    other._qpcr = true;
    other._runAt = boost::posix_time::not_a_date_time;
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
        *_protocol = protocol;
    else
        _protocol = new Protocol(protocol);
}

void Experiment::setProtocol(Protocol *protocol)
{
    if (_protocol)
        delete _protocol;

    _protocol = protocol;
}
