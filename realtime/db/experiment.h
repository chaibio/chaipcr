#ifndef EXPERIMENT_H
#define EXPERIMENT_H

class Step;

class Ramp
{
public:
    Ramp()
    {
        rate = 0;
    }

    Ramp(const Ramp &other)
    {
        rate = other.rate;
    }

    Ramp(Ramp &&other)
    {
        rate = other.rate;
        other.rate = 0;
    }

    ~Ramp()
    {

    }

    Ramp& operator= (const Ramp &other)
    {
        rate = other.rate;

        return *this;
    }

    Ramp& operator= (Ramp &&other)
    {
        rate = other.rate;
        other.rate = 0;

        return *this;
    }


    double rate;
};

class Step
{
public:
    Step()
    {
        temperature = 0;
        hold_time = 0;
        order_number = 0;
        ramp = 0;
    }

    Step(const Step &other)
    {
        name = other.name;
        temperature = other.temperature;
        hold_time = other.hold_time;
        order_number = other.order_number;

        if (ramp)
            *ramp = *other.ramp;
        else
            ramp = new Ramp(*other.ramp);
    }

    Step(Step &&other)
    {
        name = std::move(other.name);
        temperature = other.temperature;
        hold_time = other.hold_time;
        order_number = other.order_number;

        if (ramp)
            delete ramp;

        ramp = other.ramp;

        other.temperature = 0;
        other.hold_time = 0;
        other.order_number = 0;
        other.ramp = 0;
    }

    ~Step()
    {
        delete ramp;
    }

    Step& operator= (const Step &other)
    {
        name = other.name;
        temperature = other.temperature;
        hold_time = other.hold_time;
        order_number = other.order_number;

        if (ramp)
            *ramp = *other.ramp;
        else
            ramp = new Ramp(*other.ramp);

        return *this;
    }

    Step& operator= (Step &&other)
    {
        name = std::move(other.name);
        temperature = other.temperature;
        hold_time = other.hold_time;
        order_number = other.order_number;

        if (ramp)
            delete ramp;

        ramp = other.ramp;

        other.temperature = 0;
        other.hold_time = 0;
        other.order_number = 0;
        other.ramp = 0;

        return *this;
    }

    std::string name;

    double temperature;
    Poco::Timestamp hold_time;
    int order_number;

    Ramp *ramp;
};

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

    Stage()
    {
        num_cycles = 1;
        order_number = 0;
        stage_type = None;
    }

    Stage(const Stage &other)
    {
        name = other.name;
        num_cycles = other.num_cycles;
        order_number = other.order_number;
        stage_type = other.stage_type;
        steps = other.steps;
    }

    Stage(Stage &&other)
    {
        name = std::move(other.name);
        num_cycles = other.num_cycles;
        order_number = other.order_number;
        stage_type = other.stage_type;
        steps = std::move(other.steps);

        other.num_cycles = 0;
        other.order_number = 0;
        other.stage_type = None;
    }

    ~Stage()
    {

    }

    Stage& operator= (const Stage &other)
    {
        name = other.name;
        num_cycles = other.num_cycles;
        order_number = other.order_number;
        stage_type = other.stage_type;
        steps = other.steps;

        return *this;
    }

    Stage& operator= (Stage &&other)
    {
        name = std::move(other.name);
        num_cycles = other.num_cycles;
        order_number = other.order_number;
        stage_type = other.stage_type;
        steps = std::move(other.steps);

        other.num_cycles = 0;
        other.order_number = 0;
        other.stage_type = None;

        return *this;
    }

    std::string name;

    int num_cycles;
    int order_number;
    Type stage_type;

    std::vector<Step> steps;
};

class Protocol
{
public:
    Protocol()
    {
        lid_temperature = 0;
    }

    Protocol(const Protocol &other)
    {
        lid_temperature = other.lid_temperature;
        stages = other.stages;
    }

    Protocol(Protocol &&other)
    {
        lid_temperature = other.lid_temperature;
        stages = std::move(other.stages);

        other.lid_temperature = 0;
    }

    ~Protocol()
    {

    }

    Protocol& operator= (const Protocol &other)
    {
        lid_temperature = other.lid_temperature;
        stages = other.stages;

        return *this;
    }

    Protocol& operator= (Protocol &&other)
    {
        lid_temperature = other.lid_temperature;
        stages = std::move(other.stages);

        other.lid_temperature = 0;

        return *this;
    }

    double lid_temperature;

    std::vector<Stage> stages;
};

class Experiment
{
public:
    Experiment()
    {
        qpcr = true;
        run_at = 0;
        protocol = 0;
    }

    Experiment(const Experiment &other)
    {
        name = other.name;
        qpcr = other.qpcr;
        run_at = other.run_at;

        if (protocol)
            *protocol = *other.protocol;
        else
            protocol = new Protocol(*other.protocol);
    }

    Experiment(Experiment &&other)
    {
        name = std::move(other.name);
        qpcr = other.qpcr;
        run_at = other.run_at;

        if (protocol)
            delete protocol;

        protocol = other.protocol;

        other.qpcr = true;
        other.run_at = 0;
        other.protocol = 0;
    }

    ~Experiment()
    {
        delete protocol;
    }

    Experiment& operator= (const Experiment &other)
    {
        name = other.name;
        qpcr = other.qpcr;
        run_at = other.run_at;

        if (protocol)
            *protocol = *other.protocol;
        else
            protocol = new Protocol(*other.protocol);

        return *this;
    }

    Experiment& operator= (Experiment &&other)
    {
        name = std::move(other.name);
        qpcr = other.qpcr;
        run_at = other.run_at;

        if (protocol)
            delete protocol;

        protocol = other.protocol;

        other.qpcr = true;
        other.run_at = 0;
        other.protocol = 0;

        return *this;
    }

    std::string name;
    bool qpcr;
    Poco::Timestamp run_at;

    Protocol *protocol;
};

#endif // EXPERIMENT_H
