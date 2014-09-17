#ifndef SETTINGS_H
#define SETTINGS_H

#include <atomic>

class Settings
{
public:
    Settings()
    {
        _debugMode = false;
    }

    inline void setDebugMode(bool mode) { _debugMode = mode; }
    inline bool debugMode() const { return _debugMode; }

private:
    std::atomic<bool> _debugMode;
};

#endif // SETTINGS_H
