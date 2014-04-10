#ifndef QPCRFACTORY_H
#define QPCRFACTORY_H

class IControl;
class SPIPort;

// Class QPCRFactory
class QPCRFactory {
public:
    static std::vector<std::shared_ptr<IControl>> constructMachine();

private:
    static std::shared_ptr<IControl> constructOptics(std::shared_ptr<SPIPort> ledSPIPort);
};


#endif // QPCRFACTORY_H
