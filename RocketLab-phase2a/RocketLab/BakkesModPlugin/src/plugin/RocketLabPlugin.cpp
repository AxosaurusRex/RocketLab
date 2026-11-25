#include "RocketLabPlugin.h"

#include <vector>

#include "GameStateReader.h"
#include "StatusOverlay.h"

BAKKESMOD_PLUGIN(RocketLabPlugin, "Rocket Lab", ROCKETLAB_VERSION, PLUGINTYPE_FREEPLAY)

void RocketLabPlugin::onLoad() {
    probe_ = std::make_unique<rocketlab::HookProbe>(gameWrapper);
    overlayEnabled_ = std::make_shared<bool>(false);
    cvarManager->registerCvar("rocketlab_overlay", "0", "Show the Rocket Lab diagnostic overlay",
                              true, true, 0, true, 1)
        .bindTo(overlayEnabled_);
    registerCommands();
    gameWrapper->RegisterDrawable([this](CanvasWrapper canvas) {
        if (*overlayEnabled_) rocketlab::drawStatusOverlay(canvas, *gameWrapper);
    });
    log(std::string("loaded v") + ROCKETLAB_VERSION);
}

void RocketLabPlugin::onUnload() {
    gameWrapper->UnregisterDrawables();
    probe_.reset();  // unhooks if the probe is still running
    log("unloaded");
}

void RocketLabPlugin::log(const std::string& message) { cvarManager->log("[RocketLab] " + message); }

void RocketLabPlugin::registerCommands() {
    cvarManager->registerNotifier(
        "rocketlab_version",
        [this](std::vector<std::string>) { log(std::string("version ") + ROCKETLAB_VERSION); },
        "Print the Rocket Lab version", PERMISSION_ALL);

    cvarManager->registerNotifier(
        "rocketlab_status", [this](std::vector<std::string>) { printStatus(); },
        "Print game mode, car and ball state", PERMISSION_ALL);

    cvarManager->registerNotifier(
        "rocketlab_probe_start",
        [this](std::vector<std::string>) {
            if (gameWrapper->IsInOnlineGame()) {
                log("probe not started: online game");
                return;
            }
            if (probe_->running()) {
                log("probe already running");
                return;
            }
            probe_->start();
            log("probe started; touch the ball and score, then run rocketlab_probe_stop");
        },
        "Start counting candidate game events", PERMISSION_ALL);

    cvarManager->registerNotifier(
        "rocketlab_probe_stop", [this](std::vector<std::string>) { stopProbe(); },
        "Stop the event probe and save its report", PERMISSION_ALL);
}

void RocketLabPlugin::printStatus() {
    for (const std::string& line : rocketlab::describe(rocketlab::readGameStatus(*gameWrapper))) {
        log(line);
    }
}

void RocketLabPlugin::stopProbe() {
    if (!probe_->running()) {
        log("probe is not running");
        return;
    }
    probe_->stop();
    for (const std::string& line : probe_->report()) log(line);

    const std::filesystem::path file = gameWrapper->GetDataFolder() / "rocketlab" / "probe_report.txt";
    if (probe_->writeReport(file)) {
        log("report saved to data\\rocketlab\\probe_report.txt");
    } else {
        log("could not save the report file");
    }
}
