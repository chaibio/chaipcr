#ifndef ICONTROL_H
#define ICONTROL_H

class IControl
{
public:
    virtual void process() = 0;
    virtual ~IControl() {}
};

#endif // ICONTROL_H
