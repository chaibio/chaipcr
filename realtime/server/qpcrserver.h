#ifndef _QPCRSERVER_H_
#define _QPCRSERVER_H_

#include <Poco/Util/ServerApplication.h>
#include <vector>

using namespace std;

class QPCRServer;

////////////////////////////////////////////////////////////////////////////////
// Class QPCRServer
class QPCRServer: public Poco::Util::ServerApplication {
protected:
	//from ServerApplication
	void initialize(Application& self);
	int main(const vector<string>& args);

private:

};

#endif
