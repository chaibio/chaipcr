#ifndef QPCRFACTORY_H
#define QPCRFACTORY_H

class IControl;

// Class QPCRFactory
class QPCRFactory {
public:
    static void constructMachine(std::vector<std::shared_ptr<IControl>>& controlUnits);
};


#endif // QPCRFACTORY_H
