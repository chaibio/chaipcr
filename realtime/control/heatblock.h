#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

class HeatBlockZoneController;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
class HeatBlock {
public:
    HeatBlock();
	~HeatBlock();
	
    void process();
	
private:
	HeatBlockZoneController* zoneController_;
};

#endif
