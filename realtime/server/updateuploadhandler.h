#ifndef UPDATEUPLOADHANDLER_H
#define UPDATEUPLOADHANDLER_H

#include "datahandler.h"

class UpdateUploadHandler : public DataHandler
{
public:
    UpdateUploadHandler();

protected:
    void processRequest(Poco::Net::HTTPServerRequest &request);
    void processResponse(Poco::Net::HTTPServerResponse &response);
};

#endif // UPDATEUPLOADHANDLER_H
