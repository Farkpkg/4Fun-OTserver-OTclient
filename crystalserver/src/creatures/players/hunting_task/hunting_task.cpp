#include "creatures/players/hunting_task/hunting_task.hpp"

#include <algorithm>
#include <cmath>
#include <string>
#include <vector>

#include "creatures/players/player.hpp"
#include "game/game.hpp"
#include "server/server_definitions.hpp"

namespace {
constexpr uint16_t kDefaultRequiredKills = 1;
constexpr uint8_t kDefaultStars = 1;
constexpr uint32_t kDefaultRewardPoints = 0;

std::string joinRaceList(const std::vector<uint16_t> &raceIds) {
	std::string result;
	for (size_t index = 0; index < raceIds.size(); ++index) {
		if (index > 0) {
			result.push_back(',');
		}
		result += std::to_string(raceIds[index]);
	}
	return result;
}

std::vector<uint16_t> getBestiaryRaceIds() {
	std::vector<uint16_t> monsterList;
	const auto &bestiary = g_game().getBestiaryList();
	monsterList.reserve(bestiary.size());
	for (const auto &[raceId, name] : bestiary) {
		monsterList.push_back(raceId);
	}
	return monsterList;
}
} // namespace

HuntingTaskSystem::HuntingTaskSystem(Player &player) :
	player(player) {}

void HuntingTaskSystem::initialize() {
	if (!slots.empty()) {
		return;
	}

	for (uint8_t slotId = 0; slotId < 3; ++slotId) {
		HuntingTaskSlot slot;
		slot.slotId = slotId;
		slot.state = HuntingTaskState::Select;
		slot.rerollTimeStamp = 0;
		slots.push_back(slot);
	}
}

void HuntingTaskSystem::loadSlot(const HuntingTaskSlot &slotData) {
	auto *slot = findSlot(slotData.slotId);
	if (!slot) {
		slots.push_back(slotData);
		return;
	}

	*slot = slotData;
}

const std::vector<HuntingTaskSlot> &HuntingTaskSystem::getSlots() const {
	return slots;
}

uint64_t HuntingTaskSystem::getResourcePoints() const {
	return resourcePoints;
}

void HuntingTaskSystem::setResourcePoints(uint64_t points) {
	resourcePoints = points;
}

HuntingTaskSlot *HuntingTaskSystem::findSlot(uint8_t slotId) {
	auto it = std::find_if(slots.begin(), slots.end(), [slotId](const HuntingTaskSlot &slot) {
		return slot.slotId == slotId;
	});
	if (it == slots.end()) {
		return nullptr;
	}
	return std::addressof(*it);
}

const HuntingTaskSlot *HuntingTaskSystem::findSlot(uint8_t slotId) const {
	auto it = std::find_if(slots.begin(), slots.end(), [slotId](const HuntingTaskSlot &slot) {
		return slot.slotId == slotId;
	});
	if (it == slots.end()) {
		return nullptr;
	}
	return std::addressof(*it);
}

HuntingTaskData HuntingTaskSystem::buildTaskData(uint16_t raceId, bool bestiaryUnlocked) const {
	HuntingTaskData data;
	data.state = HuntingTaskState::Active;
	data.raceId = raceId;
	data.requiredKills = kDefaultRequiredKills;
	data.stars = kDefaultStars;
	data.rewardPoints = kDefaultRewardPoints;
	data.bestiaryUnlocked = bestiaryUnlocked;
	return data;
}

void HuntingTaskSystem::onKill(uint16_t raceId) {
	for (auto &slot : slots) {
		if (slot.state != HuntingTaskState::Active || !slot.task) {
			continue;
		}
		auto &task = *slot.task;
		if (task.raceId != raceId) {
			continue;
		}
		if (task.currentKills >= task.requiredKills) {
			continue;
		}
		task.currentKills = static_cast<uint16_t>(std::min<uint32_t>(task.currentKills + 1, task.requiredKills));
		if (task.currentKills >= task.requiredKills) {
			moveToRedeemState(slot);
		} else {
			sendSlotState(slot);
		}
	}
}

void HuntingTaskSystem::handleAction(uint8_t slotId, HuntingTaskAction action, bool bestiaryUnlocked, uint16_t raceId) {
	auto *slot = findSlot(slotId);
	if (!slot) {
		return;
	}

	switch (action) {
	case HuntingTaskAction::ListReroll:
		moveToSelectState(*slot);
		break;
	case HuntingTaskAction::BonusReroll:
		if (slot->task) {
			slot->task->stars = kDefaultStars;
			slot->task->rewardPoints = kDefaultRewardPoints;
		}
		sendSlotState(*slot);
		break;
	case HuntingTaskAction::SelectWildcard:
		moveToWildcardState(*slot);
		break;
	case HuntingTaskAction::Select:
		moveToActiveState(*slot, raceId, bestiaryUnlocked);
		break;
	case HuntingTaskAction::Remove:
		moveToSelectState(*slot);
		break;
	case HuntingTaskAction::Collect:
		if (slot->state == HuntingTaskState::Redeem && slot->task) {
			resourcePoints += slot->task->rewardPoints;
			moveToExhaustedState(*slot);
			sendResourceBalance();
		}
		break;
	}
}

