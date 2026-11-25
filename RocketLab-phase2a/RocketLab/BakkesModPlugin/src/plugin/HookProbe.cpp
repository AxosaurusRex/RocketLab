#include "HookProbe.h"

#include <fstream>
#include <system_error>
#include <utility>

namespace rocketlab {

namespace {

std::vector<std::string> candidateEvents() {
    return {
        "Function TAGame.Car_TA.OnHitBall",
        "Function TAGame.Ball_TA.OnHitGoal",
        "Function TAGame.Ball_TA.Explode",
        "Function TAGame.Car_TA.SetVehicleInput",
    };
}

}  // namespace

HookProbe::HookProbe(std::shared_ptr<GameWrapper> game)
    : game_(std::move(game)), counter_(candidateEvents()) {}

HookProbe::~HookProbe() { stop(); }

void HookProbe::start() {
    if (running_) return;
    counter_.reset();
    for (std::size_t i = 0; i < counter_.size(); ++i) {
        game_->HookEvent(counter_.name(i), [this, i](std::string) { counter_.record(i); });
    }
    running_ = true;
}

void HookProbe::stop() {
    if (!running_) return;
    for (std::size_t i = 0; i < counter_.size(); ++i) {
        game_->UnhookEvent(counter_.name(i));
    }
    running_ = false;
}

// Writes a few lines on the game thread. Acceptable only because the user asks
// for it explicitly with a diagnostic command.
bool HookProbe::writeReport(const std::filesystem::path& file) const {
    std::error_code error;
    std::filesystem::create_directories(file.parent_path(), error);
    if (error) return false;

    std::ofstream out(file, std::ios::trunc);
    for (const std::string& line : counter_.report()) out << line << '\n';
    out.flush();
    return out.good();
}

}  // namespace rocketlab
