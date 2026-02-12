TaskBoardDomainCalculator = TaskBoardDomainCalculator or {}

local MULTIPLIER_BANDS = {
    { min = 0, max = 3, value = 1.0, nextThreshold = 4 },
    { min = 4, max = 7, value = 1.3, nextThreshold = 8 },
    { min = 8, max = 11, value = 1.7, nextThreshold = 12 },
    { min = 12, max = 15, value = 2.0, nextThreshold = 16 },
    { min = 16, max = 18, value = 2.5, nextThreshold = nil },
}

function TaskBoardDomainCalculator.getMultiplier(totalCompleted)
    local total = math.max(0, tonumber(totalCompleted) or 0)

    for _, band in ipairs(MULTIPLIER_BANDS) do
        if total >= band.min and total <= band.max then
            return {
                value = band.value,
                band = {
                    min = band.min,
                    max = band.max,
                },
                nextThreshold = band.nextThreshold,
            }
        end
    end

    local lastBand = MULTIPLIER_BANDS[#MULTIPLIER_BANDS]
    return {
        value = lastBand.value,
        band = {
            min = lastBand.min,
            max = lastBand.max,
        },
        nextThreshold = nil,
    }
end

function TaskBoardDomainCalculator.calculateWeeklyReward(baseReward, multiplier)
    local base = tonumber(baseReward) or 0
    local mult = tonumber(multiplier) or 1
    return base * mult
end

return TaskBoardDomainCalculator
