-- Ranked tiers
Newbie       = 1
Wooden       = 2
Gold         = 3
Platinum     = 4
Crystal      = 5
Terror       = 6
Champion     = 7
Exalted      = 8
Megalomaniac = 9
Sanguinum    = 10
Warlord      = 11
LastRank     = Warlord

PrestigeRankData = {
    [Newbie] =       {img = "rank-1",  name = "Newbie",       points = {min = 0,    max = 399},   shader = "text_newbie",       banner = "rank-0-bg",   bg0 = "bg-newbie",       bg1 = "bg-newbie-anim"},
    [Wooden] =       {img = "rank-2",  name = "Wooden",       points = {min = 400,  max = 899},   shader = "text_wooden",       banner = "rank-1-bg",   bg0 = "bg-wooden",       bg1 = "bg-wooden-anim"},
    [Gold] =         {img = "rank-3",  name = "Gold",         points = {min = 900,  max = 1499},  shader = "text_gold",         banner = "rank-2-bg",   bg0 = "bg-gold",         bg1 = "bg-gold-anim"},
    [Platinum] =     {img = "rank-4",  name = "Platinum",     points = {min = 1500, max = 2199},  shader = "text_platinum",     banner = "rank-3-bg",   bg0 = "bg-platinum",     bg1 = "bg-platinum-anim"},
    [Crystal] =      {img = "rank-5",  name = "Crystal",      points = {min = 2200, max = 2999},  shader = "text_crystal",      banner = "rank-4-bg",   bg0 = "bg-crystal",      bg1 = "bg-crystal-anim"},
    [Terror] =       {img = "rank-6",  name = "Terror",       points = {min = 3000, max = 3899},  shader = "text_terror",       banner = "rank-5-bg",   bg0 = "bg-terror",       bg1 = "bg-terror-anim"},
    [Champion] =     {img = "rank-7",  name = "Champion",     points = {min = 3900, max = 4899},  shader = "text_champion",     banner = "rank-6-bg",   bg0 = "bg-champion",     bg1 = "bg-champion-anim"},
    [Exalted] =      {img = "rank-8",  name = "Exalted",      points = {min = 4900, max = 5999},  shader = "text_exalted",      banner = "rank-7-bg",   bg0 = "bg-exalted",      bg1 = "bg-exalted-anim"},
    [Megalomaniac] = {img = "rank-9",  name = "Megalomaniac", points = {min = 6000, max = 6999},  shader = "text_megalomaniac", banner = "rank-8-bg",   bg0 = "bg-megalomaniac", bg1 = "bg-megalomaniac-anim"},
    [Sanguinum] =    {img = "rank-10", name = "Sanguinum",    points = {min = 7000, max = 7999},  shader = "text_sanguinum",    banner = "rank-9-bg",   bg0 = "bg-sanguinum",    bg1 = "bg-sanguinum-anim"},
    [Warlord] =      {img = "rank-11", name = "Warlord",      points = {min = 8000, max = nil},   shader = "text_warlord",      banner = "rank-10-bg",  bg0 = "bg-warlord",      bg1 = "bg-warlord-anim"}
}

-- Map IDs
MapEmpty       = 0
TrueAsura      = 1
DeepDesert     = 2
FireLibrary    = 3
RottenGolem    = 4
SparklingPools = 5

MapData = {
	[MapEmpty]  =      {name = "None"},
	[TrueAsura] =      {name = "True Asura",      img = "true-asura"},
	[DeepDesert] =     {name = "Deep Desert",     img = "deep-desert"},
	[FireLibrary] =    {name = "Fire Library",    img = "fire-library"},
	[RottenGolem] =    {name = "Rotten Golem",    img = "rotten-golem"},
	[SparklingPools] = {name = "Sparkling Pools", img = "sparkling-pools"}
}

QueueOpen          = 0
QueueClose         = 1
QueueNoMoney       = 2
QueueNotInTemple   = 3
QueueLowLevel      = 4

DefaultQueueText = "Are you ready to unleash your power and habilities?\nProve your strength and rise through the ranks.\nOnly the strongest will claim the title of true warrior."

QueueStatusTexts = {
	[QueueOpen] = "Welcome to our famous Prestige Arena!\nYour current division is %s.\n\nYou will be charged [color=#ff9854]%s gold coins[/color] to participate.",
	[QueueClose] = "Our Prestige Arena is currently unavailable for battles. Please remember that there are specific dates and times when battles are unlocked.\n\nThe queue will open in: [color=#ff9854]%s[/color].",
	[QueueNoMoney] = "You do not have enough money to search for battles.\n\nSince you are in the %s division, each battle will cost [color=#ff9854]%s gold coins[/color].",
	[QueueNotInTemple] = "To enter battles in the Prestige Arena, you must be inside a temple.\nGo to any temple in your world and try again.",
    [QueueLowLevel] = "You are too weak to enter in the Prestige Arena.\nYou need to be at level %s or higher.",
}

QueueStatusTooltips = {
    [QueueOpen] = "",
    [QueueClose] = "The Prestige Arena is currently closed.",
    [QueueNoMoney] = "Insufficient funds. Ensure you have at least %s gold coins.",
    [QueueNotInTemple] = "You must be within a designated temple area.",
    [QueueLowLevel] = "A minimum level of %s is required.",
}

function GetPrestigePercent(currentRank, prestigePoints)
    if currentRank == LastRank then
        return 100
    end
    
    local nextRankPoints = PrestigeRankData[currentRank].points.max
    local currentMinPoints = PrestigeRankData[currentRank].points.min
    
    local progressPoints = prestigePoints - currentMinPoints
    local totalPointsNeeded = nextRankPoints - currentMinPoints
    return (progressPoints / totalPointsNeeded) * 100
end