#pragma once

#include <memory>
#include <string>

#include "Sdk.h"
#include "HookProbe.h"

// Phase 2, batch A: load, commands, read-only game state, hook diagnostics.
// Nothing here changes the game.
class RocketLabPlugin : public BakkesMod::Plugin::BakkesModPlugin {
public:
    void onLoad() override;
    void onUnload() override;

private:
    void log(const std::string& message);
    void registerCommands();
    void printStatus();
    void stopProbe();

    std::unique_ptr<rocketlab::HookProbe> probe_;
    std::shared_ptr<bool> overlayEnabled_;
};
