/*#include "pcrincludes.h"
#include "statushandler.h"

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include "qpcrcycler.h"
#include "optics.h"

using namespace Poco::Net;
using namespace boost::property_tree;*/

#include "statushandler.h"

using namespace Poco::Net;

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
StatusHandler::StatusHandler(HTTPResponse::HTTPStatus status)
{
    setStatus(status);
}

StatusHandler::~StatusHandler()
{

}

void StatusHandler::handleRequest(HTTPServerRequest &, HTTPServerResponse &response)
{
    response.setStatus(getStatus());
}
