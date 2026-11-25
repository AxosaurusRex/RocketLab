#include "rocketlab/EventCounter.h"

#include <algorithm>
#include <utility>

namespace rocketlab {

EventCounter::EventCounter(std::vector<std::string> names)
    : names_(std::move(names)), counts_(names_.size(), 0) {}

void EventCounter::record(std::size_t index) {
    if (index < counts_.size()) ++counts_[index];
}

void EventCounter::reset() { std::fill(counts_.begin(), counts_.end(), 0); }

std::vector<std::string> EventCounter::report() const {
    std::vector<std::string> lines;
    for (std::size_t i = 0; i < names_.size(); ++i) {
        lines.push_back(std::to_string(counts_[i]) + "  " + names_[i]);
    }
    return lines;
}

}  // namespace rocketlab
