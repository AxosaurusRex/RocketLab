#pragma once

#include <memory>
#include <string>
#include <vector>

#include "Sdk.h"
#include "rocketlab/EventCounter.h"

namespace rocketlab {

// Diagnostic: checks which candidate game events actually fire.
// Hook names are not declared by the SDK, so only the game can confirm them.
class HookProbe {
public:
    explicit HookProbe(std::shared_ptr<GameWrapper> game);
    ~HookProbe();
    HookProbe(const HookProbe&) = delete;
    HookProbe& operator=(const HookProbe&) = delete;

    bool running() const { return running_; }
    void start();
    void stop();
    std::vector<std::string> report() const { return counter_.report(); }
    bool writeReport(const std::filesystem::path& file) const;

private:
    std::shared_ptr<GameWrapper> game_;
    EventCounter counter_;
    bool running_ = false;
};

}  // namespace rocketlab
