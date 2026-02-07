#pragma once

#include <cstdint>
#include <optional>
#include <string>
#include <vector>

class Player;
class ProtocolGame;

enum class HuntingTaskState : uint8_t {
	Locked = 0,
	Exhausted = 1,
	Select = 2,
	Wildcard = 3,
	Active = 4,
	Redeem = 5,
};

enum class HuntingTaskAction : uint8_t {
	ListReroll = 0,
	BonusReroll = 1,
	SelectWildcard = 2,
	Select = 3,
	Remove = 4,
	Collect = 5,
};

struct HuntingTaskData {
	HuntingTaskState state = HuntingTaskState::Select;
	uint16_t raceId = 0;
	uint16_t currentKills = 0;
	uint16_t requiredKills = 0;
	uint8_t stars = 1;
	uint32_t rewardPoints = 0;
	bool bestiaryUnlocked = false;
};

struct HuntingTaskSlot {
	uint8_t slotId = 0;
	HuntingTaskState state = HuntingTaskState::Select;
	std::optional<HuntingTaskData> task;
	int64_t rerollTimeStamp = 0;
};

class HuntingTaskSystem {
public:
	explicit HuntingTaskSystem(Player &player);

	void initialize();
	void loadSlot(const HuntingTaskSlot &slotData);
	const std::vector<HuntingTaskSlot> &getSlots() const;

	void onKill(uint16_t raceId);
	void handleAction(uint8_t slotId, HuntingTaskAction action, bool bestiaryUnlocked, uint16_t raceId);

	void sendBaseData() const;
	void sendPrices() const;
	void sendResourceBalance() const;
	void sendSlotState(const HuntingTaskSlot &slot) const;
	void sendRerollTime(uint8_t slotId, int64_t timeLeftSeconds) const;

	uint64_t getResourcePoints() const;
	void setResourcePoints(uint64_t points);

	static constexpr uint8_t kExtendedOpcodeAction = 230;
	static constexpr uint8_t kExtendedOpcodeEvent = 231;
	static constexpr uint8_t kResourceHuntingTask = 50;

private:
	Player &player;
	std::vector<HuntingTaskSlot> slots;
	uint64_t resourcePoints = 0;

	HuntingTaskSlot *findSlot(uint8_t slotId);
	const HuntingTaskSlot *findSlot(uint8_t slotId) const;
	HuntingTaskData buildTaskData(uint16_t raceId, bool bestiaryUnlocked) const;
	void moveToSelectState(HuntingTaskSlot &slot);
	void moveToWildcardState(HuntingTaskSlot &slot);
	void moveToActiveState(HuntingTaskSlot &slot, uint16_t raceId, bool bestiaryUnlocked);
	void moveToRedeemState(HuntingTaskSlot &slot);
	void moveToExhaustedState(HuntingTaskSlot &slot);

	void sendExtendedEvent(const std::string &payload) const;
};
