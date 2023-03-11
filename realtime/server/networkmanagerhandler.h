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

#ifndef NETWORKMANAGERHANDLER_H
#define NETWORKMANAGERHANDLER_H

#include "jsonhandler.h"
#include "networkinterfaces.h"


class NetworkManagerHandler : public JsonHandler
{
public:
    enum OperationType
    {
        //General operations
        GetStat,
        SetSettings,

        //Wifi
        WifiScan,
        WifiConnect,
        WifiDisconnect,

        // Hotspot
        HotspotSelect, 
        WifiSelect, 
        HotspotActivate, 
        HotspotDeactivate
    };

    NetworkManagerHandler(const std::string &interfaceName, OperationType type);
    NetworkInterfaces::InterfaceSettings& hotspotSettings();

protected:
    void processData(const boost::property_tree::ptree &requestPt, boost::property_tree::ptree &responsePt);

private:
    void getStat(boost::property_tree::ptree &responsePt);
    void setSettings(const boost::property_tree::ptree &requestPt);
    void setHotspotSettings(const boost::property_tree::ptree &requestPt);
    
    void wifiScan(boost::property_tree::ptree &responsePt);
    void wifiConnect();
    void wifiDisconnect();

    void hotspotSelect();
    void wifiSelect();
    bool hotspotActivate();
    void hotspotDeactivate();


private:
    std::string _interfaceName;
    OperationType _type;
};

#endif // NETWORKMANAGERHANDLER_H
