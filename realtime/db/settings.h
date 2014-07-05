#ifndef SETTINGS_H
#define SETTINGS_H

class Settings
{
public:
    Settings();

    inline void setDebuMode(bool mode) { _debugMode = mode; }
    inline bool debugMode() const { return _debugMode; }

private:
    std::atomic<bool> _debugMode;
};

#endif // SETTINGS_H
