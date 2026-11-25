#pragma once

// The only place that includes the BakkesMod SDK.
// The SDK headers rely on these being included first, and GameWrapper only
// declares GetDataFolder() once std::filesystem support is known.
#include <cstdint>
#include <filesystem>
#include <memory>
#include <string>

#include "bakkesmod/plugin/bakkesmodplugin.h"
