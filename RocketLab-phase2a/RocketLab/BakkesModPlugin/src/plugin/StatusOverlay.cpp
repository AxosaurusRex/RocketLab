#include "StatusOverlay.h"

#include "GameStateReader.h"

namespace rocketlab {

void drawStatusOverlay(CanvasWrapper canvas, GameWrapper& game) {
    if (!game.IsInFreeplay() || game.IsInOnlineGame()) return;

    const GameStatus status = readGameStatus(game);
    canvas.SetColor(LinearColor{220, 224, 230, 255});

    int y = 80;
    canvas.SetPosition(Vector2{20, y});
    canvas.DrawString("ROCKET LAB (diagnostic)");
    for (const std::string& line : describe(status)) {
        y += 18;
        canvas.SetPosition(Vector2{20, y});
        canvas.DrawString(line);
    }
}

}  // namespace rocketlab
