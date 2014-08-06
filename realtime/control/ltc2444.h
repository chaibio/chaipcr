#ifndef _LTC2444_H_
#define _LTC2444_H_

#include "spi.h"
#include "gpio.h"

// Class LTC2444
class LTC2444  // will work with this class later
{
public:
    LTC2444(unsigned int csPinNumber, SPIPort spiPort, unsigned int busyPinNumber);
	~LTC2444();

	/*Setup the speed and resolution
	 * mode:
	 * 0 -> No changes from previous setting
	 * 1 -> OSR = 0001
	 * 2 -> OSR = 0010
	 * ...
	 * 9 -> OSR = 1001
	 * 10-> OSR = 1111
	 *
	 * TWOx = true  -> 2x speed
	 * TWOx = false ->1x speed
	 */
	void setup(char mode, bool TWOx);

    uint32_t readSingleEndedChannel(uint8_t channel);
    uint32_t readDifferentialChannels(uint8_t lowerChannel, bool lowerChannelPositive);

    /*readADC- Reads result of conversion and convert again using specified channel.
     * single ended conversion (SGL= true)
     * ch: ADC channel (0-7)
     *
     * differential conversion (SGL= false)
     * ch- (IN+,IN-)
     * 0 - ( 0, 1)
     * 1 - ( 1, 0)
     * 2 - ( 2, 3)
     * 3 - ( 3, 2)
     * 4 - ( 4, 5)
     * 5 - ( 5, 4)
     * 6 - ( 6, 7)
     * 7 - ( 7, 6)
     *
     */
    uint32_t readADC(uint8_t ch, bool SGL, bool lowerChannelPositive = false);

	//read result of conversion and convert again using previous setting.
	uint32_t repeat();

	bool busy();

private:
	GPIO csPin_;
    SPIPort spiPort_;
	GPIO busyPin_;
	uint8_t OSRTWOx;
};




#endif
