#pragma once

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

namespace rocketlab {

// Counts how often each of a fixed list of game events fired.
// Used from the game thread only.
class EventCounter {
public:
    explicit EventCounter(std::vector<std::string> names);

    std::size_t size() const { return names_.size(); }
    const std::string& name(std::size_t index) const { return names_.at(index); }
    std::uint64_t count(std::size_t index) const { return counts_.at(index); }

    void record(std::size_t index);  // out-of-range indexes are ignored
    void reset();
    std::vector<std::string> report() const;

private:
    std::vector<std::string> names_;
    std::vector<std::uint64_t> counts_;
};

}  // namespace rocketlab
