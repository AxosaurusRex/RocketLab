#include <cmath>
#include <cstdio>
#include <string>

#include "rocketlab/EventCounter.h"
#include "rocketlab/GameStatus.h"

namespace {

int failures = 0;
int checks = 0;

void check(bool ok, const char* label) {
    ++checks;
    if (!ok) {
        ++failures;
        std::printf("FAIL %s\n", label);
    }
}

}  // namespace

int main() {
    using namespace rocketlab;

    check(classifyMode({}) == GameMode::Other, "no flags is other");
    check(classifyMode({false, false, false, true}) == GameMode::FreePlay, "free play");
    check(classifyMode({true, false, false, true}) == GameMode::Online, "online beats free play");
    check(classifyMode({false, true, false, true}) == GameMode::Replay, "replay beats free play");
    check(classifyMode({false, false, true, false}) == GameMode::CustomTraining, "custom training");
    check(std::string(modeName(GameMode::FreePlay)) == "freeplay", "protocol mode name");

    check(std::fabs(uuPerSecToKph(2300.0f) - 82.8f) < 0.001f, "2300 uu/s is 82.8 km/h");
    check(std::fabs(vectorLength(3, 4, 12) - 13.0f) < 0.001f, "vector length");

    GameStatus status;
    auto lines = describe(status);
    check(lines.size() == 3 && lines[1] == "car: not available" && lines[2] == "ball: not available",
          "missing car and ball are reported, not invented");

    status.mode = GameMode::FreePlay;
    status.car = CarState{17.0f, 2300.0f, 1.0f, true, false, true};
    status.ball = BallState{93.0f, 0.0f};
    lines = describe(status);
    check(lines.size() == 4, "full status has four lines");
    check(lines[1] == "car: height 17 uu, speed 82.8 km/h, boost 100", "car numbers");
    check(lines[2] == "car: on ground yes, on wall no, flip available yes", "car flags");
    check(lines[3] == "ball: height 93 uu, speed 0.0 km/h", "ball numbers");

    EventCounter counter({"a", "b"});
    counter.record(1);
    counter.record(1);
    counter.record(99);  // ignored
    check(counter.count(0) == 0 && counter.count(1) == 2, "counting");
    check(counter.report().size() == 2 && counter.report()[1] == "2  b", "report format");
    counter.reset();
    check(counter.count(1) == 0, "reset");

    std::printf("%d checks, %d failed\n", checks, failures);
    return failures == 0 ? 0 : 1;
}
