#ifndef _HEATBLOCK_H_
#define _HEATBLOCK_H_

class HeatBlockZoneController;

// Class HeatBlock
class HeatBlock : public IControl
{
public:
    HeatBlock();
	~HeatBlock();
	
    void process();
	
private:
    boost::shared_ptr<HeatBlockZoneController> zoneController_;
};

#endif
