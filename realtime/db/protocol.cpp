#include "pcrincludes.h"
#include "pocoincludes.h"

#include "stage.h"
#include "protocol.h"

Protocol::Protocol()
{
    _lidTemperature = 0;
}

Protocol::Protocol(const Protocol &other)
{
    setLidTemperature(other.lidTemperature());
    setStages(other.stages());
}

Protocol::Protocol(Protocol &&other)
{
    _lidTemperature = other._lidTemperature;
    _stages = std::move(other._stages);

    other._lidTemperature = 0;
}

Protocol::~Protocol()
{

}

Protocol& Protocol::operator= (const Protocol &other)
{
    setLidTemperature(other.lidTemperature());
    setStages(other.stages());

    return *this;
}

Protocol& Protocol::operator= (Protocol &&other)
{
    _lidTemperature = other._lidTemperature;
    _stages = std::move(other._stages);

    other._lidTemperature = 0;

    return *this;
}

void Protocol::setStages(const std::vector<Stage> &stages)
{
    _stages = stages;
}

void Protocol::setStages(std::vector<Stage> &&stages)
{
    _stages = stages;
}

void Protocol::appendStage(const Stage &stage)
{
    _stages.push_back(stage);
}

void Protocol::appendStage(Stage &&stage)
{
    _stages.push_back(stage);
}
