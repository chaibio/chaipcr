#ifndef ICONTROL_H
#define ICONTROL_H

class IControl
{
public:
    virtual ~IControl() {}

    virtual void process() = 0;
};

#endif // ICONTROL_H
