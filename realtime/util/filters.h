/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _FILTERS_H
#define _FILTERS_H

#include <cmath>

////////////////////////////////////////////////////////////////////
// Namespace Filters
namespace Filters {
    double CutoffFrequencyForTimeConstant(double timeConstant);
}

////////////////////////////////////////////////////////////////////
// Class SinglePoleRecursiveFilter
class SinglePoleRecursiveFilter {
public:
    SinglePoleRecursiveFilter(double a0, double b1);
    SinglePoleRecursiveFilter(double cutoffFrequency);

    double filterValue() const { return _z1; }
    inline double processSample(double sampleValue) { return _z1 = sampleValue * _a0 + _z1 * _b1; }

private:
    double _a0, _b1, _z1;
};

#endif // _FILTERS_H
