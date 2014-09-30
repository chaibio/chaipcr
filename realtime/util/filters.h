#ifndef _FILTERS_H
#define _FILTERS_H

#include <cmath>

////////////////////////////////////////////////////////////////////
// Namespace Filters
namespace Filters {
    double CutoffFrequencyForTimeConstant(double timeConstant);
};

////////////////////////////////////////////////////////////////////
// Class SinglePoleRecursiveFilter
class SinglePoleRecursiveFilter {
public:
    SinglePoleRecursiveFilter(double a0, double b1);
    SinglePoleRecursiveFilter(double cutoffFrequency);

    double filterValue() const { return _z1; }
    double processSample(double sampleValue);

private:
    double _a0, _b1, _z1;
};

#endif // _FILTERS_H
