#include "updateuploadhandler.h"
#include "qpcrapplication.h"
#include "updatemanager.h"

#include <Poco/Net/MultipartReader.h>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

UpdateUploadHandler::UpdateUploadHandler()
{

}

void UpdateUploadHandler::processRequest(Poco::Net::HTTPServerRequest &request)
{
    std::istream &stream = request.stream();
    Poco::Net::MultipartReader reader(stream);

    if (reader.hasNextPart())
    {
        Poco::Net::MessageHeader message;
        reader.nextPart(message);

        qpcrApp.updateManager()->upload(reader.stream());
        qpcrApp.updateManager()->update();
    }
}

void UpdateUploadHandler::processResponse(Poco::Net::HTTPServerResponse &response)
{
    boost::property_tree::ptree ptree;

    switch (qpcrApp.updateManager()->updateState())
    {
    case UpdateManager::Unavailable:
        ptree.put("device.update_available", "unavailable");
        break;

    case UpdateManager::Available:
        ptree.put("device.update_available", "available");
        break;

    case UpdateManager::Downloading:
    case UpdateManager::ManualDownloading:
        ptree.put("device.update_available", "downloading");
        break;

    case UpdateManager::Updating:
        ptree.put("device.update_available", "updating");
        break;

    default:
        ptree.put("device.update_available", "unknown");
        break;
    }

    std::ostream &stream = response.send();
    boost::property_tree::write_json(stream, ptree);
    stream.flush();
}
