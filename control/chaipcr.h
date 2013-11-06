#ifndef _CHAIPCR_H_
#define _CHAIPCR_H_

class CSPIPort;

////////////////////////////////////////////////////////////////////////////////
// Class CChaiPCR
class CChaiPCR {
public:
	CChaiPCR();
	~CChaiPCR();
	PCRSTATUS init();
	
private:
	//ports
	CSPIPort* iSPIPort0;
};

#endif