#pragma once

#include "Sdk.h"
#include "rocketlab/GameStatus.h"

namespace rocketlab {

// Read-only. Call from the game thread.
// Car and ball are read only in offline Free Play.
GameStatus readGameStatus(GameWrapper& game);

}  // namespace rocketlab
