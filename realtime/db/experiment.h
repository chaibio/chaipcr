#ifndef EXPERIMENT_H
#define EXPERIMENT_H

class Protocol;

class Experiment
{
public:
    Experiment();
    Experiment(const Experiment &other);
    Experiment(Experiment &&other);
    ~Experiment();

    Experiment& operator= (const Experiment &other);
    Experiment& operator= (Experiment &&other);

    inline void setName(const std::string &name) {_name = name;}
    inline void setName(std::string &&name) {_name = name;}
    inline const std::string name() const {return _name;}

    inline void setQpcr(bool qpcr) {_qpcr = qpcr;}
    inline bool qpcr() const {return _qpcr;}

    inline void setRunAt(const Poco::Timestamp &runAt) {_runAt = runAt;}
    inline const Poco::Timestamp runAt() const {return _runAt;}

    void setProtocol(const Protocol &protocol);
    void setProtocol(Protocol &&protocol);
    void setProtocol(Protocol *protocol);
    inline Protocol* protocol() const {return _protocol;}

private:
    std::string _name;
    bool _qpcr;
    Poco::Timestamp _runAt;

    Protocol *_protocol;
};

#endif // EXPERIMENT_H
