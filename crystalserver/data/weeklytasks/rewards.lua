WeeklyTaskRewards = {
    pointsPerTask = 10,
    soulSealsPerTask = 1,
    -- Official-like fixed base XP by selected weekly difficulty.
    baseExperienceByDifficulty = {
        Beginner = 150000,
        Adept = 350000,
        Expert = 700000,
        Master = 1200000,
    },
    multiplierByCompletedTasks = {
        { min = 0, max = 3, value = 1.0 },
        { min = 4, max = 7, value = 1.3 },
        { min = 8, max = 11, value = 1.7 },
        { min = 12, max = 14, value = 2.0 },
        { min = 15, max = 1000, value = 2.5 },
    },
    shop = {
        { id = "expansion_unlock", type = "expansion", price = 250, name = "Weekly Expansion Unlock" },
        { id = "xp_boost_small", type = "experience", amount = 150000, price = 80, name = "XP Crate" },
        { id = "soul_pack", type = "seals", amount = 10, price = 60, name = "Soul Seal Pack" },
        { id = "supply_token", type = "item", itemId = 23373, amount = 5, price = 40, name = "Supply Token" },
    }
}
