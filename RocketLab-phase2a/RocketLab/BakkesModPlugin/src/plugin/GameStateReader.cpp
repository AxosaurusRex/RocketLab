#include "GameStateReader.h"

namespace rocketlab {

GameStatus readGameStatus(GameWrapper& game) {
    ModeFlags flags;
    flags.online = game.IsInOnlineGame();
    flags.replay = game.IsInReplay();
    flags.customTraining = game.IsInCustomTraining();
    flags.freePlay = game.IsInFreeplay();

    GameStatus status;
    status.mode = classifyMode(flags);
    if (status.mode != GameMode::FreePlay) return status;

    // Wrappers can be null while a map loads, so each one is checked before use.
    CarWrapper car = game.GetLocalCar();
    if (car) {
        CarState state;
        const Vector location = car.GetLocation();
        const Vector velocity = car.GetVelocity();
        state.heightUu = location.Z;
        state.speedUuPerSec = vectorLength(velocity.X, velocity.Y, velocity.Z);
        BoostWrapper boost = car.GetBoostComponent();
        if (boost) state.boostFraction = boost.GetCurrentBoostAmount();
        state.onGround = car.IsOnGround();
        state.onWall = car.IsOnWall();
        state.hasFlip = car.HasFlip() != 0;
        status.car = state;
    }

    ServerWrapper server = game.GetCurrentGameState();
    if (server) {
        BallWrapper ball = server.GetBall();
        if (ball) {
            BallState state;
            const Vector location = ball.GetLocation();
            const Vector velocity = ball.GetVelocity();
            state.heightUu = location.Z;
            state.speedUuPerSec = vectorLength(velocity.X, velocity.Y, velocity.Z);
            status.ball = state;
        }
    }
    return status;
}

}  // namespace rocketlab
