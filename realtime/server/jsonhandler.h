/* * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef JSONHANDLER_H
#define JSONHANDLER_H

#include "datahandler.h"

#include <boost/property_tree/ptree.hpp>

class JsonHandler : public DataHandler
{
public:
    JsonHandler();
    JsonHandler(Poco::Net::HTTPResponse::HTTPStatus status, const std::string &errorMessage);

    inline const std::string& getErrorString() const { return _errorString; }
    inline void setErrorString(const std::string &text) { _errorString = text; }

protected:
    void processRequest(Poco::Net::HTTPServerRequest &request) final;
    void processResponse(Poco::Net::HTTPServerResponse &response) final;

    virtual void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    boost::property_tree::ptree _responsePt;

    std::string _errorString;
};

#endif // JSONHANDLER_H
