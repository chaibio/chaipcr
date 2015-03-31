#ifndef CSVCONTROL_H
#define CSVCONTROL_H

#include "icontrol.h"
#include "optics.h"

#include <string>
#include <vector>
#include <utility>

class Experiment;

class CSVControl : private IThreadControl
{
public:
    CSVControl();
    ~CSVControl();

    void writeMeltCurveData(const Experiment &experiment, std::vector<Optics::MeltCurveData> &&data);

private:
    void process();
    void stop();

private:
    std::atomic<bool> _writeThreadState;
    std::condition_variable _writeCondition;

    std::vector<std::pair<std::string, std::vector<Optics::MeltCurveData>>> _meltCurveData;
    std::mutex _meltCurveMutex;
};

#endif // CSVCONTROL_H
