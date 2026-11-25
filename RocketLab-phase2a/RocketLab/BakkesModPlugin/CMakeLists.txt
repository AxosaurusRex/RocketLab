cmake_minimum_required(VERSION 3.25)

# Never offer Debug: pluginsdk.dll passes C++ standard library objects to the
# plugin, and Debug builds lay those objects out differently.
set(CMAKE_CONFIGURATION_TYPES "Release;RelWithDebInfo" CACHE STRING "" FORCE)

project(RocketLabPlugin VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
# Static C++ runtime, so the DLL does not depend on whichever runtime the game loaded.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")

if(MSVC)
    add_compile_options(/W4 /utf-8 /external:W0)
endif()

# Code with no SDK or Windows dependency, so it can be unit tested.
add_library(rocketlab_core STATIC
    src/core/GameStatus.cpp
    src/core/EventCounter.cpp
)
target_include_directories(rocketlab_core PUBLIC include)

enable_testing()
add_executable(rocketlab_core_tests tests/core_tests.cpp)
target_link_libraries(rocketlab_core_tests PRIVATE rocketlab_core)
add_test(NAME core COMMAND rocketlab_core_tests)

option(ROCKETLAB_BUILD_PLUGIN "Build the BakkesMod plugin DLL (needs MSVC)" ${MSVC})

if(ROCKETLAB_BUILD_PLUGIN)
    if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
        message(FATAL_ERROR "The plugin must be built for x64.")
    endif()

    set(BAKKESMOD_SDK_DIR "" CACHE PATH "BakkesMod SDK folder (contains include and lib)")
    set(sdk_dir "${BAKKESMOD_SDK_DIR}")
    if(NOT sdk_dir)
        file(TO_CMAKE_PATH "$ENV{APPDATA}/bakkesmod/bakkesmod/bakkesmodsdk" sdk_dir)
    endif()
    if(NOT EXISTS "${sdk_dir}/include/bakkesmod/plugin/bakkesmodplugin.h"
       OR NOT EXISTS "${sdk_dir}/lib/pluginsdk.lib")
        message(FATAL_ERROR "BakkesMod SDK not found at '${sdk_dir}'. "
                            "Run BakkesMod once, or pass -DBAKKESMOD_SDK_DIR=<folder>.")
    endif()
    message(STATUS "BakkesMod SDK: ${sdk_dir}")

    add_library(RocketLab SHARED
        src/plugin/RocketLabPlugin.cpp
        src/plugin/GameStateReader.cpp
        src/plugin/HookProbe.cpp
        src/plugin/StatusOverlay.cpp
    )
    target_include_directories(RocketLab PRIVATE src/plugin)
    target_include_directories(RocketLab SYSTEM PRIVATE "${sdk_dir}/include")
    target_compile_definitions(RocketLab PRIVATE ROCKETLAB_VERSION="${PROJECT_VERSION}")
    target_link_libraries(RocketLab PRIVATE rocketlab_core "${sdk_dir}/lib/pluginsdk.lib")
endif()
