#ifndef QPCRFACTORY_H
#define QPCRFACTORY_H

#include "adccontroller.h"

class IControl;
class IThreadControl;
class SPIPort;
class ADCConsumer;

#include <memory>
#include <vector>

// Class QPCRFactory
class QPCRFactory {
public:
    static void constructMachine(std::vector<std::shared_ptr<IControl>> &controls, std::vector<std::shared_ptr<IThreadControl>> &threadControls);

private:
    static std::shared_ptr<IControl> constructOptics(std::shared_ptr<SPIPort> ledSPIPort, ADCController::ConsumersList &consumers);
    static std::shared_ptr<IControl> constructHeatBlock(ADCController::ConsumersList &consumers);
    static std::shared_ptr<IControl> constructLid(ADCController::ConsumersList &consumers);
    static std::shared_ptr<IControl> constructHeatSink();

    static void setupMachine();
};


#endif // QPCRFACTORY_H
