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

#ifndef DATAHANDLER_H
#define DATAHANDLER_H

#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>

class DataHandler : public Poco::Net::HTTPRequestHandler
{
public:
    DataHandler();
    DataHandler(Poco::Net::HTTPResponse::HTTPStatus status);

    void handleRequest(Poco::Net::HTTPServerRequest &request, Poco::Net::HTTPServerResponse &response) final;

    inline Poco::Net::HTTPResponse::HTTPStatus getStatus() const { return _status; }
    inline void setStatus(Poco::Net::HTTPResponse::HTTPStatus status) { _status = status; }

protected:
    virtual void processRequest(Poco::Net::HTTPServerRequest &request) = 0;
    virtual void processResponse(Poco::Net::HTTPServerResponse &response);

private:
    Poco::Net::HTTPResponse::HTTPStatus _status;
};

#endif // DATAHANDLER_H
