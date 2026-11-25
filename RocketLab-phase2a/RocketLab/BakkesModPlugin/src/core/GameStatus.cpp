#include "rocketlab/GameStatus.h"

#include <cmath>
#include <cstdio>

namespace rocketlab {

GameMode classifyMode(const ModeFlags& flags) {
    if (flags.online) return GameMode::Online;
    if (flags.replay) return GameMode::Replay;
    if (flags.customTraining) return GameMode::CustomTraining;
    if (flags.freePlay) return GameMode::FreePlay;
    return GameMode::Other;
}

const char* modeName(GameMode mode) {
    switch (mode) {
        case GameMode::Online: return "online";
        case GameMode::Replay: return "replay";
        case GameMode::CustomTraining: return "custom_training";
        case GameMode::FreePlay: return "freeplay";
        case GameMode::Other: return "other";
    }
    return "other";
}

float uuPerSecToKph(float uuPerSec) { return uuPerSec * 0.036f; }

float vectorLength(float x, float y, float z) { return std::sqrt(x * x + y * y + z * z); }

std::vector<std::string> describe(const GameStatus& status) {
    std::vector<std::string> lines{std::string("mode: ") + modeName(status.mode)};
    char text[200];

    if (status.car) {
        const CarState& car = *status.car;
        std::snprintf(text, sizeof text, "car: height %.0f uu, speed %.1f km/h, boost %.0f",
                      car.heightUu, uuPerSecToKph(car.speedUuPerSec), car.boostFraction * 100.0f);
        lines.emplace_back(text);
        std::snprintf(text, sizeof text, "car: on ground %s, on wall %s, flip available %s",
                      car.onGround ? "yes" : "no", car.onWall ? "yes" : "no",
                      car.hasFlip ? "yes" : "no");
        lines.emplace_back(text);
    } else {
        lines.emplace_back("car: not available");
    }

    if (status.ball) {
        std::snprintf(text, sizeof text, "ball: height %.0f uu, speed %.1f km/h",
                      status.ball->heightUu, uuPerSecToKph(status.ball->speedUuPerSec));
        lines.emplace_back(text);
    } else {
        lines.emplace_back("ball: not available");
    }
    return lines;
}

}  // namespace rocketlab
