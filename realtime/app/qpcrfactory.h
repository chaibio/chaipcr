#ifndef QPCRFACTORY_H
#define QPCRFACTORY_H

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
    static std::shared_ptr<IControl> constructOptics(std::shared_ptr<SPIPort> ledSPIPort);
    static std::shared_ptr<IControl> constructHeatBlock(std::vector<std::shared_ptr<ADCConsumer>> &consumers);
    static std::shared_ptr<IControl> constructLid(std::shared_ptr<ADCConsumer> &consumer);
    static std::shared_ptr<IControl> constructHeatSink();

    static void setupMachine();
};


#endif // QPCRFACTORY_H
