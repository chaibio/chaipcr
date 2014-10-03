#include <cmath>

#include "filters.h"

////////////////////////////////////////////////////////////////////
// Namespace Filters
double Filters::CutoffFrequencyForTimeConstant(double timeConstant) {
    return (1.0 / (2 * M_PI * timeConstant));
}

////////////////////////////////////////////////////////////////////
// Class SinglePoleRecursiveFilter
SinglePoleRecursiveFilter::SinglePoleRecursiveFilter(double a0, double b1):
    _a0 {a0},
    _b1 {b1},
    _z1 {0} {}
//------------------------------------------------------------------------------
SinglePoleRecursiveFilter::SinglePoleRecursiveFilter(double cutoffFrequency):
    _z1 {0} {

    _b1 = exp(-2.0 * M_PI * cutoffFrequency);
    _a0 = 1.0 - _b1;
}
