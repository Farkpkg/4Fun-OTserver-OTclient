WeeklyTaskRewards = {
    pointsPerTask = 10,
    soulSealsPerTask = 1,
    baseExperiencePerLevel = 150,
    multiplierByCompletedTasks = {
        { min = 0, max = 3, value = 1.0 },
        { min = 4, max = 7, value = 1.3 },
        { min = 8, max = 11, value = 1.7 },
        { min = 12, max = 15, value = 2.0 },
        { min = 16, max = 18, value = 2.5 },
    },
    shop = {
        { id = "expansion_unlock", type = "expansion", price = 250, name = "Weekly Expansion Unlock" },
        { id = "xp_boost_small", type = "experience", amount = 150000, price = 80, name = "XP Crate" },
        { id = "soul_pack", type = "seals", amount = 10, price = 60, name = "Soul Seal Pack" },
        { id = "supply_token", type = "item", itemId = 23373, amount = 5, price = 40, name = "Supply Token" },
    }
}
