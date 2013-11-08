#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

class HeatBlockZoneController;

////////////////////////////////////////////////////////////////////////////////
// Class HeatBlock
class HeatBlock {
public:
	HeatBlock() throw();
	~HeatBlock();
	
	void process() throw();
	
private:
	HeatBlockZoneController* zoneController_;
};

#endif