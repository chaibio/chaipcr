#include "pcrincludes.h"
#include "StatusHandler.h"

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include "qpcrcycler.h"
#include "optics.h"

using namespace Poco::Net;
using namespace boost::property_tree;

////////////////////////////////////////////////////////////////////////////////
// Class StatusHandler
void StatusHandler::handleRequest(HTTPServerRequest &request, HTTPServerResponse &response) {
    response.setStatus(HTTPResponse::HTTP_OK);
    response.setContentType("text/html");

    ptree pt;
    pt.put("lidOpen", QPCRCycler::instance()->optics().lidOpen());

    std::ostream& out = response.send();
    write_json(out, pt, false);
    out.flush();
}
