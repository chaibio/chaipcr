#ifndef QPCRFACTORY_H
#define QPCRFACTORY_H

class IControl;
class SPIPort;
class ADCConsumer;

// Class QPCRFactory
class QPCRFactory {
public:
    static std::vector<std::shared_ptr<IControl>> constructMachine();

private:
    static std::shared_ptr<IControl> constructOptics(std::shared_ptr<SPIPort> ledSPIPort);
    static std::shared_ptr<IControl> constructHeatBlock(std::vector<std::shared_ptr<ADCConsumer>> &consumers);
    static std::shared_ptr<IControl> constructLid(std::vector<std::shared_ptr<ADCConsumer>> &consumers);
};


#endif // QPCRFACTORY_H
