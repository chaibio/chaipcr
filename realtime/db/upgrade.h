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

#ifndef UPGRADE_H
#define UPGRADE_H

#include <string>
#include <ctime>

#include <boost/date_time/posix_time/ptime.hpp>

class Upgrade
{
public:
    Upgrade(): _releaseDate(boost::posix_time::not_a_date_time) {}

    inline void setVersion(const std::string &version) { _version = version; }
    inline const std::string& version() const { return _version; }

    inline void setChecksum(const std::string &checksum) { _checksum = checksum; }
    inline const std::string& checksum() const { return _checksum; }

    inline void setReleaseDate(const boost::posix_time::ptime &releaseDate) { _releaseDate = releaseDate; }
    inline const boost::posix_time::ptime& releaseDate() const { return _releaseDate; }

    inline void setBriedDescription(const std::string &briefDescription) { _briefDescription = briefDescription; }
    inline const std::string& briefDescription() const { return _briefDescription; }

    inline void setFullDescription(const std::string &fullDescription) { _fullDescription = fullDescription; }
    inline const std::string& fullDescription() const { return _fullDescription; }

    inline void setPassword(const std::string &password) { _password = password; }
    inline const std::string& password() const { return _password; }

    inline void setImageUrl(const std::string &imageUrl) { _imageUrl = imageUrl; }
    inline const std::string& imageUrl() const { return _imageUrl; }

private:
    std::string _version;
    std::string _checksum;
    boost::posix_time::ptime _releaseDate;
    std::string _briefDescription;
    std::string _fullDescription;
    std::string _password;

    std::string _imageUrl;
};

#endif // UPGRADE_H
