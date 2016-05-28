//
// Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
// For more information visit http://www.chaibio.com
//
// Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
    try
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
    catch (const std::exception &ex)
    {
        setStatus(Poco::Net::HTTPResponse::HTTP_PRECONDITION_FAILED);

        _errorMessage = ex.what();
    }
}

void UpdateUploadHandler::processResponse(Poco::Net::HTTPServerResponse &response)
{
    boost::property_tree::ptree ptree;

    if (getStatus() == Poco::Net::HTTPResponse::HTTP_OK)
    {
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
    }
    else
    {
        ptree.put("status.status", false);
        ptree.put("status.error", _errorMessage);
    }

    std::ostream &stream = response.send();
    boost::property_tree::write_json(stream, ptree);
    stream.flush();
}