void HuntingTaskSystem::moveToSelectState(HuntingTaskSlot &slot) {
	slot.state = HuntingTaskState::Select;
	slot.task.reset();
	sendSlotState(slot);
}

void HuntingTaskSystem::moveToWildcardState(HuntingTaskSlot &slot) {
	slot.state = HuntingTaskState::Wildcard;
	slot.task.reset();
	sendSlotState(slot);
}

void HuntingTaskSystem::moveToActiveState(HuntingTaskSlot &slot, uint16_t raceId, bool bestiaryUnlocked) {
	slot.state = HuntingTaskState::Active;
	slot.task = buildTaskData(raceId, bestiaryUnlocked);
	sendSlotState(slot);
}

void HuntingTaskSystem::moveToRedeemState(HuntingTaskSlot &slot) {
	slot.state = HuntingTaskState::Redeem;
	if (slot.task) {
		slot.task->state = HuntingTaskState::Redeem;
	}
	sendSlotState(slot);
}

void HuntingTaskSystem::moveToExhaustedState(HuntingTaskSlot &slot) {
	slot.state = HuntingTaskState::Exhausted;
	slot.task.reset();
	sendSlotState(slot);
}

void HuntingTaskSystem::sendBaseData() const {
	const auto monsterList = getBestiaryRaceIds();
	const std::string payload = "onPreyHuntingBaseData\t" + joinRaceList(monsterList) + "\t" +
		std::to_string(kDefaultStars) + ":" + std::to_string(kDefaultRewardPoints);
	sendExtendedEvent(payload);
}

void HuntingTaskSystem::sendPrices() const {
	const std::string payload = "onPreyHuntingPrice\t0\t0\t0\t0";
	sendExtendedEvent(payload);
}

void HuntingTaskSystem::sendResourceBalance() const {
	player.sendResourceBalance(RESOURCE_TASK_HUNTING, resourcePoints);
}

void HuntingTaskSystem::sendRerollTime(uint8_t slotId, int64_t timeLeftSeconds) const {
	const std::string payload = "onUpdateRerrolTime\t" + std::to_string(slotId) + "\t" +
		std::to_string(std::max<int64_t>(timeLeftSeconds, 0));
	sendExtendedEvent(payload);
}

void HuntingTaskSystem::sendSlotState(const HuntingTaskSlot &slot) const {
	switch (slot.state) {
	case HuntingTaskState::Locked: {
		const std::string payload = "onHuntingLockedState\t" + std::to_string(slot.slotId) + "\t0\t" +
			std::to_string(static_cast<uint8_t>(slot.state));
		sendExtendedEvent(payload);
		break;
	}
	case HuntingTaskState::Select: {
		const auto monsterList = getBestiaryRaceIds();
		const std::string payload = "onHuntingSelectState\t" + std::to_string(slot.slotId) + "\t" +
			std::to_string(static_cast<uint8_t>(slot.state)) + "\t" + joinRaceList(monsterList);
		sendExtendedEvent(payload);
		break;
	}
	case HuntingTaskState::Wildcard: {
		const auto monsterList = getBestiaryRaceIds();
		const std::string payload = "onHuntingWildcardState\t" + std::to_string(slot.slotId) + "\t" +
			std::to_string(static_cast<uint8_t>(slot.state)) + "\t" + joinRaceList(monsterList);
		sendExtendedEvent(payload);
		break;
	}
	case HuntingTaskState::Active:
	case HuntingTaskState::Redeem: {
		if (!slot.task) {
			break;
		}
		const auto &task = *slot.task;
		const std::string payload = "onHuntingActiveState\t" + std::to_string(slot.slotId) + "\t" +
			std::to_string(static_cast<uint8_t>(slot.state)) + "\t" +
			std::to_string(task.raceId) + "\t" + (task.bestiaryUnlocked ? "1" : "0") + "\t" +
			std::to_string(task.requiredKills) + "\t" + std::to_string(task.currentKills) + "\t" +
			std::to_string(task.stars) + "\t" + std::to_string(task.rewardPoints);
		sendExtendedEvent(payload);
		break;
	}
	case HuntingTaskState::Exhausted: {
		const std::string payload = "onHuntingExhaustedState\t" + std::to_string(slot.slotId) + "\t" +
			std::to_string(static_cast<uint8_t>(slot.state));
		sendExtendedEvent(payload);
		break;
	}
	}
}

void HuntingTaskSystem::sendExtendedEvent(const std::string &payload) const {
	player.sendExtendedOpcode(kExtendedOpcodeEvent, payload);
}
