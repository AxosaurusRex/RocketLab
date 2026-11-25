#pragma once

#include <optional>
#include <string>
#include <vector>

namespace rocketlab {

// Matches the "status" modes in Shared/Protocol/message.schema.json.
// "menu" is not detected separately yet; it is reported as Other.
enum class GameMode { Online, Replay, CustomTraining, FreePlay, Other };

struct ModeFlags {
    bool online = false;
    bool replay = false;
    bool customTraining = false;
    bool freePlay = false;
};

// Online wins over every other flag, so unsafe states are never treated as Free Play.
GameMode classifyMode(const ModeFlags& flags);
const char* modeName(GameMode mode);

struct CarState {
    float heightUu = 0;
    float speedUuPerSec = 0;
    float boostFraction = 0;  // 0 to 1
    bool onGround = false;
    bool onWall = false;
    bool hasFlip = false;
};

struct BallState {
    float heightUu = 0;
    float speedUuPerSec = 0;
};

struct GameStatus {
    GameMode mode = GameMode::Other;
    std::optional<CarState> car;
    std::optional<BallState> ball;
};

// Unreal units are centimetres.
float uuPerSecToKph(float uuPerSec);
float vectorLength(float x, float y, float z);

std::vector<std::string> describe(const GameStatus& status);

}  // namespace rocketlab
