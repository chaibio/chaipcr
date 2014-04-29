#ifndef BOOSTINCLUDES_H
#define BOOSTINCLUDES_H

#pragma GCC diagnostic ignored "-Wunused-local-typedefs"
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-but-set-parameter"

#include <boost/property_tree/json_parser.hpp>
#include <boost/property_tree/ptree.hpp>

#include <boost/date_time/posix_time/posix_time.hpp>

#include <boost/signals2.hpp>
#include <boost/bind.hpp>

#pragma GCC diagnostic pop


inline std::string ptime_to_string(const boost::posix_time::ptime &date_time)
{
    if (date_time.is_not_a_date_time())
        return std::string();

    std::stringstream stream;
    stream << date_time.date().year() << "-" << date_time.date().month() << "-" << date_time.date().day() << " "
           << date_time.time_of_day().hours() << ":" << date_time.time_of_day().minutes() << ":" << date_time.time_of_day().seconds();

    return stream.str();
}

#endif // BOOSTINCLUDES_H
